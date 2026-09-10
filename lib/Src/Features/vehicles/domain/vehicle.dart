class Vehicle {
  const Vehicle({
    required this.id,
    required this.plate,
    this.brand,
    this.model,
    this.year,
    this.color,
    this.category,
    this.notes,
  });

  final String id;
  final String plate;
  final String? brand;
  final String? model;
  final int? year;
  final String? color;
  final String? category;
  final String? notes;

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: (json['id'] ?? json['objectId'] ?? '').toString(),
        plate: (json['plate'] ?? json['placa'] ?? '').toString(),
        brand: (json['brand'] ?? json['marca'])?.toString(),
        model: (json['model'] ?? json['modelo'])?.toString(),
        year: int.tryParse((json['year'] ?? json['ano'] ?? '').toString()),
        color: (json['color'] ?? json['cor'])?.toString(),
        category: (json['category'] ?? json['categoria'])?.toString(),
        notes: (json['notes'] ?? json['observations'])?.toString(),
      );
}
