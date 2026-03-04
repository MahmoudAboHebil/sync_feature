import 'package:isar/isar.dart';

part 'table_one_collection.g.dart';

@collection
class TableOneCollection {
  Id id = Isar.autoIncrement;
  @Index()
  late String entityId;
  late String centerId;
  late String message;
  late String byUser;
  late String byDevice;
  late bool isDeleted;
  late int version;
  late DateTime createdAt;
  late DateTime updatedAt;
}
