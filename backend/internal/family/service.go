package family

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

type Clock func() time.Time

type Child struct {
	ID          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	DateOfBirth string    `json:"dateOfBirth"`
}

type Summary struct {
	ID          uuid.UUID `json:"id"`
	Child       Child     `json:"child"`
	OwnRole     string    `json:"ownRole"`
	PartnerRole *string   `json:"partnerRole"`
	Status      string    `json:"status"`
}

type Invite struct {
	Code      string    `json:"code"`
	ExpiresAt time.Time `json:"expiresAt"`
}

type Service struct {
	pool         *pgxpool.Pool
	queries      *postgresgen.Queries
	inviteSecret []byte
	now          Clock
}

func NewService(pool *pgxpool.Pool, inviteSecret []byte, now Clock) *Service {
	return &Service{
		pool:         pool,
		queries:      postgresgen.New(pool),
		inviteSecret: append([]byte(nil), inviteSecret...),
		now:          now,
	}
}

func (s *Service) Create(ctx context.Context, userID uuid.UUID, rawRole, childName, rawDateOfBirth string) (Summary, error) {
	role, err := parseRole(rawRole)
	if err != nil {
		return Summary{}, err
	}
	name, dateOfBirth, err := validateChild(childName, rawDateOfBirth, s.now().UTC())
	if err != nil {
		return Summary{}, err
	}

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return Summary{}, fmt.Errorf("begin family creation: %w", err)
	}
	defer rollback(ctx, tx)
	queries := s.queries.WithTx(tx)

	if _, err := queries.LockUserForOnboarding(ctx, userID); err != nil {
		return Summary{}, fmt.Errorf("lock family creator: %w", err)
	}
	if _, err := queries.GetMembershipByUser(ctx, userID); err == nil {
		return Summary{}, ErrAlreadyInFamily
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return Summary{}, fmt.Errorf("check existing family: %w", err)
	}

	familyID := uuid.New()
	if _, err := queries.CreateFamily(ctx, postgresgen.CreateFamilyParams{ID: familyID, CreatedBy: userID}); err != nil {
		return Summary{}, fmt.Errorf("create family: %w", err)
	}
	if _, err := queries.CreateFamilyMember(ctx, postgresgen.CreateFamilyMemberParams{
		FamilyID: familyID,
		UserID:   userID,
		Role:     role,
	}); err != nil {
		if isUniqueViolation(err) {
			return Summary{}, ErrAlreadyInFamily
		}
		return Summary{}, fmt.Errorf("create family member: %w", err)
	}
	childID := uuid.New()
	if _, err := queries.CreateChild(ctx, postgresgen.CreateChildParams{
		ID:          childID,
		FamilyID:    familyID,
		Name:        name,
		DateOfBirth: pgtype.Date{Time: dateOfBirth, Valid: true},
	}); err != nil {
		return Summary{}, fmt.Errorf("create child: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return Summary{}, fmt.Errorf("commit family creation: %w", err)
	}
	return summary(familyID, childID, name, dateOfBirth, role, nil), nil
}

func (s *Service) Get(ctx context.Context, userID uuid.UUID) (Summary, error) {
	row, err := s.queries.GetFamilySummaryByUser(ctx, userID)
	if errors.Is(err, pgx.ErrNoRows) {
		return Summary{}, ErrFamilyRequired
	}
	if err != nil {
		return Summary{}, fmt.Errorf("get family summary: %w", err)
	}
	var partnerRole *postgresgen.ParentRole
	if row.PartnerRole.Valid {
		value := row.PartnerRole.ParentRole
		partnerRole = &value
	}
	return summary(row.FamilyID, row.ChildID, row.ChildName, row.DateOfBirth.Time, row.OwnRole, partnerRole), nil
}

func (s *Service) CreateInvite(ctx context.Context, userID uuid.UUID) (Invite, error) {
	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return Invite{}, fmt.Errorf("begin invite creation: %w", err)
	}
	defer rollback(ctx, tx)
	queries := s.queries.WithTx(tx)

	membership, err := queries.GetMembershipByUser(ctx, userID)
	if errors.Is(err, pgx.ErrNoRows) {
		return Invite{}, ErrFamilyRequired
	}
	if err != nil {
		return Invite{}, fmt.Errorf("get invite membership: %w", err)
	}
	if _, err := queries.LockFamily(ctx, membership.FamilyID); err != nil {
		return Invite{}, fmt.Errorf("lock invite family: %w", err)
	}
	memberCount, err := queries.CountFamilyMembers(ctx, membership.FamilyID)
	if err != nil {
		return Invite{}, fmt.Errorf("count invite family: %w", err)
	}
	if memberCount >= 2 {
		return Invite{}, ErrFamilyAlreadyFull
	}
	if err := queries.RevokeActiveInvitesByUser(ctx, userID); err != nil {
		return Invite{}, fmt.Errorf("revoke prior invites: %w", err)
	}

	expiresAt := s.now().UTC().Add(24 * time.Hour)
	for range 5 {
		code, err := newInviteCode()
		if err != nil {
			return Invite{}, fmt.Errorf("generate invite code: %w", err)
		}
		savepoint, err := tx.Begin(ctx)
		if err != nil {
			return Invite{}, fmt.Errorf("begin invite savepoint: %w", err)
		}
		_, insertErr := postgresgen.New(savepoint).CreatePartnerInvite(ctx, postgresgen.CreatePartnerInviteParams{
			ID:            uuid.New(),
			FamilyID:      membership.FamilyID,
			InviterUserID: userID,
			CodeDigest:    digestInviteCode(s.inviteSecret, code),
			ExpiresAt:     pgtype.Timestamptz{Time: expiresAt, Valid: true},
		})
		if insertErr == nil {
			if err := savepoint.Commit(ctx); err != nil {
				return Invite{}, fmt.Errorf("commit invite savepoint: %w", err)
			}
			if err := tx.Commit(ctx); err != nil {
				return Invite{}, fmt.Errorf("commit invite creation: %w", err)
			}
			return Invite{Code: code, ExpiresAt: expiresAt}, nil
		}
		_ = savepoint.Rollback(ctx)
		if !isUniqueViolation(insertErr) {
			return Invite{}, fmt.Errorf("create invite: %w", insertErr)
		}
	}
	return Invite{}, errors.New("could not generate a unique invite code")
}

