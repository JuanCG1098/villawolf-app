import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_controller.dart';
import '../ui/widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'admin@villawolf.local');
  final _password = TextEditingController(text: r'Admin123$');
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    await ref.read(authControllerProvider.notifier).login(_email.text.trim(), _password.text);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final error = ref.watch(authControllerProvider).error;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SurfaceCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BrandMark()),
                  const SizedBox(height: 28),
                  Text('Iniciar sesión',
                      style: TextStyle(color: t.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _password,
                    label: 'Contraseña',
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error, style: TextStyle(color: t.dangerFg, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Entrar',
                    expand: true,
                    loading: _busy,
                    onPressed: _busy ? null : _submit,
                  ),
                  const SizedBox(height: 12),
                  Text(r'admin@villawolf.local · Admin123$',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.textMuted, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
