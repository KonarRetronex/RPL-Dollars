import 'package:hive/hive.dart';
import 'transaction_model.dart'; // Impor untuk TransactionType
part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  TransactionType type;

  @HiveField(3)
  int? iconCodePoint;

  // Anda bisa tambahkan field untuk icon/color sesuai Figma
  // @HiveField(3)
  // int color; 
  
  // @HiveField(4)
  // int iconCodePoint;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.iconCodePoint,
  });
}