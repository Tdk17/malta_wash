import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/login_controller.dart';
import 'package:malta_wash/Src/Shared/layouts/auth_layout.dart';
import 'package:signals/signals_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.initialArea});

  final String? initialArea;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late final LoginController controller = sl();
  late bool companyArea = (widget.initialArea ?? '').toLowerCase() == 'empresa';
  bool obscurePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      eyebrow: companyArea ? 'Área da empresa' : 'Área do cliente',
      title: companyArea
          ? 'A operação da sua lavação em um único painel.'
          : 'Agende, acompanhe e cuide do seu carro com facilidade.',
      description: companyArea
          ? 'Acesse a operação da sua empresa pelo Malta Wash.'
          : 'Entre para agendar, acompanhar seu veículo, consultar seu plano e gerenciar seu perfil.',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              companyArea ? 'Acessar painel da empresa' : 'Bem-vindo de volta',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28, letterSpacing: -.5),
            ),
            const SizedBox(height: 8),
            Text(
              companyArea
                  ? 'Use a conta de administração da empresa.'
                  : 'Use seus dados para acessar sua conta.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7B8492)),
            ),
            const SizedBox(height: 22),
            _AreaSelector(
              companyArea: companyArea,
              onChanged: (value) => setState(() => companyArea = value),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'voce@email.com',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: password,
              obscureText: obscurePassword,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => (v == null || v.length < 6) ? 'Informe sua senha.' : null,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(RoutePaths.resetPassword),
                child: const Text('Esqueci minha senha'),
              ),
            ),
            Watch(
              (_) => controller.errorMessage.value == null
                  ? const SizedBox.shrink()
                  : Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer.withOpacity(.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.5, height: 1.35),
                            ),
                          ),
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
                      : Icon(companyArea ? Icons.dashboard_outlined : Icons.login_rounded),
                  label: Text(companyArea ? 'Entrar no painel' : 'Entrar'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (!companyArea)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8EBF0)),
                ),
                child: Row(
                  children: [
                    const Expanded(child: Text('Ainda não possui conta?', style: TextStyle(fontWeight: FontWeight.w600))),
                    TextButton(
                      onPressed: () => context.go('${RoutePaths.register}?tenant=clinicar'),
                      child: const Text('Criar conta'),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE2CC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.business_center_outlined, color: Color(0xFFFF6A00), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ainda não possui uma empresa cadastrada? Crie a empresa e a conta do administrador primeiro.',
                            style: TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF6B4A33)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go(RoutePaths.companyRegister),
                        icon: const Icon(Icons.add_business_rounded),
                        label: const Text('Cadastrar minha empresa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6A00),
                          side: const BorderSide(color: Color(0xFFFFC49A)),
                          minimumSize: const Size(0, 46),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    final session = await controller.submit(email.text, password.text);
    if (!mounted || session == null) return;

    final role = (session.role ?? '').toUpperCase();
    final isSuper = role.contains('SUPER');
    final isCompany = isSuper ||
        role.contains('ADMIN') ||
        role.contains('MANAGER') ||
        role.contains('GERENTE') ||
        role.contains('ATENDENTE') ||
        role.contains('TECH') ||
        role.contains('LAVADOR');

    if (companyArea && !isCompany) {
      await controller.logoutCurrentSession();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta conta é de cliente. Use a Área do cliente para entrar.')),
      );
      return;
    }

    if (!companyArea && isCompany) {
      context.go(isSuper ? RoutePaths.superAdmin : RoutePaths.admin);
      return;
    }

    if (isSuper) {
      context.go(RoutePaths.superAdmin);
    } else if (isCompany) {
      context.go(RoutePaths.admin);
    } else {
      context.go(RoutePaths.client);
    }
  }
}

class _AreaSelector extends StatelessWidget {
  const _AreaSelector({required this.companyArea, required this.onChanged});

  final bool companyArea;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Expanded(
            child: _AreaButton(
              selected: !companyArea,
              icon: Icons.person_outline_rounded,
              label: 'Cliente',
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _AreaButton(
              selected: companyArea,
              icon: Icons.storefront_outlined,
              label: 'Empresa',
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaButton extends StatelessWidget {
  const _AreaButton({required this.selected, required this.icon, required this.label, required this.onTap});

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected ? const [BoxShadow(color: Color(0x120F172A), blurRadius: 12, offset: Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? const Color(0xFFFF6A00) : const Color(0xFF7B8492)),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: selected ? const Color(0xFF111827) : const Color(0xFF7B8492)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