func (s *Service) RedeemInvite(ctx context.Context, userID uuid.UUID, rawCode, rawRole string) (Summary, error) {
	role, err := parseRole(rawRole)
	if err != nil {
		return Summary{}, err
	}
	code, valid := normalizeInviteCode(rawCode)
	if !valid {
		return Summary{}, ErrInviteInvalid
	}

	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return Summary{}, fmt.Errorf("begin invite redemption: %w", err)
	}
	defer rollback(ctx, tx)
	queries := s.queries.WithTx(tx)

	invite, err := queries.GetPartnerInviteForUpdate(ctx, digestInviteCode(s.inviteSecret, code))
	if errors.Is(err, pgx.ErrNoRows) {
		return Summary{}, ErrInviteInvalid
	}
	if err != nil {
		return Summary{}, fmt.Errorf("lock invite: %w", err)
	}
	if invite.RevokedAt.Valid {
		return Summary{}, ErrInviteInvalid
	}
	if invite.RedeemedAt.Valid {
		return Summary{}, ErrInviteAlreadyUsed
	}
	now := s.now().UTC()
	if !invite.ExpiresAt.Valid || !now.Before(invite.ExpiresAt.Time) {
		return Summary{}, ErrInviteExpired
	}
	if invite.InviterUserID == userID {
		return Summary{}, ErrSelfLinkNotAllowed
	}

	if _, err := queries.LockUserForOnboarding(ctx, userID); err != nil {
		return Summary{}, fmt.Errorf("lock invite redeemer: %w", err)
	}
	if _, err := queries.GetMembershipByUser(ctx, userID); err == nil {
		return Summary{}, ErrAlreadyInFamily
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return Summary{}, fmt.Errorf("check redeemer family: %w", err)
	}
	if _, err := queries.LockFamily(ctx, invite.FamilyID); err != nil {
		return Summary{}, fmt.Errorf("lock target family: %w", err)
	}
	memberCount, err := queries.CountFamilyMembers(ctx, invite.FamilyID)
	if err != nil {
		return Summary{}, fmt.Errorf("count target family: %w", err)
	}
	if memberCount >= 2 {
		return Summary{}, ErrFamilyAlreadyFull
	}
	roleTaken, err := queries.RoleExistsInFamily(ctx, postgresgen.RoleExistsInFamilyParams{FamilyID: invite.FamilyID, Role: role})
	if err != nil {
		return Summary{}, fmt.Errorf("check target role: %w", err)
	}
	if roleTaken {
		return Summary{}, ErrRoleTaken
	}
	if _, err := queries.CreateFamilyMember(ctx, postgresgen.CreateFamilyMemberParams{
		FamilyID: invite.FamilyID,
		UserID:   userID,
		Role:     role,
	}); err != nil {
		if isUniqueViolation(err) {
			return Summary{}, ErrAlreadyInFamily
		}
		return Summary{}, fmt.Errorf("create invited member: %w", err)
	}
	rows, err := queries.RedeemPartnerInvite(ctx, postgresgen.RedeemPartnerInviteParams{
		ID:         invite.ID,
		RedeemedBy: pgtype.UUID{Bytes: userID, Valid: true},
		RedeemedAt: pgtype.Timestamptz{Time: now, Valid: true},
	})
	if err != nil {
		return Summary{}, fmt.Errorf("mark invite redeemed: %w", err)
	}
	if rows != 1 {
		return Summary{}, ErrInviteAlreadyUsed
	}
	if err := tx.Commit(ctx); err != nil {
		return Summary{}, fmt.Errorf("commit invite redemption: %w", err)
	}
	return s.Get(ctx, userID)
}

func summary(familyID, childID uuid.UUID, childName string, dateOfBirth time.Time, ownRole postgresgen.ParentRole, partnerRole *postgresgen.ParentRole) Summary {
	var partner *string
	status := "waiting_for_partner"
	if partnerRole != nil {
		value := string(*partnerRole)
		partner = &value
		status = "linked"
	}
	return Summary{
		ID: familyID,
		Child: Child{
			ID:          childID,
			Name:        childName,
			DateOfBirth: dateOfBirth.Format("2006-01-02"),
		},
		OwnRole:     string(ownRole),
		PartnerRole: partner,
		Status:      status,
	}
}

func rollback(ctx context.Context, tx pgx.Tx) {
	_ = tx.Rollback(ctx)
}

func isUniqueViolation(err error) bool {
	var postgresError *pgconn.PgError
	return errors.As(err, &postgresError) && postgresError.Code == "23505"
}
