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
import 'package:sync_feature/sync_engine/domain/entities/table_four.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_one.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_three.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_two.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_entity_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_operation_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_table_queue_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/push_single_table_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/send_operation_to_server_usecase.dart';

void main() {
  test('1) create NetworkSuccess', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(queueDatasource);
    final queueRepo = QueueRepositoryImpl(queueDatasource);
    final syncRepository = SyncRepositoryImpl(
      tableRepository,
      syncDatasource,
      queueRepo,
    );
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepo);
    final sendOperationToServerUseCase = SendOperationToServerUseCase(
      syncRepository,
    );
    final addOperationLocalUseCase = AddOperationLocalUseCase(queueRepo);
    final addEntityToLocalUseCase = AddEntityLocalUseCase(tableRepository);
    final pushSyncUseCase = PushSingleTableUseCase(
      queueRepo,
      tableRepository,
      getTableQueueUseCase,
      sendOperationToServerUseCase,
    );
    final tableOneEntity = TableOne(
      entityId: '969ca17b-64a6-4e6c-8cb2-40508480f0c1',
      message: 'hellow from table one',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final oneOperation = Operation(
      id: "9b9dcde8-f6ed-4837-9214-23bd54aa4b6f",
      entityId: '969ca17b-64a6-4e6c-8cb2-40508480f0c1',
      centerId: centerId,
      action: OperationAction.create,
      table: DBTable.table_one,
      json: tableOneEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );

    final tableTwoEntity = TableTwo(
      entityId: "111e188b-70ad-4c3a-818f-7aa5d9515bdc",
      forkeyTableOne: '969ca17b-64a6-4e6c-8cb2-40508480f0c1',
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final twoOperation = Operation(
      id: "155f3331-35d3-42d1-b6e8-c8fbc1b029f4",
      entityId: '111e188b-70ad-4c3a-818f-7aa5d9515bdc',
      centerId: centerId,
      action: OperationAction.create,
      table: DBTable.table_two,
      json: tableTwoEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );
    final tableThreeEntity = TableThree(
      entityId: "a01ecd92-e27b-46b6-9ee3-432b1f798bbe",
      forKeyTableTwo: "111e188b-70ad-4c3a-818f-7aa5d9515bdc",
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final threeOperation = Operation(
      id: "0c51dd6d-56b9-4662-80aa-c727765fc9aa",
      entityId: 'a01ecd92-e27b-46b6-9ee3-432b1f798bbe',
      centerId: centerId,
      action: OperationAction.create,
      table: DBTable.table_three,
      json: tableThreeEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );
    final tableFourEntity = TableFour(
      entityId: "2968e74e-a3f1-4fed-8796-91fd5ab3ee52",
      forKeyTableTwo: "111e188b-70ad-4c3a-818f-7aa5d9515bdc",
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final fourOperation = Operation(
      id: "de8135ad-51ef-4949-a883-dee39c18703c",
      entityId: '2968e74e-a3f1-4fed-8796-91fd5ab3ee52',
      centerId: centerId,
      action: OperationAction.create,
      table: DBTable.table_four,
      json: tableFourEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );
    final tableFiveEntity = TableFive(
      entityId: "e4e0ffca-18d0-4df6-ad40-d84307f9fcaa",
      forKeyTableThree: "a01ecd92-e27b-46b6-9ee3-432b1f798bbe",
      forKeyTableFour: "2968e74e-a3f1-4fed-8796-91fd5ab3ee52",
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final fiveOperation = Operation(
      id: "4d081ebc-ca14-411b-a8db-c6b10ea13a25",
      entityId: 'e4e0ffca-18d0-4df6-ad40-d84307f9fcaa',
      centerId: centerId,
      action: OperationAction.create,
      table: DBTable.table_five,
      json: tableFiveEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );

    //todo: add entity to local
    final oneResult = await addEntityToLocalUseCase.call(
      AddEntityLocalUseCaseParams(
        table: DBTable.table_one,
        jsonEntity: null,
        entity: tableOneEntity,
      ),
    );
    oneResult.fold(
      ifLeft: (err) {
        print('Error : add entity 1 on to local');
        print(err);
      },
      ifRight: (e) {
        print('Success : add entity 1 on to local');
      },
    );
    final twoResult = await addEntityToLocalUseCase.call(
      AddEntityLocalUseCaseParams(
        table: DBTable.table_two,
        jsonEntity: null,
        entity: tableTwoEntity,
      ),
    );
    twoResult.fold(
      ifLeft: (err) {
        print('Error : add entity 2 on to local');
        print(err);
      },
      ifRight: (e) {
        print('Success : add entity 2 on to local');
      },
    );
    final threeResult = await addEntityToLocalUseCase.call(
      AddEntityLocalUseCaseParams(
        table: DBTable.table_three,
        jsonEntity: null,
        entity: tableThreeEntity,
      ),
    );
    threeResult.fold(
      ifLeft: (err) {
        print('Error : add entity 3 on to local');
        print(err);
      },
      ifRight: (e) {
        print('Success : add entity 3 on to local');
      },
    );

    final fourResult = await addEntityToLocalUseCase.call(
      AddEntityLocalUseCaseParams(
        table: DBTable.table_four,
        jsonEntity: null,
        entity: tableFourEntity,
      ),
    );
    fourResult.fold(
      ifLeft: (err) {
        print('Error : add entity 4 on to local');
        print(err);
      },
      ifRight: (e) {
        print('Success : add entity 4 on to local');
      },
    );
    final fiveResult = await addEntityToLocalUseCase.call(
      AddEntityLocalUseCaseParams(
        table: DBTable.table_five,
        jsonEntity: null,
        entity: tableFiveEntity,
      ),
    );
    fiveResult.fold(
      ifLeft: (err) {
        print('Error : add entity 5 on to local');
        print(err);
      },
      ifRight: (e) {
        print('Success : add entity 5 on to local');
      },
    );

    //todo: add operation to queue
    final oneResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: oneOperation),
    );
    oneResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 1 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 1 to queue');
      },
    );

    final twoResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: twoOperation),
    );
    twoResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 2 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 2 to queue');
      },
    );
    final threeResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: threeOperation),
    );
    threeResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 3 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 3 to queue');
      },
    );
    final fourResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: fourOperation),
    );
    fourResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 4 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 4 to queue');
      },
    );
    final fiveResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: fiveOperation),
    );
    fiveResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 5 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 5 to queue');
      },
    );

    //todo: push operation to server
    final pushResult1 = await pushSyncUseCase.call(
      PushSingleTableUseCaseParams(
        table: DBTable.table_one,
        deviceId: deviceId,
      ),
    );
    pushResult1.fold(
      ifLeft: (err) {
        print('Error : push 1 to server');
        print(err);
      },
      ifRight: (e) {
        print(e);
        print('Success : push 1 to server');
      },
    );
  });
  test('2)Create 5 ( 3 is deleted at server )', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(queueDatasource);
    final queueRepo = QueueRepositoryImpl(queueDatasource);
    final syncRepository = SyncRepositoryImpl(
      tableRepository,
      syncDatasource,
      queueRepo,
    );
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepo);
    final sendOperationToServerUseCase = SendOperationToServerUseCase(
      syncRepository,
    );
    final addOperationLocalUseCase = AddOperationLocalUseCase(queueRepo);
    final addEntityToLocalUseCase = AddEntityLocalUseCase(tableRepository);
    final pushSyncUseCase = PushSingleTableUseCase(
      queueRepo,
      tableRepository,
      getTableQueueUseCase,
      sendOperationToServerUseCase,
    );

    final tableFiveEntity = TableFive(
      entityId: "e4e0ffca-18d0-4df6-ad40-d84307f9fcaa",
      forKeyTableThree: "a01ecd92-e27b-46b6-9ee3-432b1f798bbe",
      forKeyTableFour: "2968e74e-a3f1-4fed-8796-91fd5ab3ee52",
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final fiveOperation = Operation(
      id: "a6deebd4-afd9-4e56-ab0c-832e849173d9",
      entityId: 'e4e0ffca-18d0-4df6-ad40-d84307f9fcaa',
      centerId: centerId,
      action: OperationAction.create,
      table: DBTable.table_five,
      json: tableFiveEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );

    //todo: add entity to local
    final fiveResult = await addEntityToLocalUseCase.call(
      AddEntityLocalUseCaseParams(
        table: DBTable.table_five,
        jsonEntity: null,
        entity: tableFiveEntity,
      ),
    );
    fiveResult.fold(
      ifLeft: (err) {
        print('Error : add entity 5 on to local');
        print(err);
      },
      ifRight: (e) {
        print('Success : add entity 5 on to local');
      },
    );

    //todo: add operation to queue
    final fiveResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: fiveOperation),
    );
    fiveResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 5 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 5 to queue');
      },
    );

    //todo: push operation to server
    final pushResult1 = await pushSyncUseCase.call(
      PushSingleTableUseCaseParams(
        table: DBTable.table_five,
        deviceId: deviceId,
      ),
    );
    pushResult1.fold(
      ifLeft: (err) {
        print('Error : push 1 to server');
        print(err);
      },
      ifRight: (e) {
        print(e);
        print('Success : push 1 to server');
      },
    );
  });
  test('3)Delete last node', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(queueDatasource);
    final queueRepo = QueueRepositoryImpl(queueDatasource);
    final syncRepository = SyncRepositoryImpl(
      tableRepository,
      syncDatasource,
      queueRepo,
    );
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepo);
    final sendOperationToServerUseCase = SendOperationToServerUseCase(
      syncRepository,
    );
    final addOperationLocalUseCase = AddOperationLocalUseCase(queueRepo);
    final addEntityToLocalUseCase = AddEntityLocalUseCase(tableRepository);
    final pushSyncUseCase = PushSingleTableUseCase(
      queueRepo,
      tableRepository,
      getTableQueueUseCase,
      sendOperationToServerUseCase,
    );

    final tableFiveEntity = TableFive(
      entityId: "e4e0ffca-18d0-4df6-ad40-d84307f9fcaa",
      forKeyTableThree: "a01ecd92-e27b-46b6-9ee3-432b1f798bbe",
      forKeyTableFour: "2968e74e-a3f1-4fed-8796-91fd5ab3ee52",
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: true,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final fiveOperation = Operation(
      id: "58df6f69-5790-4032-a3a5-17002a1c8cf0",
      entityId: 'e4e0ffca-18d0-4df6-ad40-d84307f9fcaa',
      centerId: centerId,
      action: OperationAction.delete,
      table: DBTable.table_five,
      json: tableFiveEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );

    //todo: add operation to queue
    final fiveResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: fiveOperation),
    );
    fiveResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 5 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 5 to queue');
      },
    );

    //todo: push operation to server
    final pushResult1 = await pushSyncUseCase.call(
      PushSingleTableUseCaseParams(
        table: DBTable.table_five,
        deviceId: deviceId,
      ),
    );
    pushResult1.fold(
      ifLeft: (err) {
        print('Error : push 1 to server');
        print(err);
      },
      ifRight: (e) {
        print(e);
        print('Success : push 1 to server');
      },
    );
  });

  test('4)Delete 2 expect to delete (2,3,4,5)', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(queueDatasource);
    final queueRepo = QueueRepositoryImpl(queueDatasource);
    final syncRepository = SyncRepositoryImpl(
      tableRepository,
      syncDatasource,
      queueRepo,
    );
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepo);
    final sendOperationToServerUseCase = SendOperationToServerUseCase(
      syncRepository,
    );
    final addOperationLocalUseCase = AddOperationLocalUseCase(queueRepo);
    final addEntityToLocalUseCase = AddEntityLocalUseCase(tableRepository);
    final pushSyncUseCase = PushSingleTableUseCase(
      queueRepo,
      tableRepository,
      getTableQueueUseCase,
      sendOperationToServerUseCase,
    );

    final tableTwoEntity = TableTwo(
      entityId: "111e188b-70ad-4c3a-818f-7aa5d9515bdc",
      forkeyTableOne: '969ca17b-64a6-4e6c-8cb2-40508480f0c1',
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: true,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final twoOperation = Operation(
      id: "155f3331-35d3-42d1-b6e8-c8fbc1b029f4",
      entityId: '111e188b-70ad-4c3a-818f-7aa5d9515bdc',
      centerId: centerId,
      action: OperationAction.delete,
      table: DBTable.table_two,
      json: tableTwoEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );

    //todo: add operation to queue
    final fiveResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: twoOperation),
    );
    fiveResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 1 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 1 to queue');
      },
    );

    //todo: push operation to server
    final pushResult1 = await pushSyncUseCase.call(
      PushSingleTableUseCaseParams(
        table: DBTable.table_two,
        deviceId: deviceId,
      ),
    );
    pushResult1.fold(
      ifLeft: (err) {
        print('Error : push 1 to server');
        print(err);
      },
      ifRight: (e) {
        print(e);
        print('Success : push 1 to server');
      },
    );
  });
  test('5)2 Entity is deleted  expect to delete (2,3,4,5)', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(queueDatasource);
    final queueRepo = QueueRepositoryImpl(queueDatasource);
    final syncRepository = SyncRepositoryImpl(
      tableRepository,
      syncDatasource,
      queueRepo,
    );
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepo);
    final sendOperationToServerUseCase = SendOperationToServerUseCase(
      syncRepository,
    );
    final addOperationLocalUseCase = AddOperationLocalUseCase(queueRepo);
    final addEntityToLocalUseCase = AddEntityLocalUseCase(tableRepository);
    final pushSyncUseCase = PushSingleTableUseCase(
      queueRepo,
      tableRepository,
      getTableQueueUseCase,
      sendOperationToServerUseCase,
    );

    final tableTwoEntity = TableTwo(
      entityId: "111e188b-70ad-4c3a-818f-7aa5d9515bdc",
      forkeyTableOne: '969ca17b-64a6-4e6c-8cb2-40508480f0c1',
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final twoOperation = Operation(
      id: "155f3331-35d3-42d1-b6e8-c8fbc1b029f4",
      entityId: '111e188b-70ad-4c3a-818f-7aa5d9515bdc',
      centerId: centerId,
      action: OperationAction.update,
      table: DBTable.table_two,
      json: tableTwoEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );

    //todo: add operation to queue
    final fiveResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: twoOperation),
    );
    fiveResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 1 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 1 to queue');
      },
    );

    //todo: push operation to server
    final pushResult1 = await pushSyncUseCase.call(
      PushSingleTableUseCaseParams(
        table: DBTable.table_two,
        deviceId: deviceId,
      ),
    );
    pushResult1.fold(
      ifLeft: (err) {
        print('Error : push 1 to server');
        print(err);
      },
      ifRight: (e) {
        print(e);
        print('Success : push 1 to server');
      },
    );
  });
  test('6)version conflict when (op.version < entity.version)', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(queueDatasource);
    final queueRepo = QueueRepositoryImpl(queueDatasource);
    final syncRepository = SyncRepositoryImpl(
      tableRepository,
      syncDatasource,
      queueRepo,
    );
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepo);
    final sendOperationToServerUseCase = SendOperationToServerUseCase(
      syncRepository,
    );
    final addOperationLocalUseCase = AddOperationLocalUseCase(queueRepo);
    final addEntityToLocalUseCase = AddEntityLocalUseCase(tableRepository);
    final pushSyncUseCase = PushSingleTableUseCase(
      queueRepo,
      tableRepository,
      getTableQueueUseCase,
      sendOperationToServerUseCase,
    );

    final tableTwoEntity = TableTwo(
      entityId: "111e188b-70ad-4c3a-818f-7aa5d9515bdc",
      forkeyTableOne: '969ca17b-64a6-4e6c-8cb2-40508480f0c1',
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final twoOperation = Operation(
      id: "155f3331-35d3-42d1-b6e8-c8fbc1b029f4",
      entityId: '111e188b-70ad-4c3a-818f-7aa5d9515bdc',
      centerId: centerId,
      action: OperationAction.update,
      table: DBTable.table_two,
      json: tableTwoEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );

    //todo: add operation to queue
    final fiveResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: twoOperation),
    );
    fiveResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 1 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 1 to queue');
      },
    );

    //todo: push operation to server
    final pushResult1 = await pushSyncUseCase.call(
      PushSingleTableUseCaseParams(
        table: DBTable.table_two,
        deviceId: deviceId,
      ),
    );
    pushResult1.fold(
      ifLeft: (err) {
        print('Error : push 1 to server');
        print(err);
      },
      ifRight: (e) {
        print(e);
        print('Success : push 1 to server');
      },
    );
  });
  test('7)updated 5 ( 3 is deleted at server )', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(queueDatasource);
    final queueRepo = QueueRepositoryImpl(queueDatasource);
    final syncRepository = SyncRepositoryImpl(
      tableRepository,
      syncDatasource,
      queueRepo,
    );
    final getTableQueueUseCase = GetTableQueueUseCase(queueRepo);
    final sendOperationToServerUseCase = SendOperationToServerUseCase(
      syncRepository,
    );
    final addOperationLocalUseCase = AddOperationLocalUseCase(queueRepo);
    final addEntityToLocalUseCase = AddEntityLocalUseCase(tableRepository);
    final pushSyncUseCase = PushSingleTableUseCase(
      queueRepo,
      tableRepository,
      getTableQueueUseCase,
      sendOperationToServerUseCase,
    );

    final tableFiveEntity = TableFive(
      entityId: "e4e0ffca-18d0-4df6-ad40-d84307f9fcaa",
      forKeyTableThree: "a01ecd92-e27b-46b6-9ee3-432b1f798bbe",
      forKeyTableFour: "2968e74e-a3f1-4fed-8796-91fd5ab3ee52",
      message: 'hellow from table two',
      centerId: centerId,
      byUser: currentUser,
      byDevice: deviceId,
      isDeleted: false,
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final fiveOperation = Operation(
      id: "4d081ebc-ca14-411b-a8db-c6b10ea13a25",
      entityId: 'e4e0ffca-18d0-4df6-ad40-d84307f9fcaa',
      centerId: centerId,
      action: OperationAction.update,
      table: DBTable.table_five,
      json: tableFiveEntity.toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastAttemptAt: DateTime.now(),
      nextRetryAt: DateTime.now(),
      status: OperationState.pending,
    );

    //todo: add operation to queue
    final fiveResultOpera = await addOperationLocalUseCase.call(
      AddOperationLocalUseCaseParams(operation: fiveOperation),
    );
    fiveResultOpera.fold(
      ifLeft: (err) {
        print('Error : add oper 1 to queue');
        print(err);
      },
      ifRight: (e) {
        print('Success : add oper 1 to queue');
      },
    );

    //todo: push operation to server
    final pushResult1 = await pushSyncUseCase.call(
      PushSingleTableUseCaseParams(
        table: DBTable.table_two,
        deviceId: deviceId,
      ),
    );
    pushResult1.fold(
      ifLeft: (err) {
        print('Error : push 1 to server');
        print(err);
      },
      ifRight: (e) {
        print(e);
        print('Success : push 1 to server');
      },
    );
  });
}
