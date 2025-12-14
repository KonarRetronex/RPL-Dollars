import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2) // Pastikan ID ini unik (Transaction=1, ini=2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId; // Relasi ke kategori

  @HiveField(2)
  final double limitAmount; // Batas pengeluaran

  @HiveField(3)
  final int month;

  @HiveField(4)
  final int year;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
  });
}