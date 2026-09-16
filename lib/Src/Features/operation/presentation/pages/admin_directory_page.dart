import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class AdminDirectoryPage extends StatefulWidget {
  const AdminDirectoryPage({super.key});

  @override
  State<AdminDirectoryPage> createState() => _AdminDirectoryPageState();
}

class _AdminDirectoryPageState extends State<AdminDirectoryPage> {
  final _repository = sl<ResourceRepository>();
  final _search = TextEditingController();
  List<Map<String, dynamic>> _customers = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _search.addListener(() => setState(() {})); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _repository.list(Endpoints.customers);
      if (!mounted) return;
      setState(() { _customers = result; });
    } catch (e) { if (mounted) setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _editCustomer(Map<String, dynamic> customer) async {
    final id = _id(customer); if (id.isEmpty) return _message('Cliente sem identificador técnico para edição.');
    final name = TextEditingController(text: _pick(customer, ['name','customerName','clientName'], fallback: ''));
    final email = TextEditingController(text: _pick(customer, ['email'], fallback: ''));
    final phone = TextEditingController(text: _pick(customer, ['phone','mobile','whatsapp'], fallback: ''));
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Editar cliente'),
      content: SizedBox(width: 440, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
        const SizedBox(height: 12),
        TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail')),
        const SizedBox(height: 12),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone / WhatsApp')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Salvar'))],
    ));
    if (ok != true) { name.dispose(); email.dispose(); phone.dispose(); return; }
    try {
      await _repository.patch(Endpoints.customer(id), {'name': name.text.trim(), 'email': email.text.trim(), 'phone': phone.text.trim()});
      await _load(); _message('Cliente atualizado.');
    } catch (e) { _message(e.toString()); }
    name.dispose(); email.dispose(); phone.dispose();
  }

  Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
    final id = _id(customer); if (id.isEmpty) return _message('Cliente sem identificador técnico para exclusão.');
    final name = _pick(customer, ['name','customerName','clientName']);
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Remover cliente?'), content: Text('Remover $name da base?'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Voltar')), FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)), onPressed: () => Navigator.pop(c, true), child: const Text('Remover'))],
    ));
    if (ok != true) return;
    try { await _repository.delete(Endpoints.customer(id)); await _load(); _message('Cliente removido.'); } catch (e) { _message(e.toString()); }
  }

  void _message(String text) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text))); }

  @override
  Widget build(BuildContext context) {
    final rows = _rows();
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFEFF6FF)])),
      child: Padding(padding: const EdgeInsets.all(28), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1320), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _header(rows.length), const SizedBox(height: 18),
        SizedBox(width: 420, child: TextField(controller: _search, decoration: InputDecoration(hintText: 'Buscar cliente, telefone ou e-mail...', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)))),
        const SizedBox(height: 18), Expanded(child: _content(rows)),
      ])))),
    );
  }

  Widget _header(int count) => Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF111827)]), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x220F172A), blurRadius: 26, offset: Offset(0, 12))]), child: Row(children: [
    Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.people_alt_rounded, color: Colors.white)), const SizedBox(width: 15),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Clientes', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('Nome, telefone, e-mail e ações de edição.', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(12)), child: Text('$count registros', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12))), const SizedBox(width: 8), IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
  ]));

  Widget _content(List<_RowData> rows) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))));
    if (rows.isEmpty) return const Center(child: Text('Nenhum registro encontrado.', style: TextStyle(fontWeight: FontWeight.w800)));
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: const [BoxShadow(color: Color(0x120F172A), blurRadius: 28, offset: Offset(0, 12))]), clipBehavior: Clip.antiAlias, child: Column(children: [
      Container(color: const Color(0xFF111827), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Row(children: [const Expanded(flex: 3, child: Text('CLIENTE', style: _heading)), const Expanded(flex: 3, child: Text('E-MAIL', style: _heading)), const Expanded(flex: 4, child: Text('TELEFONE', style: _heading)), const SizedBox(width: 112, child: Text('AÇÕES', textAlign: TextAlign.right, style: _heading))])),
      Expanded(child: ListView.separated(itemCount: rows.length, separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)), itemBuilder: (_, i) {
        final row = rows[i]; return Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Row(children: [
          Expanded(flex: 3, child: Row(children: [CircleAvatar(radius: 18, backgroundColor: const Color(0xFFFF6A00).withOpacity(.12), child: Text(_initials(row.name), style: const TextStyle(color: Color(0xFFC45200), fontWeight: FontWeight.w900, fontSize: 11))), const SizedBox(width: 10), Expanded(child: Text(row.name, style: const TextStyle(fontWeight: FontWeight.w800)))])),
          Expanded(flex: 3, child: Text(row.email, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
          Expanded(flex: 4, child: SelectableText(row.phone, style: const TextStyle(fontWeight: FontWeight.w700))),
          SizedBox(width: 112, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [IconButton(tooltip: 'Editar', onPressed: row.customer == null ? null : () => _editCustomer(row.customer!), icon: const Icon(Icons.edit_rounded, color: Color(0xFF2563EB))), IconButton(tooltip: 'Remover', onPressed: row.customer == null ? null : () => _deleteCustomer(row.customer!), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB91C1C)))])),
        ]));
      }))
    ]));
  }

  List<_RowData> _rows() {
    final rows = _customers.map((customer) => _RowData(
      name: _pick(customer, ['name', 'customerName', 'clientName']),
      email: _pick(customer, ['email']),
      phone: _pick(customer, ['phone', 'mobile', 'whatsapp']),
      customer: customer,
    )).toList();
    final query = _search.text.trim().toLowerCase();
    return rows.where((row) => '${row.name} ${row.email} ${row.phone}'.toLowerCase().contains(query)).toList();
  }

  String _id(Map<String, dynamic> item) => _pick(item, ['id', 'objectId', '_id'], fallback: '');
  String _pick(Map<String,dynamic> i,List<String> keys,{String fallback='—'}){for(final k in keys){final v=i[k];if(v!=null&&v is! Map&&v.toString().trim().isNotEmpty)return v.toString();}return fallback;}
  String _initials(String n){final p=n.trim().split(RegExp(r'\s+')).where((e)=>e.isNotEmpty).toList();if(p.isEmpty||n=='—')return'CL';return p.take(2).map((e)=>e[0].toUpperCase()).join();}
  static const _heading=TextStyle(color:Colors.white70,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:.8);
}

class _RowData { const _RowData({required this.name,required this.email,required this.phone,this.customer}); final String name; final String email; final String phone; final Map<String,dynamic>? customer; }
