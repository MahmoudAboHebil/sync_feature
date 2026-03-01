import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/netwrok_response.dart';
import '../../../core/use_cases/use_case.dart';

class SendOperationToServerUseCaseParams {
  final Operation operation;
  final String deviceId;
  const SendOperationToServerUseCaseParams({
    required this.operation,
    required this.deviceId,
  });
}

class SendOperationToServerUseCase
    implements
        UseCase<Either<Failure, void>, SendOperationToServerUseCaseParams> {
  final SyncRepository _repository;
  const SendOperationToServerUseCase(this._repository);
  @override
  Future<Either<Failure, NetworkResponse>> call(
    SendOperationToServerUseCaseParams params,
  ) async {
    return await _repository.sendOperationToServer(
      params.operation,
      params.deviceId,
    );
  }
}
