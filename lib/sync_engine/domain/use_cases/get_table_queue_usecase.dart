import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/repository/queue_repository.dart';

import '../../../core/error/failure.dart';
import '../../../core/use_cases/use_case.dart';

class GetTableQueueUseCaseParams {
  final DBTable table;

  const GetTableQueueUseCaseParams({required this.table});
}

class GetTableQueueUseCase
    implements
        UseCase<Either<Failure, List<Operation>>, GetTableQueueUseCaseParams> {
  final QueueRepository _repository;
  const GetTableQueueUseCase(this._repository);
  @override
  Future<Either<Failure, List<Operation>>> call(
    GetTableQueueUseCaseParams params,
  ) async {
    return await _repository.getPendingOperationOrdered(params.table);
  }
}
