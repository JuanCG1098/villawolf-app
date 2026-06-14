// Plain data models mirroring the API DTOs (enum-like fields kept as raw strings).

class AuthUser {
  AuthUser({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.expiresAtUtc,
  });

  final String userId;
  final String displayName;
  final String email;
  final String role;
  final String accessToken;
  final DateTime expiresAtUtc;

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        userId: j['userId'] as String,
        displayName: (j['displayName'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        role: (j['role'] ?? '') as String,
        accessToken: (j['accessToken'] ?? '') as String,
        expiresAtUtc: DateTime.parse(j['expiresAtUtc'] as String),
      );
}

class EmployeeModel {
  EmployeeModel({required this.id, required this.fullName, required this.colorHex, required this.isActive});

  final String id;
  final String fullName;
  final String colorHex;
  final bool isActive;

  factory EmployeeModel.fromJson(Map<String, dynamic> j) => EmployeeModel(
        id: j['id'] as String,
        fullName: (j['fullName'] ?? '') as String,
        colorHex: (j['colorHex'] ?? '#C8A24B') as String,
        isActive: (j['isActive'] ?? true) as bool,
      );
}

class ServiceModel {
  ServiceModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.basePrice,
    required this.targetAudience,
    required this.categoryName,
    required this.isActive,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final num basePrice;
  final String targetAudience;
  final String categoryName;
  final bool isActive;

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
        id: j['id'] as String,
        name: (j['name'] ?? '') as String,
        durationMinutes: (j['durationMinutes'] ?? 0) as int,
        basePrice: (j['basePrice'] ?? 0) as num,
        targetAudience: (j['targetAudience'] ?? 'Unisex') as String,
        categoryName: (j['categoryName'] ?? '') as String,
        isActive: (j['isActive'] ?? true) as bool,
      );
}

class AppointmentModel {
  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.employeeId,
    required this.serviceName,
    required this.startUtc,
    required this.endUtc,
    required this.totalPrice,
    required this.status,
  });

  final String id;
  final String clientId;
  final String employeeId;
  final String serviceName;
  final DateTime startUtc;
  final DateTime endUtc;
  final num totalPrice;
  final String status;

  factory AppointmentModel.fromJson(Map<String, dynamic> j) => AppointmentModel(
        id: j['id'] as String,
        clientId: (j['clientId'] ?? '') as String,
        employeeId: (j['employeeId'] ?? '') as String,
        serviceName: (j['serviceName'] ?? '') as String,
        startUtc: DateTime.parse(j['startUtc'] as String),
        endUtc: DateTime.parse(j['endUtc'] as String),
        totalPrice: (j['totalPrice'] ?? 0) as num,
        status: (j['status'] ?? 'Pending') as String,
      );
}

class FreeSlotModel {
  FreeSlotModel({required this.startUtc, required this.localStart, required this.localEnd});

  final DateTime startUtc;
  final String localStart;
  final String localEnd;

  factory FreeSlotModel.fromJson(Map<String, dynamic> j) => FreeSlotModel(
        startUtc: DateTime.parse(j['startUtc'] as String),
        localStart: (j['localStart'] ?? '') as String,
        localEnd: (j['localEnd'] ?? '') as String,
      );
}
