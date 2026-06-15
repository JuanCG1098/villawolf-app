import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/appointment_detail_page.dart';
import '../features/calendar_page.dart';
import '../features/cameras_page.dart';
import '../features/cashbox_page.dart';
import '../features/client_form_page.dart';
import '../features/clients_page.dart';
import '../features/create_appointment_page.dart';
import '../features/dashboard_page.dart';
import '../features/employee_form_page.dart';
import '../features/employees_page.dart';
import '../features/inventory_page.dart';
import '../features/login_page.dart';
import '../features/service_form_page.dart';
import '../features/services_page.dart';
import '../models/models.dart';
import '../state/auth_controller.dart';
import '../ui/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authControllerProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final location = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return location == '/splash' ? null : '/splash';
      }
      if (status == AuthStatus.unauthenticated) {
        return location == '/login' ? null : '/login';
      }
      // Authenticated.
      if (location == '/login' || location == '/splash') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/calendar', builder: (_, __) => const CalendarPage()),
          GoRoute(path: '/cashbox', builder: (_, __) => const CashboxPage()),
          GoRoute(path: '/inventory', builder: (_, __) => const InventoryPage()),
          GoRoute(path: '/cameras', builder: (_, __) => const CamerasPage()),
          GoRoute(path: '/clients', builder: (_, __) => const ClientsPage()),
          GoRoute(path: '/services', builder: (_, __) => const ServicesPage()),
          GoRoute(path: '/employees', builder: (_, __) => const EmployeesPage()),
        ],
      ),
      // Full-screen forms (own AppBar, outside the shell).
      GoRoute(path: '/clients/new', builder: (_, __) => const ClientFormPage()),
      GoRoute(
        path: '/clients/edit/:id',
        builder: (_, state) => ClientFormPage(client: state.extra as ClientModel?),
      ),
      GoRoute(path: '/appointments/new', builder: (_, __) => const CreateAppointmentPage()),
      GoRoute(
        path: '/appointments/:id',
        builder: (_, state) => AppointmentDetailPage(appointmentId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/services/new', builder: (_, __) => const ServiceFormPage()),
      GoRoute(
        path: '/services/edit/:id',
        builder: (_, state) => ServiceFormPage(service: state.extra as ServiceModel?),
      ),
      GoRoute(path: '/employees/new', builder: (_, __) => const EmployeeFormPage()),
    ],
  );
});

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
