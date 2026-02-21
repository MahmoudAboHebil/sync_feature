import 'dart:collection';

import 'package:dart_either/dart_either.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/core/error/netwrok_response.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_five.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_four.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_one.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_three.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_two.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';

import '../../../core/helper.dart';
import '../../../main.dart';
import '../../domain/entities/operation.dart';
import '../../domain/entities/standard_table_record.dart';
import '../data_source/local/local_table_five_datasource_impl.dart';
import '../data_source/local/local_table_four_datasource_impl.dart';
import '../data_source/local/local_table_one_datasource_impl.dart';
import '../data_source/local/local_table_three_datasource_impl.dart';
import '../data_source/local/local_table_two_datasource_impl.dart';
import '../models/operation_model.dart';
import '../models/standard_table_record_model.dart';
import '../models/table_five_model.dart';
import '../models/table_four_model.dart';
import '../models/table_one_model.dart';
import '../models/table_three_model.dart';
import '../models/table_two_model.dart';

class TableRepositoryImpl implements TableRepository {
  final LocalQueueDatasource _queueDatasource;
  final LocalTableDatasource _localTableDatasource;
  TableRepositoryImpl(this._queueDatasource, this._localTableDatasource);

  LocalTableDatasource _getTableDataSource(DBTable table) {
    if (table == DBTable.table_one) {
      return LocalTableOneDatasource();
    } else if (table == DBTable.table_two) {
      return LocalTableTwoDatasource();
    } else if (table == DBTable.table_three) {
      return LocalTableThreeDatasource();
    } else if (table == DBTable.table_four) {
      return LocalTableFourDatasource();
    } else if (table == DBTable.table_five) {
      return LocalTableFiveDatasource();
    } else {
      throw Exception(
        'there is not datasource file for this ${table.name} table',
      );
    }
  }

  StandardTableRecordModel _getTableModel(
    DBTable table,
    Map<String, dynamic> jsonModel,
  ) {
    if (table == DBTable.table_one) {
      return TableOneModel.fromJson(jsonModel);
    } else if (table == DBTable.table_two) {
      return TableTwoModel.fromJson(jsonModel);
    } else if (table == DBTable.table_three) {
      return TableThreeModel.fromJson(jsonModel);
    } else if (table == DBTable.table_four) {
      return TableFourModel.fromJson(jsonModel);
    } else if (table == DBTable.table_five) {
      return TableFiveModel.fromJson(jsonModel);
    } else {
      throw Exception('there is not model file for this ${table.name} table');
    }
  }

  Map<DBTable, List<String>> _getForginKeysIds(
    DBTable table,
    Operation operation,
  ) {
    if (table == DBTable.table_one) {
      return {};
    } else if (table == DBTable.table_two) {
      final model = _getTableModel(table, operation.json) as TableTwoModel;
      return {
        DBTable.table_one: [model.forkeyTableOne],
      };
    } else if (table == DBTable.table_three) {
      final model = _getTableModel(table, operation.json) as TableThreeModel;
      return {
        DBTable.table_two: [model.forKeyTableTwo],
      };
    } else if (table == DBTable.table_four) {
      final model = _getTableModel(table, operation.json) as TableFourModel;
      return {
        DBTable.table_two: [model.forKeyTableTwo],
      };
    } else if (table == DBTable.table_five) {
      final model = _getTableModel(table, operation.json) as TableFiveModel;
      return {
        DBTable.table_three: [model.forKeyTableThree],
        DBTable.table_four: [model.forKeyTableFour],
      };
    } else {
      return {};
    }
  }

