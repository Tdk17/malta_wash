import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:signals/signals_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final email = TextEditingController();
  late final ForgotPasswordController controller = sl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recuperar senha',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    const Text('Informe seu e-mail para receber as instruções.'),
                    const SizedBox(height: 22),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                    ),
                    const SizedBox(height: 14),
                    Watch(
                      (_) => controller.message.value == null
                          ? const SizedBox.shrink()
                          : Text(
                              controller.message.value!,
                              style: const TextStyle(color: Colors.green),
                            ),
                    ),
                    Watch(
                      (_) => controller.errorMessage.value == null
                          ? const SizedBox.shrink()
                          : Text(
                              controller.errorMessage.value!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: Watch(
                        (_) => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.submit(email.text),
                          child: const Text('Enviar'),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(RoutePaths.login),
                      child: const Text('Voltar ao login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
