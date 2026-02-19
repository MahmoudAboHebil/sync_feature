import 'package:flutter_test/flutter_test.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/enums/user_role.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_one_datasource_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/sync_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_one.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_entity_local.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/push_single_operation.dart';

void main() {
  late final queueDatasource;
  late final tableDatasource;
  late final tableRepository;
  late final syncRepository;

  setUp(() {
    queueDatasource = LocalQueueDatasource();
    tableDatasource = LocalTableOneDatasource();
    tableRepository = TableRepositoryImpl(queueDatasource, tableDatasource);
    syncRepository = SyncRepositoryImpl(tableRepository);
  });

  test('add entity to local db && to server', () async {
    final entityId = "c887ca56-89c8-42fd-9d8c-0b0c2be7c5d6";
    final centerId = "5d242021-432d-41ea-ac04-fba60e368fd3";
    final operationId = "3e82f13c-f9eb-4f7f-93c9-2451473a8a6f";
    final entity = TableOne(
      entityId: entityId,
      message: 'hellow from table one',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // add to local
    final params = AddEntityLocalParams(
      table: DBTable.table_one,
      jsonEntity: null,
      entity: entity,
    );
    final useCase = AddEntityLocal(tableRepository);
    final result = await useCase.call(params);
    result.fold(
      ifLeft: (err) {
        print('Entity is Not Add');
        print(err);
      },
      ifRight: (d) => print('Entity is Added to Local Db'),
    );
    // push to server

    final operation = Operation(
      id: operationId,
      entityId: entityId,
      centerId: centerId,
      action: OperationAction.create,
      table: DBTable.table_one,
      json: entity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
    );
    final pushParams = PushSingleOperationParams(operation: operation);
    final pushUseCase = PushSingleOperation(syncRepository);
    final pushResult = await pushUseCase.call(pushParams);
    pushResult.fold(
      ifLeft: (err) {
        print('failed to push flutter side');
        print(err);
      },
      ifRight: (d) {
        print(d);
      },
    );
  });
}
