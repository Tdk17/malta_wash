import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/login_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';
import 'package:signals/signals_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late final LoginController controller = sl();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: formKey,
                    child: Column(children: [
                      const BrandLogo(size: 96),
                      const SizedBox(height: 18),
                      Text('Acessar Clinicar', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      const Text('powered by Malta Wash'),
                      const SizedBox(height: 26),
                      TextFormField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail'), validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido.' : null),
                      const SizedBox(height: 14),
                      TextFormField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha'), validator: (v) => (v == null || v.length < 6) ? 'Informe sua senha.' : null),
                      const SizedBox(height: 10),
                      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.go(RoutePaths.resetPassword), child: const Text('Esqueci minha senha'))),
                      Watch((_) => controller.errorMessage.value == null ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(controller.errorMessage.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)))),
                      SizedBox(width: double.infinity, child: Watch((_) => ElevatedButton(onPressed: controller.isLoading.value ? null : _submit, child: controller.isLoading.value ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Entrar')))),
                      const SizedBox(height: 14),
                      TextButton(onPressed: () => context.go(RoutePaths.register), child: const Text('Ainda não tenho conta')),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    final session = await controller.submit(email.text, password.text);
    if (!mounted || session == null) return;
    final role = (session.role ?? '').toUpperCase();
    if (role.contains('SUPER')) {
      context.go(RoutePaths.superAdmin);
    } else if (role.contains('ADMIN') || role.contains('MANAGER') || role.contains('GERENTE') || role.contains('ATENDENTE') || role.contains('TECH') || role.contains('LAVADOR')) {
      context.go(RoutePaths.admin);
    } else {
      context.go(RoutePaths.client);
    }
  }
}
