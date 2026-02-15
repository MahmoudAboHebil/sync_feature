import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';

class MockLocalTableDataSource extends Mock implements LocalTableDatasource {}

class MockLocalQueueDataSource extends Mock implements LocalQueueDatasource {}

void main() {
  late final TableRepositoryImpl repository;
  late final MockLocalQueueDataSource localQueueDatasource;
  late final MockLocalTableDataSource localTableDatasource;
  setUp(() {
    registerFallbackValue(DBTable.values.first);
    localQueueDatasource = MockLocalQueueDataSource();
    localTableDatasource = MockLocalTableDataSource();
    repository = TableRepositoryImpl(
      localQueueDatasource,
      localTableDatasource,
    );
  });

  test(
    'should print tables and its entities-ids (that will be removed)',
    () async {
      final tableDeletedEntitiesMap = await repository
          .deleteEntityCascadeNotNull(
            DBTable.table4,
            'tab-4-enti-2',
            test: true,
          );
      final x = tableDeletedEntitiesMap.getOrThrow();
      for (final z in x.entries) {
        print('${z.key}   ==> ${z.value}');
      }
    },
  );
}

/*
    //--------------- Queue------------------------

final List<OperationCollection> mainQueue = [
      OperationCollection()
        ..operationId = 'oper-1'
        ..entityId = 'enti-1'
        ..centerId = '---'
        ..action = 'create'
        ..table = "table1"
        ..version = 1
        ..userRole = "---"
        ..createdBy = "---"
        ..payload = jsonEncode({
          'id': 'enti-1',
          'data': 0,
          'version': 1,
          'by_user': "ahmed",
          'is_deleted': false,
          'centerId': "center-1",
          'by_device': 'device-1',
          'updated_at': DateTime(2026, 2, 1, 0).toIso8601String(),
          'created_at': DateTime(2026, 2, 1, 0).toIso8601String(),
        })
        ..createdAt = DateTime(2026, 2, 1, 0),
      //------------------------------------------
      OperationCollection()
        ..operationId = 'oper-2'
        ..entityId = 'enti-2'
        ..centerId = 'center-1'
        ..action = 'update'
        ..table = "table2"
        ..version = 1
        ..userRole = "admin"
        ..createdBy = "ahmed"
        ..payload = jsonEncode({
          'id': 'enti-2',
          'data': 0,
          'version': 1,
          'by_user': "ahmed",
          'is_deleted': false,
          'centerId': "center-1",
          'by_device': 'device-1',
          'updated_at': DateTime(2026, 2, 1, 1).toIso8601String(),
          'created_at': DateTime(2026, 2, 1, 1).toIso8601String(),
        })
        ..createdAt = DateTime(2026, 2, 1, 1),
      //------------------------------------------------
    ];
 */
