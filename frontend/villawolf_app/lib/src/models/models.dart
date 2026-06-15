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

class PaymentModel {
  PaymentModel({
    required this.id,
    required this.amount,
    required this.method,
    required this.type,
    required this.createdAtUtc,
    this.notes,
  });

  final String id;
  final num amount;
  final String method;
  final String type;
  final DateTime createdAtUtc;
  final String? notes;

  factory PaymentModel.fromJson(Map<String, dynamic> j) => PaymentModel(
        id: j['id'] as String,
        amount: (j['amount'] ?? 0) as num,
        method: (j['method'] ?? '') as String,
        type: (j['type'] ?? '') as String,
        createdAtUtc: DateTime.parse(j['createdAtUtc'] as String),
        notes: j['notes'] as String?,
      );
}

class MethodTotalModel {
  MethodTotalModel({required this.method, required this.total, required this.count});

  final String method;
  final num total;
  final int count;

  factory MethodTotalModel.fromJson(Map<String, dynamic> j) => MethodTotalModel(
        method: (j['method'] ?? '') as String,
        total: (j['total'] ?? 0) as num,
        count: (j['count'] ?? 0) as int,
      );
}

class CashboxSummaryModel {
  CashboxSummaryModel({required this.total, required this.count, required this.byMethod});

  final num total;
  final int count;
  final List<MethodTotalModel> byMethod;

  factory CashboxSummaryModel.fromJson(Map<String, dynamic> j) => CashboxSummaryModel(
        total: (j['total'] ?? 0) as num,
        count: (j['count'] ?? 0) as int,
        byMethod: ((j['byMethod'] ?? []) as List)
            .map((e) => MethodTotalModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}

class ProductModel {
  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minStock,
    required this.isLowStock,
    required this.isActive,
    this.salePrice,
  });

  final String id;
  final String name;
  final String category;
  final int currentStock;
  final int minStock;
  final bool isLowStock;
  final bool isActive;
  final num? salePrice;

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        id: j['id'] as String,
        name: (j['name'] ?? '') as String,
        category: (j['category'] ?? '') as String,
        currentStock: (j['currentStock'] ?? 0) as int,
        minStock: (j['minStock'] ?? 0) as int,
        isLowStock: (j['isLowStock'] ?? false) as bool,
        isActive: (j['isActive'] ?? true) as bool,
        salePrice: j['salePrice'] as num?,
      );
}

class CameraModel {
  CameraModel({
    required this.id,
    required this.name,
    required this.location,
    required this.powerType,
    required this.status,
    required this.isLowBattery,
    this.batteryLevel,
  });

  final String id;
  final String name;
  final String location;
  final String powerType;
  final String status;
  final bool isLowBattery;
  final int? batteryLevel;

  factory CameraModel.fromJson(Map<String, dynamic> j) => CameraModel(
        id: j['id'] as String,
        name: (j['name'] ?? '') as String,
        location: (j['location'] ?? '') as String,
        powerType: (j['powerType'] ?? '') as String,
        status: (j['status'] ?? '') as String,
        isLowBattery: (j['isLowBattery'] ?? false) as bool,
        batteryLevel: j['batteryLevel'] as int?,
      );
}
