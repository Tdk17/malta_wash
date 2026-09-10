import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Core/di/service_locator.dart';
import 'package:malta_wash/Src/Core/http/endpoints.dart';
import 'package:malta_wash/Src/Features/common/domain/resource_repository.dart';

class AdminServicesPage extends StatefulWidget {
  const AdminServicesPage({super.key});

  @override
  State<AdminServicesPage> createState() => _AdminServicesPageState();
}

class _AdminServicesPageState extends State<AdminServicesPage> {
  final _repository = sl<ResourceRepository>();
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = const [];
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repository.list(Endpoints.services);
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEditor([Map<String, dynamic>? service]) async {
    final name = TextEditingController(text: _pick(service, ['name', 'title'], ''));
    final description = TextEditingController(text: _pick(service, ['description'], ''));
    final price = TextEditingController(text: _pick(service, ['price', 'value', 'amount'], ''));
    final duration = TextEditingController(text: _pick(service, ['durationMinutes', 'duration', 'minutes'], ''));
    bool active = _bool(service, ['active', 'isActive'], true);
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(service == null ? 'Novo serviço' : 'Editar serviço'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Nome do serviço', hintText: 'Ex.: Lavagem completa'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: description,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descrição', hintText: 'O que está incluído neste serviço'),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: price,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Preço (R\$)', hintText: '0,00'),
                          validator: (v) => double.tryParse((v ?? '').replaceAll(',', '.')) == null ? 'Valor inválido.' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: duration,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Duração (min)', hintText: '60'),
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Duração inválida.' : null,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Disponível para agendamento'),
                      subtitle: const Text('Quando desativado, o cliente não deve ver este serviço ao agendar.'),
                      value: active,
                      onChanged: (value) => setDialogState(() => active = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Salvar serviço'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) {
      name.dispose();
      description.dispose();
      price.dispose();
      duration.dispose();
      return;
    }

    final payload = <String, dynamic>{
      'name': name.text.trim(),
      'description': description.text.trim(),
      'price': double.parse(price.text.replaceAll(',', '.')),
      'durationMinutes': int.parse(duration.text),
      'active': active,
    };

    try {
      if (service == null) {
        await _repository.create(Endpoints.services, payload);
      } else {
        final id = _id(service);
        if (id.isEmpty) throw Exception('Serviço sem identificador técnico para edição.');
        await _repository.patch(Endpoints.service(id), payload);
      }
      await _load();
      _message(service == null ? 'Serviço cadastrado.' : 'Serviço atualizado.');
    } catch (e) {
      _message(e.toString());
    } finally {
      name.dispose();
      description.dispose();
      price.dispose();
      duration.dispose();
    }
  }

  Future<void> _delete(Map<String, dynamic> service) async {
    final id = _id(service);
    if (id.isEmpty) {
      _message('Serviço sem identificador técnico para exclusão.');
      return;
    }
    final name = _pick(service, ['name', 'title'], 'este serviço');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover serviço?'),
        content: Text('$name será removido do catálogo e não deverá mais aparecer para novos agendamentos.'),
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
      await _repository.delete(Endpoints.service(id));
      await _load();
      _message('Serviço removido.');
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
    final q = _search.text.trim().toLowerCase();
    final visible = _items.where((item) {
      if (q.isEmpty) return true;
      return '${_pick(item, ['name', 'title'], '')} ${_pick(item, ['description'], '')}'.toLowerCase().contains(q);
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFFFF7ED)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _header(visible.length),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Buscar serviço...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Novo serviço'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              Expanded(child: _body(visible)),
            ]),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6A00), Color(0xFFFF8A34)]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.local_car_wash_rounded, color: Colors.white),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Serviços', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('Cadastre tudo que a empresa oferece. Estes serviços alimentam as opções do agendamento do cliente.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(12)),
            child: Text('$count serviços', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
        ]),
      );

  Widget _body(List<Map<String, dynamic>> items) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))));
    }
    if (items.isEmpty) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cleaning_services_rounded, size: 42, color: Color(0xFFFF6A00)),
            const SizedBox(height: 12),
            const Text('Nenhum serviço cadastrado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            const Text('Cadastre lavagem simples, lavagem completa, enceramento, polimento ou qualquer outro serviço oferecido pela empresa.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), height: 1.45)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: () => _openEditor(), icon: const Icon(Icons.add_rounded), label: const Text('Cadastrar primeiro serviço')),
          ]),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 390,
        mainAxisExtent: 230,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        final name = _pick(item, ['name', 'title'], 'Serviço');
        final description = _pick(item, ['description'], 'Sem descrição');
        final price = _number(item, ['price', 'value', 'amount']);
        final duration = _pick(item, ['durationMinutes', 'duration', 'minutes'], '—');
        final active = _bool(item, ['active', 'isActive'], true);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [BoxShadow(color: Color(0x100F172A), blurRadius: 20, offset: Offset(0, 9))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFFF6A00).withOpacity(.10), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.water_drop_rounded, color: Color(0xFFFF6A00))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: active ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                child: Text(active ? 'Disponível' : 'Inativo', style: TextStyle(color: active ? const Color(0xFF166534) : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 14),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), height: 1.35, fontSize: 12.5)),
            const Spacer(),
            Row(children: [
              Text('R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              Text('$duration min', style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 12)),
              const Spacer(),
              IconButton(tooltip: 'Editar', onPressed: () => _openEditor(item), icon: const Icon(Icons.edit_rounded, color: Color(0xFF2563EB))),
              IconButton(tooltip: 'Remover', onPressed: () => _delete(item), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB91C1C))),
            ]),
          ]),
        );
      },
    );
  }

  String _id(Map<String, dynamic> item) => _pick(item, ['id', 'objectId', '_id'], '');

  String _pick(Map<String, dynamic>? item, List<String> keys, String fallback) {
    if (item == null) return fallback;
    for (final key in keys) {
      final value = item[key];
      if (value != null && value is! Map && value.toString().trim().isNotEmpty) return value.toString();
    }
    return fallback;
  }

  double _number(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  bool _bool(Map<String, dynamic>? item, List<String> keys, bool fallback) {
    if (item == null) return fallback;
    for (final key in keys) {
      final value = item[key];
      if (value is bool) return value;
      if (value?.toString().toLowerCase() == 'true') return true;
      if (value?.toString().toLowerCase() == 'false') return false;
    }
    return fallback;
  }
}
