package auth

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	postgresgen "github.com/vgpl2000/Sitaara/backend/internal/postgres/gen"
)

type User struct {
	ID    uuid.UUID `json:"id"`
	Email string    `json:"email"`
}

type Session struct {
	User                  User      `json:"user"`
	OnboardingState       string    `json:"onboardingState"`
	AccessToken           string    `json:"accessToken"`
	RefreshToken          string    `json:"refreshToken"`
	AccessTokenExpiresAt  time.Time `json:"accessTokenExpiresAt"`
	RefreshTokenExpiresAt time.Time `json:"refreshTokenExpiresAt"`
}

type Me struct {
	ID              uuid.UUID `json:"id"`
	Email           string    `json:"email"`
	OnboardingState string    `json:"onboardingState"`
	Family          any       `json:"family"`
}

type Service struct {
	pool              *pgxpool.Pool
	queries           *postgresgen.Queries
	hasher            *PasswordHasher
	accessTokens      *AccessTokenManager
	refreshSecret     []byte
	refreshTTL        time.Duration
	now               Clock
	dummyPasswordHash string
}

type ServiceOptions struct {
	Pool          *pgxpool.Pool
	Hasher        *PasswordHasher
	AccessTokens  *AccessTokenManager
	RefreshSecret []byte
	RefreshTTL    time.Duration
	Now           Clock
}

func NewService(ctx context.Context, options ServiceOptions) (*Service, error) {
	dummyHash, err := options.Hasher.Hash(ctx, "not-a-real-user-password")
	if err != nil {
		return nil, fmt.Errorf("prepare password verification: %w", err)
	}

	return &Service{
		pool:              options.Pool,
		queries:           postgresgen.New(options.Pool),
		hasher:            options.Hasher,
		accessTokens:      options.AccessTokens,
		refreshSecret:     append([]byte(nil), options.RefreshSecret...),
		refreshTTL:        options.RefreshTTL,
		now:               options.Now,
		dummyPasswordHash: dummyHash,
	}, nil
}

func (s *Service) Register(ctx context.Context, rawEmail, password string) (Session, error) {
	email, err := normalizeEmail(rawEmail)
	if err != nil {
		return Session{}, err
	}
	if err := validatePassword(password); err != nil {
		return Session{}, err
	}

	passwordHash, err := s.hasher.Hash(ctx, password)
	if err != nil {
		return Session{}, fmt.Errorf("hash password: %w", err)
	}

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return Session{}, fmt.Errorf("begin registration: %w", err)
	}
	defer rollback(ctx, tx)
	queries := s.queries.WithTx(tx)

	created, err := queries.CreateUser(ctx, postgresgen.CreateUserParams{
		ID:           uuid.New(),
		Email:        email,
		PasswordHash: passwordHash,
	})
	if err != nil {
		if isUniqueViolation(err) {
			return Session{}, ErrEmailAlreadyUsed
		}
		return Session{}, fmt.Errorf("create user: %w", err)
	}

	session, err := s.createSession(ctx, queries, User{ID: created.ID, Email: created.Email}, uuid.New(), uuid.Nil)
	if err != nil {
		return Session{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return Session{}, fmt.Errorf("commit registration: %w", err)
	}
	return session, nil
}

func (s *Service) Login(ctx context.Context, rawEmail, password string) (Session, error) {
	email, err := normalizeEmail(rawEmail)
	forceInvalid := err != nil
	if err != nil {
		email = "invalid@example.invalid"
	}
	if validatePassword(password) != nil {
		password = "invalid-password"
		forceInvalid = true
	}

	user, queryErr := s.queries.GetUserByEmail(ctx, email)
	encodedHash := s.dummyPasswordHash
	if queryErr == nil {
		encodedHash = user.PasswordHash
	} else if !errors.Is(queryErr, pgx.ErrNoRows) {
		return Session{}, fmt.Errorf("lookup user: %w", queryErr)
	}

	passwordMatches, verifyErr := s.hasher.Verify(ctx, password, encodedHash)
	if verifyErr != nil {
		return Session{}, fmt.Errorf("verify password: %w", verifyErr)
	}
	if forceInvalid || queryErr != nil || !passwordMatches {
		return Session{}, ErrInvalidCredentials
	}

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return Session{}, fmt.Errorf("begin login: %w", err)
	}
	defer rollback(ctx, tx)

	session, err := s.createSession(
		ctx,
		s.queries.WithTx(tx),
		User{ID: user.ID, Email: user.Email},
		uuid.New(),
		uuid.Nil,
	)
	if err != nil {
		return Session{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return Session{}, fmt.Errorf("commit login: %w", err)
	}
	return session, nil
}

