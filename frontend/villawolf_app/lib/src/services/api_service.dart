import 'package:dio/dio.dart';

import '../models/models.dart';

/// Typed wrapper over the VILLAWOLF REST API.
class ApiService {
  ApiService(this._dio);

  final Dio _dio;

  Future<AuthUser> login(String email, String password) async {
    final res = await _dio.post('/api/auth/login', data: {'email': email, 'password': password});
    return AuthUser.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/api/auth/me');
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<List<EmployeeModel>> listEmployees() async {
    final res = await _dio.get('/api/employees');
    return _list(res.data, EmployeeModel.fromJson);
  }

  Future<List<ServiceModel>> listServices({bool includeInactive = false}) async {
    final res = await _dio.get('/api/services', queryParameters: {
      if (includeInactive) 'includeInactive': true,
    });
    return _list(res.data, ServiceModel.fromJson);
  }

  Future<List<CategoryModel>> listCategories() async {
    final res = await _dio.get('/api/service-categories');
    return _list(res.data, CategoryModel.fromJson);
  }

  Future<ServiceModel> createService(Map<String, dynamic> body) async {
    final res = await _dio.post('/api/services', data: body);
    return ServiceModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<ServiceModel> updateService(String id, Map<String, dynamic> body) async {
    final res = await _dio.put('/api/services/$id', data: body);
    return ServiceModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<void> setServiceActive(String id, bool active) async {
    await _dio.patch('/api/services/$id/${active ? 'activate' : 'deactivate'}');
  }

  Future<EmployeeModel> createEmployee(Map<String, dynamic> body) async {
    final res = await _dio.post('/api/employees', data: body);
    return EmployeeModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<void> setEmployeeActive(String id, bool active) async {
    await _dio.patch('/api/employees/$id/${active ? 'activate' : 'deactivate'}');
  }

  Future<List<EmployeeModel>> listEmployeesAll({bool includeInactive = true}) async {
    final res = await _dio.get('/api/employees', queryParameters: {
      if (includeInactive) 'includeInactive': true,
    });
    return _list(res.data, EmployeeModel.fromJson);
  }

  Future<List<AppointmentModel>> listAppointments({
    DateTime? fromUtc,
    DateTime? toUtc,
    String? employeeId,
    String? status,
  }) async {
    final res = await _dio.get('/api/appointments', queryParameters: {
      if (fromUtc != null) 'fromUtc': fromUtc.toUtc().toIso8601String(),
      if (toUtc != null) 'toUtc': toUtc.toUtc().toIso8601String(),
      if (employeeId != null) 'employeeId': employeeId,
      if (status != null) 'status': status,
    });
    return _list(res.data, AppointmentModel.fromJson);
  }

  Future<List<FreeSlotModel>> freeSlots({
    required String employeeId,
    required DateTime date,
    String? serviceId,
  }) async {
    final res = await _dio.get('/api/schedule/free-slots', queryParameters: {
      'employeeId': employeeId,
      'date': _dateOnly(date),
      if (serviceId != null) 'serviceId': serviceId,
    });
    return _list(res.data, FreeSlotModel.fromJson);
  }

  Future<List<ClientModel>> listClients({String? search, bool includeInactive = false}) async {
    final res = await _dio.get('/api/clients', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (includeInactive) 'includeInactive': true,
    });
    return _list(res.data, ClientModel.fromJson);
  }

  Future<ClientModel> createClient(Map<String, dynamic> body) async {
    final res = await _dio.post('/api/clients', data: body);
    return ClientModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<ClientModel> updateClient(String id, Map<String, dynamic> body) async {
    final res = await _dio.put('/api/clients/$id', data: body);
    return ClientModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<AppointmentModel> createAppointment(Map<String, dynamic> body) async {
    final res = await _dio.post('/api/appointments', data: body);
    return AppointmentModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<AppointmentDetailModel> getAppointment(String id) async {
    final res = await _dio.get('/api/appointments/$id');
    return AppointmentDetailModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Runs a status transition: action is one of confirm/start/complete/cancel/no-show.
  Future<AppointmentDetailModel> appointmentAction(String id, String action) async {
    final res = await _dio.post('/api/appointments/$id/$action');
    return AppointmentDetailModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<ClientModel> getClient(String id) async {
    final res = await _dio.get('/api/clients/$id');
    return ClientModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<DashboardSummaryModel> dashboardSummary() async {
    final res = await _dio.get('/api/dashboard/summary');
    return DashboardSummaryModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<CashboxSummaryModel> cashboxSummary({DateTime? date}) async {
    final res = await _dio.get('/api/payments/summary', queryParameters: {
      if (date != null) 'date': _dateOnly(date),
    });
    return CashboxSummaryModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<List<PaymentModel>> listPayments({DateTime? fromUtc, DateTime? toUtc}) async {
    final res = await _dio.get('/api/payments', queryParameters: {
      if (fromUtc != null) 'fromUtc': fromUtc.toUtc().toIso8601String(),
      if (toUtc != null) 'toUtc': toUtc.toUtc().toIso8601String(),
    });
    return _list(res.data, PaymentModel.fromJson);
  }

  Future<List<ProductModel>> listProducts({bool lowStockOnly = false}) async {
    final res = await _dio.get('/api/products', queryParameters: {
      if (lowStockOnly) 'lowStockOnly': true,
    });
    return _list(res.data, ProductModel.fromJson);
  }

  static List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) =>
      (data as List).map((e) => fromJson((e as Map).cast<String, dynamic>())).toList();

  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
