import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';

abstract class TableRepository {
  Future<Either<Failure, Map<DBTable, Set<String>>>> deleteEntityCascadeNotNull(
    DBTable table,
    String entityId, {
    bool test = false,
  });

  Future<Either<Failure, void>> replaceEntityLocalWithServer(
    DBTable table,
    Map<String, dynamic> jone,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getUpdatedEntities(
    DBTable table,
    String deviceId,
    DateTime lastTimeSync,
  );
  Future<Either<Failure, void>> sendOperation(
    Operation operation,
    String deviceId,
  );
  Future<Either<Failure, Map<String, dynamic>>> getEntityFromTable(
    DBTable table,
    String entityId,
  );
  Future<Either<Failure, void>> insertEntityToTable(
    DBTable table,
    Map<String, dynamic> json,
  );
  Future<Either<Failure, void>> updateTableEntity(
    DBTable table,
    Map<String, dynamic> json,
  );
}
