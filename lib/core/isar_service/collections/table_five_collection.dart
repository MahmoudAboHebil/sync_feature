import 'package:isar/isar.dart';

part 'table_five_collection.g.dart';

@collection
class TableFiveCollection {
  Id id = Isar.autoIncrement;
  @Index()
  late String entityId;
  @Index()
  late String forKeyTableFour;
  @Index()
  late String forKeyTableThree;
  late String centerId;
  late String message;
  late String byUser;
  late String byDevice;
  late bool isDeleted;
  late int version;
  late DateTime createdAt;
  late DateTime updatedAt;
}
