import 'package:hive/hive.dart';

part 'budget_model.g.dart';

// UBAH TypeId JADI 6 (Agar aman dan terhitung baru)
@HiveType(typeId: 6) 
class BudgetModel extends HiveObject {
  
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double limitAmount;

  @HiveField(3)
  final int month;

  @HiveField(4)
  final int year;

  @HiveField(5) // Field Baru
  final double warningPercentage; // Batas peringatan (0.0 - 1.0)

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
    this.warningPercentage = 0.20, // Default 20%
  });
}