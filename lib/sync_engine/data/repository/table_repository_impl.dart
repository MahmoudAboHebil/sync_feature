import 'dart:collection';

import 'package:dart_either/src/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_datasource.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';

import '../data_source/local/local_table_five_datasource_impl.dart';
import '../data_source/local/local_table_four_datasource_impl.dart';
import '../data_source/local/local_table_one_datasource_impl.dart';
import '../data_source/local/local_table_three_datasource_impl.dart';
import '../data_source/local/local_table_two_datasource_impl.dart';

class TableRepositoryImpl implements TableRepository {
  final LocalQueueDatasource _queueDatasource;
  final LocalTableDatasource _localTableDatasource;
  TableRepositoryImpl(this._queueDatasource, this._localTableDatasource);

  LocalTableDatasource _getTableDataSource(DBTable table) {
    if (table == DBTable.table1) {
      return LocalTableOneDatasource();
    } else if (table == DBTable.table2) {
      return LocalTableTwoDatasource();
    } else if (table == DBTable.table3) {
      return LocalTableThreeDatasource();
    } else if (table == DBTable.table4) {
      return LocalTableFourDatasource();
    } else if (table == DBTable.table5) {
      return LocalTableFiveDatasource();
    } else {
      throw Exception(
        'there is not datasource file for this ${table.name} table',
      );
    }
  }

  @override
  Future<Either<Failure, Map<DBTable, Set<String>>>> deleteEntityCascadeNotNull(
    DBTable startTable,
    String entityId, {
    bool test = false,
  }) async {
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
        final idsList = await _getTableDataSource(
          child,
        ).getEntitiesIdsByFornKeyBulk(current, parentIds.toList(), test: test);

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

    return Right(tableEntityRemoveIds);
  }

  /*
    final tableDataSource = _getTableDataSource(table);
    await tableDataSource.softDelete(entityId);
    await _queueDatasource.removeOperationsByEntity(entityId);
     */
  @override
  Future<Either<Failure, Map<String, dynamic>>> getEntityFromTable(
    DBTable table,
    String entityId,
  ) {
    // TODO: implement getEntityFromTable
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUpdatedEntities(
    DBTable table,
    String deviceId,
    DateTime lastTimeSync,
  ) {
    // TODO: implement getUpdatedEntities
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> insertEntityToTable(
    DBTable table,
    Map<String, dynamic> json,
  ) {
    // TODO: implement insertEntityToTable
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> replaceEntityLocalWithServer(
    DBTable table,
    Map<String, dynamic> jone,
  ) {
    // TODO: implement replaceEntityLocalWithServer
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> sendOperation(
    Operation operation,
    String deviceId,
  ) {
    // TODO: implement sendOperation
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateTableEntity(
    DBTable table,
    Map<String, dynamic> json,
  ) {
    // TODO: implement updateTableEntity
    throw UnimplementedError();
  }
}
