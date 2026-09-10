import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/company_register_controller.dart';
import 'package:malta_wash/Src/Shared/layouts/auth_layout.dart';
import 'package:signals/signals_flutter.dart';

class CompanyRegisterPage extends StatefulWidget {
  const CompanyRegisterPage({super.key});

  @override
  State<CompanyRegisterPage> createState() => _CompanyRegisterPageState();
}

class _CompanyRegisterPageState extends State<CompanyRegisterPage> {
  final formKey = GlobalKey<FormState>();
  final companyName = TextEditingController();
  final ownerName = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  late final CompanyRegisterController controller = sl();
  bool accepted = false;
  bool obscurePassword = true;
  bool obscureConfirmation = true;

  @override
  void dispose() {
    companyName.dispose();
    ownerName.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      eyebrow: 'Cadastro da empresa',
      title: 'Comece com a sua empresa e entre direto no painel de gestão.',
      description:
          'Crie a empresa e a conta do administrador no mesmo fluxo. Depois do cadastro, você entra com acesso ao dashboard, agenda, clientes, equipe e operação.',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cadastrar empresa',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 28, letterSpacing: -.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Primeiro criamos a empresa. Você será cadastrado como administrador principal.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: const Color(0xFF7B8492)),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: companyName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome da empresa',
                hintText: 'Ex.: Clinicar Estética Automotiva',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Informe o nome da empresa.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: ownerName,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Nome do responsável',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Informe o nome do responsável.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                labelText: 'Telefone / WhatsApp',
                hintText: '(47) 99999-9999',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  (v == null || v.replaceAll(RegExp(r'\D'), '').length < 10)
                      ? 'Informe um telefone válido.'
                      : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'E-mail do administrador',
                hintText: 'admin@suaempresa.com.br',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Informe um e-mail válido.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: password,
              obscureText: obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Senha',
                helperText: 'Use pelo menos 8 caracteres.',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
                  icon: Icon(obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
              validator: (v) => (v == null || v.length < 8)
                  ? 'A senha precisa ter pelo menos 8 caracteres.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: confirmPassword,
              obscureText: obscureConfirmation,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Confirmar senha',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  tooltip: obscureConfirmation
                      ? 'Mostrar confirmação'
                      : 'Ocultar confirmação',
                  onPressed: () => setState(
                      () => obscureConfirmation = !obscureConfirmation),
                  icon: Icon(obscureConfirmation
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
              validator: (v) => v != password.text
                  ? 'As senhas não conferem.'
                  : null,
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
                  border: Border.all(
                    color: accepted
                        ? const Color(0xFFFFB27C)
                        : const Color(0xFFE8EBF0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: accepted,
                      onChanged: (value) =>
                          setState(() => accepted = value ?? false),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 9),
                        child: Text(
                          'Aceito os Termos de Uso e a Política de Privacidade da plataforma.',
                          style: TextStyle(fontSize: 12.5, height: 1.4),
                        ),
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
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .errorContainer
                            .withOpacity(.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
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
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.storefront_rounded),
                  label: const Text('Criar empresa e entrar'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Já cadastrou a empresa?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.go('${RoutePaths.login}?area=empresa'),
                  child: const Text('Entrar'),
                ),
              ],
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
        const SnackBar(
          content: Text('Aceite os termos para continuar.'),
        ),
      );
      return;
    }

    final session = await controller.submit(
      companyName: companyName.text,
      ownerName: ownerName.text,
      phone: phone.text,
      email: email.text,
      password: password.text,
    );

    if (!mounted || session == null) return;
    context.go(RoutePaths.admin);
  }
}
