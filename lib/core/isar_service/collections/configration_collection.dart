import 'package:isar/isar.dart';

part 'configration_collection.g.dart';

@collection
class ConfigrationCollection {
  Id id = Isar.autoIncrement;
  late DateTime lastSyncTime;
  late String deviceId;
  late int recordId;
}
