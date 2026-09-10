import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Features/auth/presentation/controllers/register_controller.dart';
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';
import 'package:signals/signals_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
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
  late final RegisterController controller = sl();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(child: Padding(padding: const EdgeInsets.all(32), child: Form(key: formKey, child: Column(children: [
                const BrandLogo(size: 82),
                const SizedBox(height: 16),
                Text('Criar conta', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Nome completo'), validator: (v) => (v == null || v.trim().length < 3) ? 'Informe seu nome.' : null),
                const SizedBox(height: 12),
                TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone'), validator: (v) => (v == null || v.trim().length < 8) ? 'Informe seu telefone.' : null),
                const SizedBox(height: 12),
                TextFormField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail'), validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido.' : null),
                const SizedBox(height: 12),
                TextFormField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha'), validator: (v) => (v == null || v.length < 6) ? 'Use pelo menos 6 caracteres.' : null),
                CheckboxListTile(value: accepted, contentPadding: EdgeInsets.zero, onChanged: (v) => setState(() => accepted = v ?? false), title: const Text('Aceito os Termos de Uso e a Política de Privacidade.')),
                Watch((_) => controller.errorMessage.value == null ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(controller.errorMessage.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)))),
                SizedBox(width: double.infinity, child: Watch((_) => ElevatedButton(onPressed: controller.isLoading.value ? null : _submit, child: const Text('Cadastrar')))),
                const SizedBox(height: 12),
                TextButton(onPressed: () => context.go(RoutePaths.login), child: const Text('Já tenho conta')),
              ])))),
            ),
          ),
        ),
      );

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você precisa aceitar os termos para continuar.')));
      return;
    }
    final session = await controller.submit(name: name.text, phone: phone.text, email: email.text, password: password.text);
    if (!mounted || session == null) return;
    context.go(session.token.isNotEmpty ? RoutePaths.client : RoutePaths.login);
  }
}
