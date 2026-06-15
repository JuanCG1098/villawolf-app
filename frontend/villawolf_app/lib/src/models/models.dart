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

class CategoryModel {
  CategoryModel({required this.id, required this.name});
  final String id;
  final String name;
  factory CategoryModel.fromJson(Map<String, dynamic> j) =>
      CategoryModel(id: j['id'] as String, name: (j['name'] ?? '') as String);
}

class ServiceModel {
  ServiceModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.basePrice,
    required this.targetAudience,
    required this.categoryId,
    required this.categoryName,
    required this.requiresPreparation,
    required this.allowsAddons,
    required this.isActive,
    this.description,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final num basePrice;
  final String targetAudience;
  final String categoryId;
  final String categoryName;
  final bool requiresPreparation;
  final bool allowsAddons;
  final bool isActive;
  final String? description;

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
        id: j['id'] as String,
        name: (j['name'] ?? '') as String,
        durationMinutes: (j['durationMinutes'] ?? 0) as int,
        basePrice: (j['basePrice'] ?? 0) as num,
        targetAudience: (j['targetAudience'] ?? 'Unisex') as String,
        categoryId: (j['categoryId'] ?? '') as String,
        categoryName: (j['categoryName'] ?? '') as String,
        requiresPreparation: (j['requiresPreparation'] ?? false) as bool,
        allowsAddons: (j['allowsAddons'] ?? true) as bool,
        isActive: (j['isActive'] ?? true) as bool,
        description: j['description'] as String?,
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

class AppointmentAddonModel {
  AppointmentAddonModel({required this.name, required this.price, required this.durationMinutes});

  final String name;
  final num price;
  final int durationMinutes;

  factory AppointmentAddonModel.fromJson(Map<String, dynamic> j) => AppointmentAddonModel(
        name: (j['name'] ?? '') as String,
        price: (j['price'] ?? 0) as num,
        durationMinutes: (j['durationMinutes'] ?? 0) as int,
      );
}

class AppointmentDetailModel {
  AppointmentDetailModel({
    required this.id,
    required this.clientId,
    required this.employeeId,
    required this.serviceName,
    required this.startUtc,
    required this.endUtc,
    required this.totalDurationMinutes,
    required this.totalPrice,
    required this.status,
    required this.bookingChannel,
    required this.addons,
    this.internalNotes,
  });

  final String id;
  final String clientId;
  final String employeeId;
  final String serviceName;
  final DateTime startUtc;
  final DateTime endUtc;
  final int totalDurationMinutes;
  final num totalPrice;
  final String status;
  final String bookingChannel;
  final List<AppointmentAddonModel> addons;
  final String? internalNotes;

  factory AppointmentDetailModel.fromJson(Map<String, dynamic> j) => AppointmentDetailModel(
        id: j['id'] as String,
        clientId: (j['clientId'] ?? '') as String,
        employeeId: (j['employeeId'] ?? '') as String,
        serviceName: (j['serviceName'] ?? '') as String,
        startUtc: DateTime.parse(j['startUtc'] as String),
        endUtc: DateTime.parse(j['endUtc'] as String),
        totalDurationMinutes: (j['totalDurationMinutes'] ?? 0) as int,
        totalPrice: (j['totalPrice'] ?? 0) as num,
        status: (j['status'] ?? 'Pending') as String,
        bookingChannel: (j['bookingChannel'] ?? '') as String,
        internalNotes: j['internalNotes'] as String?,
        addons: ((j['addons'] ?? []) as List)
            .map((e) => AppointmentAddonModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
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

class DashboardSummaryModel {
  DashboardSummaryModel({
    required this.appointmentsToday,
    required this.confirmed,
    required this.pending,
    required this.completed,
    required this.revenueToday,
    required this.activeClients,
    required this.activeEmployees,
    required this.activeServices,
    required this.lowStockProducts,
    required this.camerasNeedingAttention,
  });

  final int appointmentsToday;
  final int confirmed;
  final int pending;
  final int completed;
  final num revenueToday;
  final int activeClients;
  final int activeEmployees;
  final int activeServices;
  final int lowStockProducts;
  final int camerasNeedingAttention;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> j) => DashboardSummaryModel(
        appointmentsToday: (j['appointmentsToday'] ?? 0) as int,
        confirmed: (j['confirmed'] ?? 0) as int,
        pending: (j['pending'] ?? 0) as int,
        completed: (j['completed'] ?? 0) as int,
        revenueToday: (j['revenueToday'] ?? 0) as num,
        activeClients: (j['activeClients'] ?? 0) as int,
        activeEmployees: (j['activeEmployees'] ?? 0) as int,
        activeServices: (j['activeServices'] ?? 0) as int,
        lowStockProducts: (j['lowStockProducts'] ?? 0) as int,
        camerasNeedingAttention: (j['camerasNeedingAttention'] ?? 0) as int,
      );
}

class ClientModel {
  ClientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.isActive,
    this.phone,
    this.email,
    this.notes,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final bool isActive;
  final String? phone;
  final String? email;
  final String? notes;

  factory ClientModel.fromJson(Map<String, dynamic> j) => ClientModel(
        id: j['id'] as String,
        firstName: (j['firstName'] ?? '') as String,
        lastName: (j['lastName'] ?? '') as String,
        fullName: (j['fullName'] ?? '') as String,
        isActive: (j['isActive'] ?? true) as bool,
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        notes: j['notes'] as String?,
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
