import 'package:dart_either/src/dart_either.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';

import '../../../core/enums/user_role.dart';
import '../../../core/error/netwrok_response.dart';

class SyncRepositoryImpl extends SyncRepository {
  final TableRepositoryImpl _tableRepositoryImpl;
  SyncRepositoryImpl(this._tableRepositoryImpl);

  @override
  Future<Either<Failure, NetworkResponse>> pushSingleOperation(
    Operation operation,
  ) async {
    final result = await _tableRepositoryImpl.sendOperationToServer(
      operation,
      deviceId,
    );
    return result;
  }
}
