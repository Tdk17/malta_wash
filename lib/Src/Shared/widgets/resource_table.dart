import 'package:flutter/material.dart';

class ResourceTable extends StatelessWidget {
  const ResourceTable({
    super.key,
    required this.items,
    this.visibleKeys,
    this.labels = const {},
  });

  final List<Map<String, dynamic>> items;
  final List<String>? visibleKeys;
  final Map<String, String> labels;

  static const _hiddenKeys = {
    'id',
    'objectId',
    '_id',
    'tenantId',
    'userId',
    'customerId',
    'vehicleId',
    'locationId',
    'ownerId',
    'createdBy',
    'updatedBy',
    'acl',
    'ACL',
  };

  @override
  Widget build(BuildContext context) {
    final keys = visibleKeys ?? _discoverKeys();
    if (keys.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x120F172A), blurRadius: 28, offset: Offset(0, 12)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF111827)),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: .25,
          ),
          dataTextStyle: const TextStyle(
            color: Color(0xFF334155),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          dividerThickness: .6,
          horizontalMargin: 22,
          columnSpacing: 34,
          dataRowMinHeight: 58,
          dataRowMaxHeight: 68,
          columns: keys.map((key) => DataColumn(label: Text(labels[key] ?? _label(key)))).toList(),
          rows: items.map((item) {
            return DataRow(
              cells: keys.map((key) => DataCell(_CellValue(value: _resolve(item, key), keyName: key))).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<String> _discoverKeys() {
    final keys = <String>[];
    for (final item in items.take(15)) {
      for (final key in item.keys) {
        if (_hiddenKeys.contains(key) || key.toLowerCase().endsWith('id')) continue;
        if (!keys.contains(key) && keys.length < 6) keys.add(key);
      }
    }
    return keys;
  }

  dynamic _resolve(Map<String, dynamic> item, String key) {
    if (item.containsKey(key)) return item[key];
    if (!key.contains('.')) return null;
    dynamic value = item;
    for (final part in key.split('.')) {
      if (value is Map) {
        value = value[part];
      } else {
        return null;
      }
    }
    return value;
  }

  String _label(String key) {
    final clean = key.split('.').last;
    return clean
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
        .trim()
        .split(' ')
        .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }
}

class _CellValue extends StatelessWidget {
  const _CellValue({required this.value, required this.keyName});
  final dynamic value;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    final text = _format(value);
    final key = keyName.toLowerCase();
    final statusLike = key.contains('status') || key.contains('state');

    if (statusLike && text != '—') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6A00).withOpacity(.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFF6A00).withOpacity(.22)),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xFFC45200), fontWeight: FontWeight.w800, fontSize: 12)),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 2),
    );
  }

  String _format(dynamic value) {
    if (value == null) return '—';
    if (value is Map) {
      for (final key in const ['name', 'title', 'label', 'email', 'plate', 'licensePlate']) {
        final nested = value[key];
        if (nested != null && nested.toString().trim().isNotEmpty) return nested.toString();
      }
      return '—';
    }
    if (value is List) return value.isEmpty ? '—' : value.map(_format).where((e) => e != '—').join(', ');
    if (value is bool) return value ? 'Sim' : 'Não';
    final text = value.toString().trim();
    return text.isEmpty ? '—' : text;
  }
}
