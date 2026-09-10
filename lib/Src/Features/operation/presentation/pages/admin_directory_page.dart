import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class AdminDirectoryPage extends StatefulWidget {
  const AdminDirectoryPage({super.key, this.vehicleFocus = false});
  final bool vehicleFocus;

  @override
  State<AdminDirectoryPage> createState() => _AdminDirectoryPageState();
}

class _AdminDirectoryPageState extends State<AdminDirectoryPage> {
  final _repository = sl<ResourceRepository>();
  final _search = TextEditingController();
  List<Map<String, dynamic>> _customers = const [];
  List<Map<String, dynamic>> _vehicles = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await Future.wait([
        _repository.list(Endpoints.customers),
        _repository.list(Endpoints.vehicles),
      ]);
      if (!mounted) return;
      setState(() {
        _customers = result[0];
        _vehicles = result[1];
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editCustomer(Map<String, dynamic> customer) async {
    final id = _id(customer);
    if (id.isEmpty) {
      _message('Este cliente veio sem identificador técnico para edição.');
      return;
    }
    final name = TextEditingController(text: _pick(customer, ['name', 'customerName', 'clientName'], fallback: ''));
    final email = TextEditingController(text: _pick(customer, ['email'], fallback: ''));
    final phone = TextEditingController(text: _pick(customer, ['phone', 'mobile', 'whatsapp'], fallback: ''));
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar cliente'),
        content: SizedBox(
          width: 440,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
            const SizedBox(height: 12),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail')),
            const SizedBox(height: 12),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone / WhatsApp')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Salvar alterações')),
        ],
      ),
    );
    if (saved != true) return;
    try {
      await _repository.patch(Endpoints.customer(id), {
        'name': name.text.trim(),
        'email': email.text.trim(),
        'phone': phone.text.trim(),
      });
      await _load();
      _message('Cliente atualizado.');
    } catch (e) {
      _message(e.toString());
    } finally {
      name.dispose(); email.dispose(); phone.dispose();
    }
  }

  Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
    final id = _id(customer);
    if (id.isEmpty) {
      _message('Este cliente veio sem identificador técnico para exclusão.');
      return;
    }
    final name = _pick(customer, ['name', 'customerName', 'clientName']);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover cliente?'),
        content: Text('O cliente $name será removido da base. Esta ação deve ser permitida pelo backend.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Voltar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repository.delete(Endpoints.customer(id));
      await _load();
      _message('Cliente removido.');
    } catch (e) {
      _message(e.toString());
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFEFF6FF)]),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _header(rows.length),
                const SizedBox(height: 18),
                SizedBox(
                  width: 420,
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: widget.vehicleFocus ? 'Buscar cliente, e-mail, veículo ou placa...' : 'Buscar cliente ou e-mail...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(child: _content(rows)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(int count) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF111827)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x220F172A), blurRadius: 26, offset: Offset(0, 12))],
        ),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]), borderRadius: BorderRadius.circular(15)), child: Icon(widget.vehicleFocus ? Icons.directions_car_filled_rounded : Icons.people_alt_rounded, color: Colors.white)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.vehicleFocus ? 'Veículos dos clientes' : 'Clientes', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(widget.vehicleFocus ? 'Veículos vinculados ao cliente, sem expor IDs internos.' : 'Nome, e-mail, veículo e ações administrativas.', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(12)), child: Text('$count registros', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12))),
          const SizedBox(width: 8),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
        ]),
      );

  Widget _content(List<_DirectoryRow> rows) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))));
    if (rows.isEmpty) return Center(child: Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2E8F0))), child: Text(widget.vehicleFocus ? 'Nenhum veículo vinculado' : 'Nenhum cliente cadastrado', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))));

    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(.96), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: const [BoxShadow(color: Color(0x120F172A), blurRadius: 28, offset: Offset(0, 12))]),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Container(
          color: const Color(0xFF111827),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            const Expanded(flex: 3, child: Text('CLIENTE', style: _headingStyle)),
            const Expanded(flex: 3, child: Text('E-MAIL', style: _headingStyle)),
            Expanded(flex: 4, child: Text(widget.vehicleFocus ? 'VEÍCULO / PLACA' : 'VEÍCULOS', style: _headingStyle)),
            if (!widget.vehicleFocus) const SizedBox(width: 112, child: Text('AÇÕES', textAlign: TextAlign.right, style: _headingStyle)),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (_, i) {
              final row = rows[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(children: [
                  Expanded(flex: 3, child: Row(children: [
                    CircleAvatar(radius: 18, backgroundColor: const Color(0xFFFF6A00).withOpacity(.12), child: Text(_initials(row.name), style: const TextStyle(color: Color(0xFFC45200), fontWeight: FontWeight.w900, fontSize: 11))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(row.name, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800))),
                  ])),
                  Expanded(flex: 3, child: Text(row.email, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
                  Expanded(flex: 4, child: Wrap(spacing: 7, runSpacing: 7, children: row.vehicles.isEmpty ? [const Text('Nenhum veículo', style: TextStyle(color: Color(0xFF94A3B8)))] : row.vehicles.map((vehicle) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))), child: Text(vehicle, style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w700, fontSize: 12)))).toList())),
                  if (!widget.vehicleFocus)
                    SizedBox(width: 112, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      IconButton(tooltip: 'Editar cliente', onPressed: row.customer == null ? null : () => _editCustomer(row.customer!), icon: const Icon(Icons.edit_rounded, color: Color(0xFF2563EB))),
                      IconButton(tooltip: 'Remover cliente', onPressed: row.customer == null ? null : () => _deleteCustomer(row.customer!), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB91C1C))),
                    ])),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }

  List<_DirectoryRow> _buildRows() {
    final rows = <_DirectoryRow>[];
    final customerById = <String, Map<String, dynamic>>{};
    for (final customer in _customers) {
      final id = _id(customer);
      if (id.isNotEmpty) customerById[id] = customer;
    }
    if (widget.vehicleFocus) {
      for (final vehicle in _vehicles) {
        final ownerId = _ownerId(vehicle);
        final customer = ownerId.isNotEmpty ? customerById[ownerId] : _embeddedCustomer(vehicle);
        rows.add(_DirectoryRow(name: _pick(customer ?? vehicle, ['name', 'customerName', 'clientName']), email: _pick(customer ?? vehicle, ['email', 'customerEmail']), vehicles: [_vehicleLabel(vehicle)], customer: customer));
      }
    } else {
      for (final customer in _customers) {
        final id = _id(customer);
        final linked = _vehicles.where((vehicle) {
          final ownerId = _ownerId(vehicle);
          if (id.isNotEmpty && ownerId == id) return true;
          final embedded = _embeddedCustomer(vehicle);
          return embedded != null && _pick(embedded, ['email']) == _pick(customer, ['email']);
        }).map(_vehicleLabel).toList();
        rows.add(_DirectoryRow(name: _pick(customer, ['name', 'customerName', 'clientName']), email: _pick(customer, ['email']), vehicles: linked, customer: customer));
      }
    }
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return rows.where((row) => '${row.name} ${row.email} ${row.vehicles.join(' ')}'.toLowerCase().contains(q)).toList();
  }

  String _id(Map<String, dynamic> item) => _pick(item, ['id', 'objectId', '_id'], fallback: '');
  String _ownerId(Map<String, dynamic> vehicle) {
    for (final key in const ['customerId', 'ownerId', 'clientId', 'userId']) {
      final value = vehicle[key];
      if (value != null && value.toString().isNotEmpty) return value.toString();
    }
    final customer = _embeddedCustomer(vehicle);
    return customer == null ? '' : _id(customer);
  }
  Map<String, dynamic>? _embeddedCustomer(Map<String, dynamic> vehicle) {
    for (final key in const ['customer', 'owner', 'client']) {
      final value = vehicle[key];
      if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }
  String _vehicleLabel(Map<String, dynamic> vehicle) {
    final name = _pick(vehicle, ['vehicleName', 'name', 'model', 'car'], fallback: 'Veículo');
    final plate = _pick(vehicle, ['plate', 'licensePlate'], fallback: '');
    final color = _pick(vehicle, ['color'], fallback: '');
    return [name, color, plate].where((e) => e.isNotEmpty).join(' • ');
  }
  String _pick(Map<String, dynamic> item, List<String> keys, {String fallback = '—'}) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value is! Map && value.toString().trim().isNotEmpty) return value.toString();
    }
    return fallback;
  }
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty || name == '—') return 'CL';
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }

  static const _headingStyle = TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8);
}

class _DirectoryRow {
  const _DirectoryRow({required this.name, required this.email, required this.vehicles, this.customer});
  final String name;
  final String email;
  final List<String> vehicles;
  final Map<String, dynamic>? customer;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF64748B).withOpacity(.05)..strokeWidth = .6;
    const gap = 34.0;
    for (double x = 0; x < size.width; x += gap) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += gap) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
