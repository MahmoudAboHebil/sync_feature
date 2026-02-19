import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/netwrok_response.dart';
import '../../../core/use_cases/use_case.dart';

class PushSingleOperationParams {
  final Operation operation;
  const PushSingleOperationParams({required this.operation});
}

class PushSingleOperation
    implements UseCase<Either<Failure, void>, PushSingleOperationParams> {
  final SyncRepository _repository;
  const PushSingleOperation(this._repository);
  @override
  Future<Either<Failure, NetworkResponse>> call(
    PushSingleOperationParams params,
  ) async {
    return await _repository.pushSingleOperation(params.operation);
  }
}
