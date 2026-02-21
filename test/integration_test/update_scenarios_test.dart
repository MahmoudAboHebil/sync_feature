import 'package:flutter_test/flutter_test.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart'
    show OperationAction;
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_one_datasource_impl.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/sync_datasource.dart';
import 'package:sync_feature/sync_engine/data/repository/queue_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/sync_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_five.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_entity_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_operation_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_table_queue_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/push_single_operation_usecase.dart';

void main() {
  test('version conflict when (op.version < entity.version', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final queueRepository = QueueRepositoryImpl(queueDatasource);
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(
      queueDatasource,
      tableDatasource,
    );
    final syncRepository = SyncRepositoryImpl(tableRepository, syncDatasource);
    final addEntityUseCase = AddEntityLocalUseCase(tableRepository);
    final addOperationUseCase = AddOperationLocalUseCase(queueRepository);
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepository);
    final pushSingleOperationUseCase = PushSingleOperationUseCase(
      syncRepository,
    );

    final entityFive = TableFive(
      forKeyTableThree: "8142af86-79a1-44ba-89a5-05928e14a173",
      forKeyTableFour: "a5053a65-26f6-4c7f-8887-b6b6fd88a595",
      entityId: "4080b569-9715-471d-bf8f-61ae352d2c4a",
      message: 'hellow from table five ent=1',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: true,
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final operationFive = Operation(
      id: "66263d05-f8cf-4a83-ade2-21cc5abe61c8",
      entityId: "4080b569-9715-471d-bf8f-61ae352d2c4a",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.update,
      table: DBTable.table_five,
      json: entityFive.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
    );

    // push operation to server
    final result = await pushSingleOperationUseCase.call(
      PushSingleOperationUseCaseParams(
        operation: operationFive,
        deviceId: deviceId,
      ),
    );
    result.fold(
      ifLeft: (err) {
        print('Error : pushing operation five to server');
        print(err);
      },
      ifRight: (e) {
        print('Success : pushing operation five to server');
        print(e);
      },
    );
  });
  test('4)updated 5 ( 3 is deleted at server )', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final queueRepository = QueueRepositoryImpl(queueDatasource);
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(
      queueDatasource,
      tableDatasource,
    );
    final syncRepository = SyncRepositoryImpl(tableRepository, syncDatasource);
    final addEntityUseCase = AddEntityLocalUseCase(tableRepository);
    final addOperationUseCase = AddOperationLocalUseCase(queueRepository);
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepository);
    final pushSingleOperationUseCase = PushSingleOperationUseCase(
      syncRepository,
    );

    final entityFive = TableFive(
      forKeyTableFour: "a5053a65-26f6-4c7f-8887-b6b6fd88a595",
      forKeyTableThree: "8142af86-79a1-44ba-89a5-05928e14a173",
      entityId: "513a4e22-ac98-4634-bdc2-1dc65ff774e5",
      message: 'hellow from table five ent=2',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final operationFive = Operation(
      id: "3e84f13c-f9eb-4f7f-93c9-2451473a8a5f",
      entityId: "513a4e22-ac98-4634-bdc2-1dc65ff774e5",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.create,
      table: DBTable.table_five,
      json: entityFive.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
    );

    // push operation to server
    final result = await pushSingleOperationUseCase.call(
      PushSingleOperationUseCaseParams(
        operation: operationFive,
        deviceId: deviceId,
      ),
    );
    result.fold(
      ifLeft: (err) {
        print('Error : pushing operation five to server');
        print(err);
      },
      ifRight: (e) {
        print('Success : pushing operation five to server');
        print(e);
      },
    );
  });
}