func (s *Service) Refresh(ctx context.Context, rawToken string) (Session, error) {
	if rawToken == "" || len(rawToken) > 512 {
		return Session{}, ErrInvalidRefreshToken
	}

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return Session{}, fmt.Errorf("begin refresh: %w", err)
	}
	defer rollback(ctx, tx)
	queries := s.queries.WithTx(tx)

	stored, err := queries.GetRefreshSessionForUpdate(ctx, digestOpaqueToken(s.refreshSecret, rawToken))
	if errors.Is(err, pgx.ErrNoRows) {
		return Session{}, ErrInvalidRefreshToken
	}
	if err != nil {
		return Session{}, fmt.Errorf("lookup refresh session: %w", err)
	}

	now := s.now().UTC()
	if stored.UsedAt.Valid {
		if _, err := queries.RevokeRefreshFamily(ctx, postgresgen.RevokeRefreshFamilyParams{
			FamilyID:  stored.FamilyID,
			RevokedAt: timestamp(now),
		}); err != nil {
			return Session{}, fmt.Errorf("revoke reused refresh family: %w", err)
		}
		if err := tx.Commit(ctx); err != nil {
			return Session{}, fmt.Errorf("commit refresh reuse revocation: %w", err)
		}
		return Session{}, ErrSessionReused
	}
	if stored.RevokedAt.Valid || !stored.ExpiresAt.Valid || !now.Before(stored.ExpiresAt.Time) {
		return Session{}, ErrInvalidRefreshToken
	}

	rows, err := queries.MarkRefreshSessionUsed(ctx, postgresgen.MarkRefreshSessionUsedParams{
		ID:     stored.ID,
		UsedAt: timestamp(now),
	})
	if err != nil {
		return Session{}, fmt.Errorf("consume refresh session: %w", err)
	}
	if rows != 1 {
		return Session{}, ErrInvalidRefreshToken
	}

	user, err := queries.GetUserByID(ctx, stored.UserID)
	if err != nil {
		return Session{}, fmt.Errorf("load refresh user: %w", err)
	}
	session, err := s.createSession(
		ctx,
		queries,
		User{ID: user.ID, Email: user.Email},
		stored.FamilyID,
		stored.ID,
	)
	if err != nil {
		return Session{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return Session{}, fmt.Errorf("commit refresh: %w", err)
	}
	return session, nil
}

func (s *Service) Logout(ctx context.Context, principal Principal, rawToken string) error {
	if rawToken == "" || len(rawToken) > 512 {
		return nil
	}

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("begin logout: %w", err)
	}
	defer rollback(ctx, tx)
	queries := s.queries.WithTx(tx)

	stored, err := queries.GetRefreshSessionForUpdate(ctx, digestOpaqueToken(s.refreshSecret, rawToken))
	if errors.Is(err, pgx.ErrNoRows) {
		return tx.Commit(ctx)
	}
	if err != nil {
		return fmt.Errorf("lookup logout session: %w", err)
	}
	if stored.UserID != principal.UserID || stored.FamilyID != principal.SessionFamily {
		return tx.Commit(ctx)
	}

	if _, err := queries.RevokeRefreshFamilyForUser(ctx, postgresgen.RevokeRefreshFamilyForUserParams{
		FamilyID:  stored.FamilyID,
		UserID:    stored.UserID,
		RevokedAt: timestamp(s.now().UTC()),
	}); err != nil {
		return fmt.Errorf("revoke logout session: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit logout: %w", err)
	}
	return nil
}

func (s *Service) GetMe(ctx context.Context, userID uuid.UUID) (Me, error) {
	user, err := s.queries.GetUserByID(ctx, userID)
	if err != nil {
		return Me{}, fmt.Errorf("get current user: %w", err)
	}
	return Me{
		ID:              user.ID,
		Email:           user.Email,
		OnboardingState: "needs_family",
		Family:          nil,
	}, nil
}

func (s *Service) createSession(
	ctx context.Context,
	queries *postgresgen.Queries,
	user User,
	familyID uuid.UUID,
	parentID uuid.UUID,
) (Session, error) {
	onboardingState := "needs_family"
	if _, err := queries.GetMembershipByUser(ctx, user.ID); err == nil {
		onboardingState = "onboarded"
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return Session{}, fmt.Errorf("lookup session membership: %w", err)
	}

	rawRefreshToken, err := newOpaqueToken()
	if err != nil {
		return Session{}, err
	}

	now := s.now().UTC()
	refreshExpiresAt := now.Add(s.refreshTTL)
	parent := pgtype.UUID{}
	if parentID != uuid.Nil {
		parent = pgtype.UUID{Bytes: parentID, Valid: true}
	}

	if _, err := queries.CreateRefreshSession(ctx, postgresgen.CreateRefreshSessionParams{
		ID:              uuid.New(),
		UserID:          user.ID,
		TokenDigest:     digestOpaqueToken(s.refreshSecret, rawRefreshToken),
		FamilyID:        familyID,
		ParentSessionID: parent,
		ExpiresAt:       timestamp(refreshExpiresAt),
	}); err != nil {
		return Session{}, fmt.Errorf("create refresh session: %w", err)
	}

	accessToken, accessExpiresAt, err := s.accessTokens.Issue(user.ID, familyID)
	if err != nil {
		return Session{}, err
	}
	return Session{
		User:                  user,
		OnboardingState:       onboardingState,
		AccessToken:           accessToken,
		RefreshToken:          rawRefreshToken,
		AccessTokenExpiresAt:  accessExpiresAt,
		RefreshTokenExpiresAt: refreshExpiresAt,
	}, nil
}

func timestamp(value time.Time) pgtype.Timestamptz {
	return pgtype.Timestamptz{Time: value, Valid: true}
}

func rollback(ctx context.Context, tx pgx.Tx) {
	_ = tx.Rollback(ctx)
}

func isUniqueViolation(err error) bool {
	var postgresError *pgconn.PgError
	return errors.As(err, &postgresError) && postgresError.Code == "23505"
}
