class VWModel {
  final int id;
  final String name;
  final String productionYears;
  final int unitsProduced;
  final String imageUrl;
  final String descriptionCa;
  final String descriptionEn;
  final String descriptionEs;
  final String descriptionFr;
  final String descriptionPt;
  final bool isCabriolet;
  final String? designer;
  final String? engine;
  final String? topSpeed;
  final String? manufacturingPlant;
  final List<Version> versions;
  final List<int> relatedModels;

  VWModel({
    required this.id,
    required this.name,
    required this.productionYears,
    required this.unitsProduced,
    required this.imageUrl,
    required this.descriptionCa,
    required this.descriptionEn,
    required this.descriptionEs,
    required this.descriptionFr,
    required this.descriptionPt,
    this.isCabriolet = false,
    this.designer,
    this.engine,
    this.topSpeed,
    this.manufacturingPlant,
    this.versions = const [],
    this.relatedModels = const [],
  });

  factory VWModel.fromJson(Map<String, dynamic> json) {
    return VWModel(
      id: json['id'],
      name: json['name'],
      productionYears: json['productionYears'],
      unitsProduced: json['unitsProduced'] ?? 0,
      imageUrl: json['imageUrl'],
      descriptionCa: json['description_ca'],
      descriptionEn: json['description_en'],
      descriptionEs: json['description_es'],
      descriptionFr: json['description_fr'],
      descriptionPt: json['description_pt'],
      isCabriolet: json['isCabriolet'] ?? false,
      designer: json['designer'],
      engine: json['engine'],
      topSpeed: json['topSpeed'],
      manufacturingPlant: json['manufacturingPlant'],
      versions: (json['versions'] as List?)
              ?.map((v) => Version.fromJson(v))
              .toList() ??
          [],
      relatedModels: List<int>.from(json['relatedModels'] ?? []),
    );
  }
}

class Version {
  final String modelYear;
  final String dateFrom;
  final String dateTo;
  final String? chassisFrom;
  final String? chassisTo;

  Version({
    required this.modelYear,
    required this.dateFrom,
    required this.dateTo,
    this.chassisFrom,
    this.chassisTo,
  });

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      modelYear: json['modelYear'],
      dateFrom: json['dateFrom'],
      dateTo: json['dateTo'],
      chassisFrom: json['chassisFrom'],
      chassisTo: json['chassisTo'],
    );
  }
}
