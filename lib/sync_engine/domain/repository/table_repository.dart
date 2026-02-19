import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/standard_table_record.dart';

import '../../../core/error/netwrok_response.dart';

abstract class TableRepository {
  Future<Either<Failure, void>> deleteEntityCascadeNotNull(
    DBTable table,
    String entityId, {
    bool test = false,
  });
  Future<Either<Failure, Map<DBTable, Set<String>>>> getBackwordRelationsIds(
    DBTable table,
    String entityId, {
    bool test = false,
  });
  Future<Either<Failure, Map<DBTable, Set<String>>>>
  getForwardRecursiveRelationsIds(
    DBTable startTable,
    String entityId, {
    bool test = false,
  });

  Future<Either<Failure, void>> replaceEntityLocalWithServer(
    DBTable table,
    Map<String, dynamic> json,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getUpdatedServerEntities(
    DBTable table,
    String deviceId,
    DateTime lastTimeSync,
  );
  Future<Either<Failure, NetworkResponse>> sendOperationToServer(
    Operation operation,
    String deviceId, {
    Map<String, dynamic> recursiveForwardRelationsIds = const {},
    Map<String, dynamic> recursiveBackwordRelationsIds = const {},
  });
  Future<Either<Failure, Map<String, dynamic>?>> getEntityFromTable(
    DBTable table,
    String entityId,
  );

  Future<Either<Failure, void>> insertEntityToTable(
    DBTable table,
    Map<String, dynamic>? jsonEntity,
    StandardTableRecord? entity,
  );
}
