import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/queue_repository.dart';

import '../../../core/error/failure.dart';
import '../../../core/use_cases/use_case.dart';

class AddOperationLocalUseCaseParams {
  final Operation operation;

  const AddOperationLocalUseCaseParams({required this.operation});
}

class AddOperationLocalUseCase
    implements UseCase<Either<Failure, void>, AddOperationLocalUseCaseParams> {
  final QueueRepository _repository;
  const AddOperationLocalUseCase(this._repository);
  @override
  Future<Either<Failure, void>> call(
    AddOperationLocalUseCaseParams params,
  ) async {
    return await _repository.addOperationToQueue(params.operation);
  }
}
