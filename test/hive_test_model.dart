import 'package:hive/hive.dart';

part 'hive_test_model.g.dart';

@HiveType(typeId: 1)
class HiveTestModel {
  @HiveField(0)
  final String key;

  HiveTestModel({required this.key});
}
