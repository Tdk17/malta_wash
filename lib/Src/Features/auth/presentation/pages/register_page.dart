import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/register_controller.dart';
import 'package:malta_wash/Src/Shared/layouts/auth_layout.dart';
import 'package:signals/signals_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.tenantSlug});

  final String? tenantSlug;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool accepted = false;
  bool obscurePassword = true;
  late final RegisterController controller = sl();

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      eyebrow: 'Cadastro de cliente',
      title: 'Sua próxima lavagem começa antes de você chegar.',
      description: 'Crie sua conta para cadastrar seu veículo, agendar uma lavagem e acompanhar o atendimento.',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crie sua conta',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28, letterSpacing: -.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastro de cliente Malta Wash.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7B8492)),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.person_outline_rounded)),
              validator: (v) => (v == null || v.trim().length < 3) ? 'Informe seu nome completo.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(labelText: 'Telefone / WhatsApp', hintText: '(47) 99999-9999', prefixIcon: Icon(Icons.phone_outlined)),
              validator: (v) => (v == null || v.replaceAll(RegExp(r'\D'), '').length < 10) ? 'Informe um telefone válido.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'E-mail', hintText: 'voce@email.com', prefixIcon: Icon(Icons.mail_outline_rounded)),
              validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: password,
              obscureText: obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Crie uma senha',
                helperText: 'Use pelo menos 8 caracteres.',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              validator: (v) => (v == null || v.length < 8) ? 'A senha precisa ter pelo menos 8 caracteres.' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => accepted = !accepted),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accepted ? const Color(0xFFFFB27C) : const Color(0xFFE8EBF0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: accepted,
                        onChanged: (value) => setState(() => accepted = value ?? false),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Text(
                        'Li e aceito os Termos de Uso e a Política de Privacidade.',
                        style: TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF4B5563)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Watch(
              (_) => controller.errorMessage.value == null
                  ? const SizedBox.shrink()
                  : Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer.withOpacity(.35), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(controller.errorMessage.value!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.5, height: 1.35))),
                        ],
                      ),
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: Watch(
                (_) => ElevatedButton.icon(
                  onPressed: controller.isLoading.value ? null : _submit,
                  icon: controller.isLoading.value
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Criar minha conta'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('já possui cadastro?', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF8A93A1))),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('${RoutePaths.login}?area=cliente'),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Entrar na minha conta'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('${RoutePaths.login}?area=empresa'),
                icon: const Icon(Icons.storefront_outlined, size: 18),
                label: const Text('Acessar área da empresa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa aceitar os termos para continuar.')),
      );
      return;
    }

    final session = await controller.submit(
      name: name.text,
      phone: phone.text,
      email: email.text,
      password: password.text,
      tenantSlug: widget.tenantSlug ?? 'clinicar',
    );
    if (!mounted || session == null) return;
    context.go(session.token.isNotEmpty ? RoutePaths.client : '${RoutePaths.login}?area=cliente');
  }
}
