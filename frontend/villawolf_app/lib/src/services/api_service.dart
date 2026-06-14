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

  Future<List<ServiceModel>> listServices() async {
    final res = await _dio.get('/api/services');
    return _list(res.data, ServiceModel.fromJson);
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

  static List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) =>
      (data as List).map((e) => fromJson((e as Map).cast<String, dynamic>())).toList();

  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
