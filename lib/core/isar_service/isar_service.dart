import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sync_feature/core/isar_service/collections/configration_collection.dart';
import 'package:sync_feature/core/isar_service/collections/operation_collection.dart';
import 'package:sync_feature/core/isar_service/collections/table_one_collection.dart';

import 'collections/table_five_collection.dart';
import 'collections/table_four_collection.dart';
import 'collections/table_three_collection.dart';
import 'collections/table_two_collection.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [
        OperationCollectionSchema,
        ConfigrationCollectionSchema,
        TableOneCollectionSchema,
        TableTwoCollectionSchema,
        TableThreeCollectionSchema,
        TableFourCollectionSchema,
        TableFiveCollectionSchema,
      ],
      directory: dir.path,
      inspector: true,
    );

    return _instance!;
  }

  static Isar get isar {
    if (_instance == null) {
      throw Exception('Isar is not initialized');
    }
    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
