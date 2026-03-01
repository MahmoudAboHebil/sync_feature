import 'package:dart_either/dart_either.dart';
import 'package:dart_either/src/dart_either.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/sync_datasource.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';

import '../../../core/error/netwrok_response.dart';
import '../../domain/repository/queue_repository.dart';
import '../../domain/repository/table_repository.dart';

class SyncRepositoryImpl extends SyncRepository {
  final TableRepository _tableRepositoryImpl;
  final QueueRepository _queueRepository;
  final SyncDatasource _syncDatasource;
  SyncRepositoryImpl(
    this._tableRepositoryImpl,
    this._syncDatasource,
    this._queueRepository,
  );

  @override
  Future<Either<Failure, NetworkResponse>> sendOperationToServer(
    Operation operation,
    String deviceId,
  ) async {
    final result = await _tableRepositoryImpl.sendOperationToServer(
      operation,
      deviceId,
    );
    return result;
  }

  @override
  Future<Either<Failure, String>> getDeviceId() async {
    try {
      final result = await _syncDatasource.getDeviceId();
      return Right(result);
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'Failed To get Device Id from Queue :${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DateTime>> getLastSyncTime() async {
    try {
      final result = await _syncDatasource.getLastSyncTime();
      return Right(result);
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'Failed To get  Last Sync Time  :${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateLastTimeSync(DateTime timeAsUTC) async {
    try {
      final result = await _syncDatasource.updateLastTimeSync(timeAsUTC);
      return Right(null);
    } catch (e) {
      return Left(
        ProcessingFailure(
          message: 'Failed To update Last Sync Time  :${e.toString()}',
        ),
      );
    }
  }
}
