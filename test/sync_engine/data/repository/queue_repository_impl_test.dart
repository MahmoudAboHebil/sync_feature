import 'dart:convert';

import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/enums/user_role.dart';
import 'package:sync_feature/core/isar_service/collections/operation_collection.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/models/operation_model.dart';
import 'package:sync_feature/sync_engine/data/repository/queue_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';

class MockLocalDataSource extends Mock implements LocalQueueDatasource {}

void main() {
  late QueueRepositoryImpl repository;
  late MockLocalDataSource mockLocal;
  setUp(() {
    mockLocal = MockLocalDataSource();
    repository = QueueRepositoryImpl(mockLocal);
  });

  test(
    'should add Operation to Queue without remove other operations( if there are no operation related entity in queue)',
    () async {
      final List<OperationCollection> mainQueue = [
        OperationCollection()
          ..operationId = 'oper-1'
          ..entityId = 'enti-1'
          ..centerId = 'center-1'
          ..action = 'create'
          ..table = "table1"
          ..version = 1
          ..userRole = "admin"
          ..createdBy = "ahmed"
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

      final operation = Operation(
        id: 'oper-3',
        entityId: 'enti-3',
        centerId: 'center-1',
        action: OperationAction.create,
        table: DBTable.table_two,
        json: {
          'id': 'enti-3',
          'data': 0,
          'version': 1,
          'by_user': "ahmed",
          'is_deleted': false,
          'centerId': "center-1",
          'by_device': 'device-1',
          'updated_at': DateTime(2026, 2, 1, 2).toIso8601String(),
          'created_at': DateTime(2026, 2, 1, 2).toIso8601String(),
        },
        version: 1,
        userRole: UserRole.admin,
        createdBy: 'ahmed',
        createdAt: DateTime(2026, 2, 1, 2),
      );

      when(
        () => mockLocal.removeOperationsByEntity(operation.entityId),
      ).thenAnswer((_) async {
        mainQueue.removeWhere((oper) => oper.entityId == operation.entityId);
      });

      when(
        () => mockLocal.insertToQueue(OperationModel.fromOperation(operation)),
      ).thenAnswer((_) async {
        mainQueue.add(OperationModel.fromOperation(operation).toCollection());
      });
      final result = await repository.addOperationToQueue(operation);
      expect(mainQueue.length, 3);
      verify(
        () => mockLocal.removeOperationsByEntity(operation.entityId),
      ).called(1);
      verify(
        () => mockLocal.insertToQueue(OperationModel.fromOperation(operation)),
      ).called(1);
    },
  );
  test(
    'should add Operation to Queue with remove ( if there are  operation related entity in queue)',
    () async {
      final List<OperationCollection> mainQueue = [
        OperationCollection()
          ..operationId = 'oper-1'
          ..entityId = 'enti-1'
          ..centerId = 'center-1'
          ..action = 'create'
          ..table = "table1"
          ..version = 1
          ..userRole = "admin"
          ..createdBy = "ahmed"
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

      final operation = Operation(
        id: 'oper-4',
        entityId: 'enti-2',
        centerId: 'center-1',
        action: OperationAction.update,
        table: DBTable.table_two,
        json: {
          'id': 'enti-2',
          'data': 0,
          'version': 1,
          'by_user': "ahmed",
          'is_deleted': false,
          'centerId': "center-1",
          'by_device': 'device-1',
          'updated_at': DateTime(2026, 2, 1, 2).toIso8601String(),
          'created_at': DateTime(2026, 2, 1, 2).toIso8601String(),
        },
        version: 1,
        userRole: UserRole.admin,
        createdBy: 'ahmed',
        createdAt: DateTime(2026, 2, 1, 2),
      );

      when(
        () => mockLocal.removeOperationsByEntity(operation.entityId),
      ).thenAnswer((_) async {
        mainQueue.removeWhere((oper) => oper.entityId == operation.entityId);
      });

      when(
        () => mockLocal.insertToQueue(OperationModel.fromOperation(operation)),
      ).thenAnswer((_) async {
        mainQueue.add(OperationModel.fromOperation(operation).toCollection());
      });
      final result = await repository.addOperationToQueue(operation);
      expect(mainQueue.length, 2);
      verify(
        () => mockLocal.removeOperationsByEntity(operation.entityId),
      ).called(1);
      verify(
        () => mockLocal.insertToQueue(OperationModel.fromOperation(operation)),
      ).called(1);
    },
  );

  test(
    'should do not add Operation to Queue (entity operation which has is_deleted=true && operation type update)',
    () async {
      final List<OperationCollection> mainQueue = [
        OperationCollection()
          ..operationId = 'oper-1'
          ..entityId = 'enti-1'
          ..centerId = 'center-1'
          ..action = 'create'
          ..table = "table1"
          ..version = 1
          ..userRole = "admin"
          ..createdBy = "ahmed"
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
          ..action = 'delete'
          ..table = "table2"
          ..version = 1
          ..userRole = "admin"
          ..createdBy = "ahmed"
          ..payload = jsonEncode({
            'id': 'enti-2',
            'data': 0,
            'version': 1,
            'by_user': "ahmed",
            'is_deleted': true,
            'centerId': "center-1",
            'by_device': 'device-1',
            'updated_at': DateTime(2026, 2, 1, 1).toIso8601String(),
            'created_at': DateTime(2026, 2, 1, 1).toIso8601String(),
          })
          ..createdAt = DateTime(2026, 2, 1, 1),
        //------------------------------------------------
      ];

      final operation = Operation(
        id: 'oper-5',
        entityId: 'enti-2',
        centerId: 'center-1',
        action: OperationAction.update,
        table: DBTable.table_two,
        json: {
          'id': 'enti-2',
          'data': 0,
          'version': 1,
          'by_user': "ahmed",
          'is_deleted': true,
          'centerId': "center-1",
          'by_device': 'device-1',
          'updated_at': DateTime(2026, 2, 1, 2).toIso8601String(),
          'created_at': DateTime(2026, 2, 1, 2).toIso8601String(),
        },
        version: 1,
        userRole: UserRole.admin,
        createdBy: 'ahmed',
        createdAt: DateTime(2026, 2, 1, 2),
      );

      when(
        () => mockLocal.removeOperationsByEntity(operation.entityId),
      ).thenAnswer((_) async {
        mainQueue.removeWhere((oper) => oper.entityId == operation.entityId);
      });

      when(
        () => mockLocal.insertToQueue(OperationModel.fromOperation(operation)),
      ).thenAnswer((_) async {
        mainQueue.add(OperationModel.fromOperation(operation).toCollection());
      });
      final result = await repository.addOperationToQueue(operation);
      expect(mainQueue.length, 2);
      verifyNever(() => mockLocal.removeOperationsByEntity(operation.entityId));
      verifyNever(
        () => mockLocal.insertToQueue(OperationModel.fromOperation(operation)),
      );
    },
  );
  test('get table operation queue', () async {
    final List<OperationCollection> mainQueue = [
      OperationCollection()
        ..operationId = 'oper-1'
        ..entityId = 'enti-1'
        ..centerId = 'center-1'
        ..action = 'create'
        ..table = "table1"
        ..version = 1
        ..userRole = "admin"
        ..createdBy = "ahmed"
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
        ..action = 'delete'
        ..table = "table2"
        ..version = 1
        ..userRole = "admin"
        ..createdBy = "ahmed"
        ..payload = jsonEncode({
          'id': 'enti-2',
          'data': 0,
          'version': 1,
          'by_user': "ahmed",
          'is_deleted': true,
          'centerId': "center-1",
          'by_device': 'device-1',
          'updated_at': DateTime(2026, 2, 1, 1).toIso8601String(),
          'created_at': DateTime(2026, 2, 1, 1).toIso8601String(),
        })
        ..createdAt = DateTime(2026, 2, 1, 1),
      //------------------------------------------------
      OperationCollection()
        ..operationId = 'oper-7'
        ..entityId = 'enti-6'
        ..centerId = 'center-1'
        ..action = 'update'
        ..table = "table2"
        ..version = 1
        ..userRole = "admin"
        ..createdBy = "ahmed"
        ..payload = jsonEncode({
          'id': 'enti-6',
          'data': 0,
          'version': 1,
          'by_user': "ahmed",
          'is_deleted': true,
          'centerId': "center-1",
          'by_device': 'device-1',
          'updated_at': DateTime(2026, 2, 1, 0).toIso8601String(),
          'created_at': DateTime(2026, 2, 1, 0).toIso8601String(),
        })
        ..createdAt = DateTime(2026, 2, 1, 0),
    ];

    when(
      () => mockLocal.getPendingTableOperationAscending(DBTable.table_two),
    ).thenAnswer((_) async {
      final list = mainQueue.where((coll) {
        return coll.table == DBTable.table_two.name;
      }).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final operationsModels = list
          .map((coll) => OperationModel.fromCollection(coll))
          .toList();
      return operationsModels;
    });
    final result = await repository.getPendingOperationOrdered(
      DBTable.table_two,
    );
    expect(result.getOrThrow().length, 2);
    expect(result.getOrThrow().first.id, 'oper-7');
    verify(
      () => mockLocal.getPendingTableOperationAscending(DBTable.table_two),
    );
  });
}
