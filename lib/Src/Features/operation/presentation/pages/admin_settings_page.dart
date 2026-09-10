import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _repository = sl<ResourceRepository>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _opening = TextEditingController();
  final _closing = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose(); _opening.dispose(); _closing.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repository.get(Endpoints.settings);
      _name.text = _pick(data, ['companyName','name','businessName']);
      _email.text = _pick(data, ['email','contactEmail']);
      _phone.text = _pick(data, ['phone','contactPhone','whatsapp']);
      _opening.text = _pick(data, ['openingTime','opensAt']);
      _closing.text = _pick(data, ['closingTime','closesAt']);
    } catch (e) { _error = e.toString(); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _repository.patch(Endpoints.settings, {
        'companyName': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'openingTime': _opening.text.trim(),
        'closingTime': _closing.text.trim(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações atualizadas.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  String _pick(Map<String,dynamic> data, List<String> keys) {
    for (final key in keys) { final value = data[key]; if (value != null && value is! Map && value.toString().trim().isNotEmpty) return value.toString(); }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFEFF6FF)])),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF111827)]), borderRadius: BorderRadius.circular(24)), child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.settings_rounded, color: Colors.white)), const SizedBox(width: 15),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Configurações da empresa', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Edite os dados que realmente importam para a operação.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))])),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
              ])),
              const SizedBox(height: 18),
              Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Text(_error!)) : SingleChildScrollView(child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2E8F0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Perfil da empresa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 18),
                _field(_name, 'Nome da empresa', Icons.storefront_rounded), const SizedBox(height: 12),
                _field(_email, 'E-mail', Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress), const SizedBox(height: 12),
                _field(_phone, 'Telefone / WhatsApp', Icons.phone_rounded, keyboard: TextInputType.phone), const SizedBox(height: 22),
                const Text('Horário padrão', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 12),
                Row(children: [Expanded(child: _field(_opening, 'Abre às', Icons.schedule_rounded)), const SizedBox(width: 12), Expanded(child: _field(_closing, 'Fecha às', Icons.schedule_rounded))]),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded), label: const Text('Salvar alterações'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6A00), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)))),
              ])))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType? keyboard}) => TextField(controller: controller, keyboardType: keyboard, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0)))));
}
