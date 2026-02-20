import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/netwrok_response.dart';
import '../../../core/use_cases/use_case.dart';

class PushSingleOperationUseCaseParams {
  final Operation operation;
  const PushSingleOperationUseCaseParams({required this.operation});
}

class PushSingleOperationUseCase
    implements
        UseCase<Either<Failure, void>, PushSingleOperationUseCaseParams> {
  final SyncRepository _repository;
  const PushSingleOperationUseCase(this._repository);
  @override
  Future<Either<Failure, NetworkResponse>> call(
    PushSingleOperationUseCaseParams params,
  ) async {
    return await _repository.pushSingleOperation(params.operation);
  }
}
