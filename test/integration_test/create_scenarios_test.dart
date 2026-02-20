import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/enums/user_role.dart';
import 'package:sync_feature/core/helper.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_one_datasource_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/queue_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/sync_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_five.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_three.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_entity_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_operation_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_table_queue_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/push_single_operation_usecase.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('1)Create (first Node)', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final tableRepository = TableRepositoryImpl(
      queueDatasource,
      tableDatasource,
    );
    final syncRepository = SyncRepositoryImpl(tableRepository);
    final token = await Helper.login('testone@gmail.com', 'testone@gmail.com');
    final entityId = "4080b569-9715-471d-bf8f-61ae352d2c4a";
    final centerId = "5d242021-432d-41ea-ac04-fba60e368fd3";
    final operationId = "0739bf25-55e8-492c-9d97-eb2612380eb9";
    final entity = TableFive(
      forKeyTableThree: "8142af86-79a1-44ba-89a5-05928e14a173",
      forKeyTableFour: "a5053a65-26f6-4c7f-8887-b6b6fd88a595",
      entityId: entityId,
      message: 'hellow from table five',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // add to local
    final params = AddEntityLocalUseCaseParams(
      table: DBTable.table_five,
      jsonEntity: null,
      entity: entity,
    );
    final useCase = AddEntityLocalUseCase(tableRepository);
    final result = await useCase.call(params);
    result.fold(
      ifLeft: (err) {
        print('Entity is Not Add');
        print(err);
      },
      ifRight: (d) async {
        print('Entity is Added to Local Db');
        final operation = Operation(
          id: operationId,
          entityId: entityId,
          centerId: centerId,
          action: OperationAction.create,
          table: DBTable.table_five,
          json: entity.toJson(),
          version: 1,
          userRole: currentUserRole,
          createdBy: currentUser,
          createdAt: DateTime.now(),
        );
        final pushParams = PushSingleOperationUseCaseParams(
          operation: operation,
        );
        final pushUseCase = PushSingleOperationUseCase(syncRepository);
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
      },
    );
  });
  test('3)Create 5 ( 3 not created at server yet % at QUEUE %)', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final queueRepository = QueueRepositoryImpl(queueDatasource);
    final tableRepository = TableRepositoryImpl(
      queueDatasource,
      tableDatasource,
    );
    final syncRepository = SyncRepositoryImpl(tableRepository);
    final addEntityUseCase = AddEntityLocalUseCase(tableRepository);
    final addOperationUseCase = AddOperationLocalUseCase(queueRepository);
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepository);
    final pushSingleOperationUseCase = PushSingleOperationUseCase(
      syncRepository,
    );

    final entityThree = TableThree(
      forKeyTableTwo: "811100ea-4383-4710-a6e6-9fee6b61034d",
      entityId: '81d43683-ea57-4fc8-a489-f5c34e72b62c',
      message: 'hellow from table three ent=2',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final operationThree = Operation(
      id: "3e82f13c-f9eb-4f7f-93c9-2451473a8a5f",
      entityId: '81d43683-ea57-4fc8-a489-f5c34e72b62c',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.create,
      table: DBTable.table_three,
      json: entityThree.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
    );

    final entityFive = TableFive(
      forKeyTableFour: "a5053a65-26f6-4c7f-8887-b6b6fd88a595",
      forKeyTableThree: "81d43683-ea57-4fc8-a489-f5c34e72b62c",
      entityId: "0f55ec9b-f1e6-4274-817a-b287cf846a64",
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
      entityId: "0f55ec9b-f1e6-4274-817a-b287cf846a64",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.create,
      table: DBTable.table_five,
      json: entityFive.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
    );

    // adding entities to local data base

    final addThreeEntityResult = await addEntityUseCase.call(
      AddEntityLocalUseCaseParams(
        table: DBTable.table_three,
        jsonEntity: null,
        entity: entityThree,
      ),
    );
    await addThreeEntityResult.fold(
      ifLeft: (err) {
        print('Failed : Adding Three Entity');
        print(err);
      },
      ifRight: (e) {
        print('Success : Adding Three Entity');
      },
    );
    final addFiveEntityResult = await addEntityUseCase.call(
      AddEntityLocalUseCaseParams(
        table: DBTable.table_five,
        jsonEntity: null,
        entity: entityFive,
      ),
    );
    await addFiveEntityResult.fold(
      ifLeft: (err) {
        print('Failed : Adding Five Entity');
        print(err);
      },
      ifRight: (e) {
        print('Success : Adding Five Entity');
      },
    );

    // adding operation to local data base

    final addThreeOperResult = await addOperationUseCase.call(
      AddOperationLocalUseCaseParams(operation: operationThree),
    );
    await addThreeOperResult.fold(
      ifLeft: (err) {
        print('Failed : Adding three operation');
        print(err);
      },
      ifRight: (e) {
        print('Success : Adding three operation');
      },
    );
    final addFiveOperResult = await addOperationUseCase.call(
      AddOperationLocalUseCaseParams(operation: operationFive),
    );
    await addFiveOperResult.fold(
      ifLeft: (err) {
        print('Failed : Adding Five operation');
        print(err);
      },
      ifRight: (e) {
        print('Success : Adding Five operation');
      },
    );

    // get Table Three Operation Queue and Push

    final getTableThreeResult = await getTableQueueUseCase.call(
      GetTableQueueUseCaseParams(table: DBTable.table_three),
    );
    await getTableThreeResult.fold(
      ifLeft: (err) {
        print('Failed : getting Table Three Queue');
        print(err);
      },
      ifRight: (queue) async {
        print('Success : getting Table Three Queue');

        for (final operation in queue) {
          final result = await pushSingleOperationUseCase.call(
            PushSingleOperationUseCaseParams(operation: operation),
          );
          await result.fold(
            ifLeft: (err) {
              print('Failed : pushing Table three operation ');
              print(err);
            },
            ifRight: (e) {
              print('Success : pushing Table three operation');
            },
          );
        }
      },
    );

    // get Table Three Operation Queue and Push

    final getTableFiveResult = await getTableQueueUseCase.call(
      GetTableQueueUseCaseParams(table: DBTable.table_five),
    );
    await getTableFiveResult.fold(
      ifLeft: (err) {
        print('Failed : getting Table Five Queue');
        print(err);
      },
      ifRight: (queue) async {
        print('Success :  getting Table Five Queue');

        for (final operation in queue) {
          final result = await pushSingleOperationUseCase.call(
            PushSingleOperationUseCaseParams(operation: operation),
          );
          result.fold(
            ifLeft: (err) {
              print('Failed : pushing Table Five operation ');
              print(err);
            },
            ifRight: (e) {
              print('Success : pushing Table Five operation');
            },
          );
        }
      },
    );
  });
}
