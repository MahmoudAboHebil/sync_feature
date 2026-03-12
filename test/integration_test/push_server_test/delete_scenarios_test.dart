import 'package:flutter_test/flutter_test.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/enums/operation_status.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_one_datasource_impl.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/sync_datasource.dart';
import 'package:sync_feature/sync_engine/data/repository/queue_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/sync_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_five.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_two.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_entity_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_operation_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_table_queue_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/send_operation_to_server_usecase.dart';

void main() {
  test('1)Delete last node', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final queueRepository = QueueRepositoryImpl(queueDatasource);
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(queueDatasource);
    final queueRepo = QueueRepositoryImpl(queueDatasource);

    final syncRepository = SyncRepositoryImpl(
      tableRepository,
      syncDatasource,
      queueRepo,
    );
    final addEntityUseCase = AddEntityLocalUseCase(tableRepository);
    final addOperationUseCase = AddOperationLocalUseCase(queueRepository);
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepository);
    final pushSingleOperationUseCase = SendOperationToServerUseCase(
      syncRepository,
    );

    final entityFive = TableFive(
      forKeyTableFour: "a5053a65-26f6-4c7f-8887-b6b6fd88a595",
      forKeyTableThree: "8142af86-79a1-44ba-89a5-05928e14a173",
      entityId: "4080b569-9715-471d-bf8f-61ae352d2c4a",
      message: 'hellow from table five ent=2',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: true,
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final operationFive = Operation(
      id: "3e84f13c-f9eb-4f7f-93c9-2451473a8aff",
      entityId: "4080b569-9715-471d-bf8f-61ae352d2c4a",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.delete,
      table: DBTable.table_five,
      json: entityFive.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      lastAttemptAt: DateTime.now(),
      retryCount: 0,
      status: OperationState.pending,
    );

    // push operation to server
    final result = await pushSingleOperationUseCase.call(
      SendOperationToServerUseCaseParams(
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
  test('2)Delete 2 expect to delete (2,3,4,5)', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final queueRepository = QueueRepositoryImpl(queueDatasource);
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(queueDatasource);
    final queueRepo = QueueRepositoryImpl(queueDatasource);

    final syncRepository = SyncRepositoryImpl(
      tableRepository,
      syncDatasource,
      queueRepo,
    );
    final addEntityUseCase = AddEntityLocalUseCase(tableRepository);
    final addOperationUseCase = AddOperationLocalUseCase(queueRepository);
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepository);
    final pushSingleOperationUseCase = SendOperationToServerUseCase(
      syncRepository,
    );

    final entityTwo = TableTwo(
      forkeyTableOne: "c887ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      message: 'hellow from table two ent=2',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: true,
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final operationTwo = Operation(
      id: "7a0fa837-f47a-4df2-bec8-e29d3f2621e6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.delete,
      table: DBTable.table_two,
      json: entityTwo.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      lastAttemptAt: DateTime.now(),
      retryCount: 0,
      status: OperationState.pending,
    );

    // push operation to server
    final result = await pushSingleOperationUseCase.call(
      SendOperationToServerUseCaseParams(
        operation: operationTwo,
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
