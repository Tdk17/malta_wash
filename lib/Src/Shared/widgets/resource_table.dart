import 'package:flutter/material.dart';

class ResourceTable extends StatelessWidget {
  const ResourceTable({super.key, required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final keys = <String>[];
    for (final item in items.take(10)) {
      for (final key in item.keys) {
        if (!keys.contains(key) && keys.length < 6) keys.add(key);
      }
    }
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: keys.map((e) => DataColumn(label: Text(_label(e)))).toList(),
          rows: items.map((item) => DataRow(cells: keys.map((key) => DataCell(Text(_format(item[key])))).toList())).toList(),
        ),
      ),
    );
  }

  String _format(dynamic value) {
    if (value == null) return '—';
    if (value is Map || value is List) return value.toString();
    return value.toString();
  }

  String _label(String key) => key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}').trim();
}
