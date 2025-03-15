import 'package:hive/hive.dart';


part 'hive.g.dart';

@HiveType(typeId: 0)
class FavoriteModel extends HiveObject{
  @HiveField(0)
  String word;

  @HiveField(1)
  bool isChecked;

  FavoriteModel({
    required this.word,
    this.isChecked = false,
  });
}