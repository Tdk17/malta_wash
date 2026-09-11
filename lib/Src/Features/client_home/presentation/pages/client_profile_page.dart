import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final _repository = sl<ResourceRepository>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repository.get(Endpoints.profile);
      _name.text = _pick(data, const ['name', 'fullName', 'customerName']);
      _email.text = _pick(data, const ['email']);
      _phone.text = _pick(data, const ['phone', 'mobile', 'whatsapp']);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _repository.patch(Endpoints.profile, {
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _pick(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value is! Map && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(mobile ? 16 : 28, 24, mobile ? 16 : 28, 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0B0F14), Color(0xFF151B24), Color(0xFF1E293B)]),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('MALTA WASH', style: TextStyle(color: Color(0xFFFF9B54), fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                    SizedBox(height: 10),
                    Text('Meu perfil', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    SizedBox(height: 6),
                    Text('Mantenha apenas seus dados essenciais atualizados.', style: TextStyle(color: Color(0xFF94A3B8))),
                  ])),
                  Icon(Icons.person_rounded, color: Color(0xFFFF8A34), size: 34),
                ]),
              ),
              const SizedBox(height: 18),
              if (_loading)
                const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                _state(_error!)
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.96),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(children: [
                    _field(_name, 'Nome', Icons.person_outline_rounded),
                    const SizedBox(height: 12),
                    _field(_email, 'E-mail', Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _field(_phone, 'Telefone / WhatsApp', Icons.phone_outlined, keyboard: TextInputType.phone),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_rounded),
                        label: const Text('Salvar perfil'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6A00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType? keyboard}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
    );
  }

  Widget _state(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB42318), size: 34),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: const Text('Tentar novamente')),
        ]),
      );
}
