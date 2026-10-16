class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.fields = const {},
    this.requestId,
    this.statusCode,
  });

  final String code;
  final String message;
  final Map<String, dynamic> fields;
  final String? requestId;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

class UserModel {
  const UserModel({required this.id, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'] as String, email: json['email'] as String);

  final String id;
  final String email;
}

class ChildModel {
  const ChildModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) => ChildModel(
    id: json['id'] as String,
    name: json['name'] as String,
    dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  );

  final String id;
  final String name;
  final DateTime dateOfBirth;
}

class FamilyModel {
  const FamilyModel({
    required this.id,
    required this.child,
    required this.ownRole,
    required this.status,
    this.partnerRole,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) => FamilyModel(
    id: json['id'] as String,
    child: ChildModel.fromJson(json['child'] as Map<String, dynamic>),
    ownRole: json['ownRole'] as String,
    partnerRole: json['partnerRole'] as String?,
    status: json['status'] as String,
  );

  final String id;
  final ChildModel child;
  final String ownRole;
  final String? partnerRole;
  final String status;
}

class SessionModel {
  const SessionModel({
    required this.user,
    required this.onboardingState,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    onboardingState: json['onboardingState'] as String,
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    accessTokenExpiresAt: DateTime.parse(
      json['accessTokenExpiresAt'] as String,
    ),
    refreshTokenExpiresAt: DateTime.parse(
      json['refreshTokenExpiresAt'] as String,
    ),
  );

  final UserModel user;
  final String onboardingState;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
}

class MeModel {
  const MeModel({
    required this.id,
    required this.email,
    required this.onboardingState,
    this.family,
  });

  factory MeModel.fromJson(Map<String, dynamic> json) => MeModel(
    id: json['id'] as String,
    email: json['email'] as String,
    onboardingState: json['onboardingState'] as String,
    family: json['family'] == null
        ? null
        : FamilyModel.fromJson(json['family'] as Map<String, dynamic>),
  );

  final String id;
  final String email;
  final String onboardingState;
  final FamilyModel? family;
}

class InviteModel {
  const InviteModel({required this.code, required this.expiresAt});

  factory InviteModel.fromJson(Map<String, dynamic> json) => InviteModel(
    code: json['code'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );

  final String code;
  final DateTime expiresAt;
}
