import 'package:flutter_test/flutter_test.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/repository/queue_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_five.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_operation_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_table_queue_usecase.dart';

void main() {
  test('1) [create] & oper=update => [create,update]', () async {
    final queueDataSource = LocalQueueDatasource();
    final queueRepo = QueueRepositoryImpl(queueDataSource);
    final addUseCase = AddOperationLocalUseCase(queueRepo);
    final getUseCase = GetTableQueueUseCase(queueRepo);
    final entityData = DateTime.now().toUtc();
    final entityTwo = TableFive(
      forKeyTableThree: "x3x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      forKeyTableFour: "x4x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      message: 'hellow from table five 1',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: entityData,
      updatedAt: entityData,
    );
    print('entity_data= $entityData');
    final operationFive = Operation(
      id: "7a0fa837-f47a-4df2-bec8-e29d3f2621e6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.create,
      table: DBTable.table_five,
      json: entityTwo.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: entityData,
    );

    final addParams = AddOperationLocalUseCaseParams(operation: operationFive);
    final getParams = GetTableQueueUseCaseParams(table: DBTable.table_five);
    final result = await addUseCase.call(addParams);
    await result.fold(
      ifLeft: (err) {
        print('Error: add operation to queue');
        print(err);
      },
      ifRight: (d) async {
        print('Success: add operation to queue');
        final result = await getUseCase.call(getParams);
        result.fold(
          ifLeft: (err) {
            print('Error: get Queue operations');
            print(err);
          },
          ifRight: (data) {
            print('Success: get Queue operations');
            for (var d in data) {
              print('ddddddddddddddddddddddddddddd');
              print("oper_data: ${d.createdAt}");
              print("entity_id: ${d.json['id']}");
              print("entity_data: ${d.json['created_at']}");
            }
          },
        );
      },
    );
  });
  test('2) [create,updated1] & oper=update2 => [create,update2]', () async {
    final queueDataSource = LocalQueueDatasource();
    final queueRepo = QueueRepositoryImpl(queueDataSource);
    final addUseCase = AddOperationLocalUseCase(queueRepo);
    final getUseCase = GetTableQueueUseCase(queueRepo);
    final entityData = DateTime.now().toUtc();
    final entityTwo = TableFive(
      forKeyTableThree: "x3x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      forKeyTableFour: "x4x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      message: 'hellow from table five 1',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: entityData,
      updatedAt: entityData,
    );
    print('entity_data= $entityData');
    final operationFive = Operation(
      id: "7a0fa837-f47a-4df2-bec8-e29d3f2621e6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.create,
      table: DBTable.table_five,
      json: entityTwo.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: entityData,
    );

    final addParams = AddOperationLocalUseCaseParams(operation: operationFive);
    final getParams = GetTableQueueUseCaseParams(table: DBTable.table_five);
    final result = await addUseCase.call(addParams);
    await result.fold(
      ifLeft: (err) {
        print('Error: add operation to queue');
        print(err);
      },
      ifRight: (d) async {
        print('Success: add operation to queue');
        final result = await getUseCase.call(getParams);
        result.fold(
          ifLeft: (err) {
            print('Error: get Queue operations');
            print(err);
          },
          ifRight: (data) {
            print('Success: get Queue operations');
            for (var d in data) {
              print('ddddddddddddddddddddddddddddd');
              print("oper_data: ${d.createdAt}");
              print("entity_id: ${d.json['id']}");
              print("entity_data: ${d.json['created_at']}");
            }
          },
        );
      },
    );
  });
  test('3) [create] & oper=delete => []', () async {
    final queueDataSource = LocalQueueDatasource();
    final queueRepo = QueueRepositoryImpl(queueDataSource);
    final addUseCase = AddOperationLocalUseCase(queueRepo);
    final getUseCase = GetTableQueueUseCase(queueRepo);
    final entityData = DateTime.now().toUtc();
    final entityTwo = TableFive(
      forKeyTableThree: "x3x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      forKeyTableFour: "x4x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      message: 'hellow from table five 1',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: entityData,
      updatedAt: entityData,
    );
    print('entity_data= $entityData');
    final operationFive = Operation(
      id: "7a0fa837-f47a-4df2-bec8-e29d3f2621e6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.create,
      table: DBTable.table_five,
      json: entityTwo.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: entityData,
    );

    final addParams = AddOperationLocalUseCaseParams(operation: operationFive);
    final getParams = GetTableQueueUseCaseParams(table: DBTable.table_five);
    final result = await addUseCase.call(addParams);
    await result.fold(
      ifLeft: (err) {
        print('Error: add operation to queue');
        print(err);
      },
      ifRight: (d) async {
        print('Success: add operation to queue');
        final result = await getUseCase.call(getParams);
        result.fold(
          ifLeft: (err) {
            print('Error: get Queue operations');
            print(err);
          },
          ifRight: (data) {
            print('Success: get Queue operations');
            for (var d in data) {
              print('ddddddddddddddddddddddddddddd');
              print("oper_data: ${d.createdAt}");
              print("entity_id: ${d.json['id']}");
              print("entity_data: ${d.json['created_at']}");
            }
          },
        );
      },
    );
  });
  test('4) (is_deleted=true) & oper=update => []', () async {
    final queueDataSource = LocalQueueDatasource();
    final queueRepo = QueueRepositoryImpl(queueDataSource);
    final addUseCase = AddOperationLocalUseCase(queueRepo);
    final getUseCase = GetTableQueueUseCase(queueRepo);
    final entityData = DateTime.now().toUtc();
    final entityTwo = TableFive(
      forKeyTableThree: "x3x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      forKeyTableFour: "x4x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      message: 'hellow from table five 1',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: entityData,
      updatedAt: entityData,
    );
    print('entity_data= $entityData');
    final operationFive = Operation(
      id: "7a0fa837-f47a-4df2-bec8-e29d3f2621e6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.create,
      table: DBTable.table_five,
      json: entityTwo.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: entityData,
    );

    final addParams = AddOperationLocalUseCaseParams(operation: operationFive);
    final getParams = GetTableQueueUseCaseParams(table: DBTable.table_five);
    final result = await addUseCase.call(addParams);
    await result.fold(
      ifLeft: (err) {
        print('Error: add operation to queue');
        print(err);
      },
      ifRight: (d) async {
        print('Success: add operation to queue');
        final result = await getUseCase.call(getParams);
        result.fold(
          ifLeft: (err) {
            print('Error: get Queue operations');
            print(err);
          },
          ifRight: (data) {
            print('Success: get Queue operations');
            for (var d in data) {
              print('ddddddddddddddddddddddddddddd');
              print("oper_data: ${d.createdAt}");
              print("entity_id: ${d.json['id']}");
              print("entity_data: ${d.json['created_at']}");
            }
          },
        );
      },
    );
  });
  test('5) normal => remove All => add to queue', () async {
    final queueDataSource = LocalQueueDatasource();
    final queueRepo = QueueRepositoryImpl(queueDataSource);
    final addUseCase = AddOperationLocalUseCase(queueRepo);
    final getUseCase = GetTableQueueUseCase(queueRepo);
    final entityData = DateTime.now().toUtc();
    final entityTwo = TableFive(
      forKeyTableThree: "x3x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      forKeyTableFour: "x4x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      message: 'hellow from table five 1',
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: entityData,
      updatedAt: entityData,
    );
    print('entity_data= $entityData');
    final operationFive = Operation(
      id: "7a0fa837-f47a-4df2-bec8-e29d3f2621e6",
      entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
      centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
      action: OperationAction.create,
      table: DBTable.table_five,
      json: entityTwo.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: entityData,
    );

    final addParams = AddOperationLocalUseCaseParams(operation: operationFive);
    final getParams = GetTableQueueUseCaseParams(table: DBTable.table_five);
    final result = await addUseCase.call(addParams);
    await result.fold(
      ifLeft: (err) {
        print('Error: add operation to queue');
        print(err);
      },
      ifRight: (d) async {
        print('Success: add operation to queue');
        final result = await getUseCase.call(getParams);
        result.fold(
          ifLeft: (err) {
            print('Error: get Queue operations');
            print(err);
          },
          ifRight: (data) {
            print('Success: get Queue operations');
            for (var d in data) {
              print('ddddddddddddddddddddddddddddd');
              print("oper_data: ${d.createdAt}");
              print("entity_id: ${d.json['id']}");
              print("entity_data: ${d.json['created_at']}");
            }
          },
        );
      },
    );
  });
}