  StandardTableRecordModel _getTableModelFromEntity(
    DBTable table,
    StandardTableRecord entity,
  ) {
    if (table == DBTable.table_one) {
      return TableOneModel.fromEntity(entity as TableOne);
    } else if (table == DBTable.table_two) {
      return TableTwoModel.fromEntity(entity as TableTwo);
    } else if (table == DBTable.table_three) {
      return TableThreeModel.fromEntity(entity as TableThree);
    } else if (table == DBTable.table_four) {
      return TableFourModel.fromEntity(entity as TableFour);
    } else if (table == DBTable.table_five) {
      return TableFiveModel.fromEntity(entity as TableFive);
    } else {
      throw Exception('there is not model  for this ${table.name} table');
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntityCascadeNotNull(
    DBTable startTable,
    String entityId, {
    bool test = false,
  }) async {
    try {
      final result = await getForwardRecursiveRelationsIds(
        startTable,
        entityId,
        test: test,
      );
      Map<DBTable, List<String>> tableEntityRemoveIds = result.getOrThrow();
      //todo: delete subs  from db && queue
      for (final tab in tableEntityRemoveIds.entries) {
        final table = tab.key;
        final ids = tab.value;
        final dataSource = _getTableDataSource(table);
        await dataSource.softDeleteEntities(ids.toList());
        await _queueDatasource.removeOperationsByEntitiesIds(ids.toList());
      }
      //todo: delete main  from db
      final dataSource = _getTableDataSource(startTable);
      await dataSource.softDelete(entityId);
      return Right(null);
    } catch (e) {
      return Left(ProcessingFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> replaceEntityLocalWithServer(
    DBTable table,
    Map<String, dynamic> json,
  ) async {
    try {
      final model = _getTableModel(table, json);
      final dataSource = _getTableDataSource(table);
      await dataSource.updateEntity(model);
      return Right(null);
    } catch (e) {
      return Left(ProcessingFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getEntityFromTable(
    DBTable table,
    String entityId,
  ) async {
    try {
      final dataSource = _getTableDataSource(table);
      final model = await dataSource.getEntity(entityId);
      if (model == null) return Right(null);

      return Right(model.toJson());
    } catch (e) {
      return Left(ProcessingFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUpdatedServerEntities(
    DBTable table,
    String deviceId,
    DateTime lastTimeSync,
    String centerId,
  ) async {
    try {
      final response = await supabase
          .from(table.name)
          .select()
          .eq('center_id', centerId)
          .gt('push_time', lastTimeSync)
          .neq('by_device', deviceId);
      return Right(response);
    } catch (e) {
      return Left(ProcessingFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> insertEntityToTable(
    DBTable table,
    Map<String, dynamic>? jsonEntity,
    StandardTableRecord? entity,
  ) async {
    try {
      final model;
      if (entity != null) {
        model = _getTableModelFromEntity(table, entity);
      } else {
        model = _getTableModel(table, jsonEntity!);
      }
      final dataSource = _getTableDataSource(table);
      await dataSource.insertEntity(model);
      return Right(null);
    } catch (e) {
      return Left(ProcessingFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NetworkResponse>> sendOperationToServer(
    Operation operation,
    String deviceId,
  ) async {
    Map<String, dynamic> recursiveForwardRelationsIds = {};

    Map<String, dynamic> recursiveBackwordRelationsIds = {};

    final forward = await getForwardRecursiveRelationsIds(
      operation.table,
      operation.entityId,
    );
    final forwardResult = forward.getOrThrow();

    for (final item in forwardResult.entries) {
      recursiveForwardRelationsIds[item.key.name] = item.value;
    }

    final backword = _getForginKeysIds(operation.table, operation);

    for (final item in backword.entries) {
      recursiveBackwordRelationsIds[item.key.name] = item.value;
    }

    print('Forward :$recursiveForwardRelationsIds');
    print('backword :$recursiveBackwordRelationsIds');

    try {
      final operationModel = OperationModel.fromOperation(operation);
      final payload = {
        "operation": operationModel.toJson(),
        "parent_ids": recursiveBackwordRelationsIds,
        "tablesEntitiesIdsRemove": recursiveForwardRelationsIds,
        "device_id": deviceId,
        "user_id": operationModel.createdBy,
      };

      final response = await Supabase.instance.client.functions.invoke(
        'sync-operation',
        body: payload,
      );
      final result = Helper.handleSyncOperationResponse(response.data);
      return Right(result);
    } on FunctionException catch (e) {
      final result = Helper.handleSyncOperationResponse(e.details);
      return Right(result);
    } catch (e) {
      return Left(ProcessingFailure(message: e.toString()));
    }
  }

  /*
  @override
  Future<Either<Failure, Map<DBTable, List<String>>>> getBackwordRelationsIds(
    DBTable startTable,
    String entityId, {
    bool test = false,
  }) async {
    try {
      final Map<DBTable, List<String>> tableEntityRemoveIds = {};

      final parentsTables =
          tabelRelationsNotNull[startTable]?["backword"] ?? [];
      for (final table in parentsTables) {
        final idsList = await _getTableDataSource(
          table,
        ).getForeignkeyEntitiesIdsBulk(table, [entityId], test: test);
        tableEntityRemoveIds[table] = idsList.toSet().toList();
      }
      return Right(tableEntityRemoveIds);
    } catch (e) {
      return Left(ProcessingFailure(message: e.toString()));
    }
  }

   */

  @override
  Future<Either<Failure, Map<DBTable, List<String>>>>
  getForwardRecursiveRelationsIds(
    DBTable startTable,
    String entityId, {
    bool test = false,
  }) async {
    try {
      final Map<DBTable, Set<String>> tableEntityRemoveIds = {
        startTable: {entityId},
      };

      final Queue<DBTable> queue = Queue();
      queue.add(startTable);

      while (queue.isNotEmpty) {
        final current = queue.removeFirst();
        final parentIds = tableEntityRemoveIds[current] ?? {};

        if (parentIds.isEmpty) continue;

        final children = tabelRelationsNotNull[current]?["forward"] ?? [];

        for (final child in children) {
          final idsList = await _getTableDataSource(child)
              .getForeignkeyEntitiesIdsBulk(
                current,
                parentIds.toList(),
                test: test,
              );

          final ids = idsList.toSet();
          if (ids.isEmpty) continue;

          final existing = tableEntityRemoveIds[child] ?? {};

          final newIds = ids.difference(existing);

          if (newIds.isNotEmpty) {
            tableEntityRemoveIds[child] = {...existing, ...newIds};

            queue.add(child);
          }
        }
      }
      tableEntityRemoveIds.remove(startTable);

      final Map<DBTable, List<String>> result = {};
      for (final item in tableEntityRemoveIds.entries) {
        result[item.key] = item.value.toList();
      }
      return Right(result);
    } catch (e) {
      return Left(ProcessingFailure(message: e.toString()));
    }
  }
}
