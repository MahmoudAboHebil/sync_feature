import 'package:isar/isar.dart';

part 'operation_collection.g.dart';

@collection
class OperationCollection {
  Id id = Isar.autoIncrement;
  late String centerId;
  late String operationId;
  late String entityId;
  late String action;
  late String table;
  late String payload;
  late int version;
  late String userRole;
  late String createdBy;
  late DateTime createdAt;
}
