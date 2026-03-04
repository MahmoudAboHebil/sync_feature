import 'package:isar/isar.dart';

part 'table_three_collection.g.dart';

@collection
class TableThreeCollection {
  Id id = Isar.autoIncrement;
  @Index()
  late String entityId;
  @Index()
  late String forKeyTableTwo;

  late String centerId;
  late String message;
  late String byUser;
  late String byDevice;
  late bool isDeleted;
  late int version;
  late DateTime createdAt;
  late DateTime updatedAt;
}
