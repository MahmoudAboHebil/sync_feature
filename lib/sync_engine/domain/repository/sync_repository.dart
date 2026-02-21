import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/netwrok_response.dart';

abstract class SyncRepository {
  Future<Either<Failure, NetworkResponse>> pushSingleOperation(
    Operation operation,
    String deviceId,
  );
  Future<Either<Failure, DateTime>> getLastSyncTime();
  Future<Either<Failure, void>> updateLastTimeSync(DateTime timeAsUTC);
  Future<Either<Failure, String>> getDeviceId();
}
