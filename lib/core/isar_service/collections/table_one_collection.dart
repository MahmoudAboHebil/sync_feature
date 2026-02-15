import 'package:isar/isar.dart';

part 'table_one_collection.g.dart';

@collection
class TableOneCollection {
  Id id = Isar.autoIncrement;
  @Index()
  late final String entityId;
  late final String centerId;
  late final String message;
  late final String byUser;
  late final String byDevice;
  late final bool isDeleted;
  late final int version;
  late final DateTime createdAt;
  late final DateTime updatedAt;
}
