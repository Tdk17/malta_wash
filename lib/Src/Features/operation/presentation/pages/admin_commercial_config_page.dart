import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';
import 'package:malta_wash/Src/Shared/widgets/resource_table.dart';

class AdminCommercialConfigPage extends StatefulWidget {
  const AdminCommercialConfigPage({super.key, required this.mode});
  final CommercialConfigMode mode;

  @override
  State<AdminCommercialConfigPage> createState() => _AdminCommercialConfigPageState();
}

enum CommercialConfigMode { plans, loyalty }

class _AdminCommercialConfigPageState extends State<AdminCommercialConfigPage> {
  final _repository = sl<ResourceRepository>();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _value = TextEditingController();
  final _benefit = TextEditingController();
  List<Map<String, dynamic>> _items = const [];
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
    _description.dispose();
    _value.dispose();
    _benefit.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repository.list(Endpoints.plans);
      if (mounted) setState(() => _items = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final amount = double.tryParse(_value.text.replaceAll(',', '.')) ?? 0;
      final payload = <String, dynamic>{
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        'price': amount,
        'billingCycle': 'MONTHLY',
        'active': true,
        'paymentProvider': 'MERCADO_PAGO',
        'benefits': _benefit.text.trim(),
      };
      await _repository.create(Endpoints.plans, payload);
      _name.clear();
      _description.clear();
      _value.clear();
      _benefit.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plano de fidelidade salvo.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFFFF7ED)]),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _header(),
                const SizedBox(height: 18),
                Expanded(
                  child: LayoutBuilder(builder: (_, constraints) {
                    final wide = constraints.maxWidth >= 980;
                    final form = _form();
                    final list = _list();
                    if (!wide) return ListView(children: [form, const SizedBox(height: 18), SizedBox(height: 460, child: list)]);
                    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 390, child: form), const SizedBox(width: 18), Expanded(child: list)]);
                  }),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF111827)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x220F172A), blurRadius: 26, offset: Offset(0, 12))],
        ),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.loyalty_rounded, color: Colors.white)),
          const SizedBox(width: 15),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Planos de fidelidade', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            SizedBox(height: 4),
            Text('Crie um único plano com valor e benefícios. Não existe mais uma configuração separada de fidelidade.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          ])),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
        ]),
      );

  Widget _form() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.96), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: const [BoxShadow(color: Color(0x120F172A), blurRadius: 24, offset: Offset(0, 10))]),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Novo plano de fidelidade', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            _field(_name, 'Nome do plano', 'Obrigatório'),
            const SizedBox(height: 12),
            _field(_description, 'Descrição', 'Obrigatório', maxLines: 3),
            const SizedBox(height: 12),
            _field(_value, 'Valor mensal (R\$)', 'Informe um valor válido', numeric: true),
            const SizedBox(height: 12),
            _field(_benefit, 'Benefícios e vantagens', 'Obrigatório', maxLines: 3),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBFDBFE))),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF2563EB), size: 18),
                SizedBox(width: 9),
                Expanded(child: Text('A cobrança recorrente fica preparada para o Mercado Pago e deve ser criada pelo backend quando o cliente assinar o plano.', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 12, height: 1.4, fontWeight: FontWeight.w600))),
              ]),
            ),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _saving ? null : _save, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6A00), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), icon: _saving ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.add_rounded), label: const Text('Criar plano de fidelidade'))),
          ]),
        ),
      );

  Widget _field(TextEditingController controller, String label, String error, {int maxLines = 1, bool numeric = false}) => TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : null,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return error;
          if (numeric && double.tryParse(v.replaceAll(',', '.')) == null) return error;
          return null;
        },
        decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0)))),
      );

  Widget _list() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))));
    if (_items.isEmpty) return Center(child: Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2E8F0))), child: const Text('Nenhum plano de fidelidade cadastrado ainda.', style: TextStyle(fontWeight: FontWeight.w800))));
    return SingleChildScrollView(child: ResourceTable(items: _items));
  }
}

class _GridPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final p=Paint()..color=const Color(0xFF64748B).withOpacity(.05)..strokeWidth=.6; const gap=34.0; for(double x=0;x<size.width;x+=gap) canvas.drawLine(Offset(x,0),Offset(x,size.height),p); for(double y=0;y<size.height;y+=gap) canvas.drawLine(Offset(0,y),Offset(size.width,y),p); }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
