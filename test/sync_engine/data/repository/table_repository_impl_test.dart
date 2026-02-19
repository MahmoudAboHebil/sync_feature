import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/enums/user_role.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/models/operation_model.dart';
import 'package:sync_feature/sync_engine/data/data_source/models/table_one_model.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';

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
  /*
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

 */

  test('test operation', () async {
    final operation = Operation(
      id: '3e82f13c-f9eb-4f7f-93c9-2451473a8a6f',
      entityId: 'c887ca56-89c8-42fd-9d8c-0b0c2be7c5d6',
      centerId: '5d242021-432d-41ea-ac04-fba60e368fd3',
      action: OperationAction.create,
      table: DBTable.table_one,
      json: TableOneModel(
        entityId: 'c887ca56-89c8-42fd-9d8c-0b0c2be7c5d6',
        message: 'hellow from table one',
        centerId: '5d242021-432d-41ea-ac04-fba60e368fd3',
        byUser: 'Mahmoud',
        byDevice: deviceId,
        isDeleted: false,
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
    );

    final payload = {
      "operation": OperationModel.fromOperation(operation).toJson(),
      "parent_ids": {},
      "tablesEntitiesIdsRemove": {},
      "device_id": deviceId,
      "user_id": operation.createdBy,
    };
    print(payload);
  });
  /*
  test('insert entity to table', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final TableRepository repository = TableRepositoryImpl(
      queueDatasource,
      tableDatasource,
    );
    final model = TableOneModel(
      entityId: 'c887ca56-89c8-42fd-9d8c-0b0c2be7c5d6',
      message: 'hellow from table one',
      centerId: '5d242021-432d-41ea-ac04-fba60e368fd3',
      byUser: 'Mahmoud',
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    repository.insertEntityToTable(DBTable.table_one, null, entity);
  });

   */
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
