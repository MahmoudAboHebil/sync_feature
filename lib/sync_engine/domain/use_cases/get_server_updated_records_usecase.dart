import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';

import '../../../core/error/failure.dart';
import '../../../core/use_cases/use_case.dart';

class GetServerUpdatedRecordsUseCaseParams {
  final DBTable table;
  final String deviceId;
  final String centerId;
  final DateTime lastSyncTime;
  const GetServerUpdatedRecordsUseCaseParams({
    required this.table,
    required this.deviceId,
    required this.centerId,
    required this.lastSyncTime,
  });
}

class GetServerUpdatedRecordsUseCase
    implements
        UseCase<
          Either<Failure, List<Map<String, dynamic>>>,
          GetServerUpdatedRecordsUseCaseParams
        > {
  final TableRepository _repository;
  const GetServerUpdatedRecordsUseCase(this._repository);
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetServerUpdatedRecordsUseCaseParams params,
  ) async {
    return await _repository.getUpdatedServerEntities(
      params.table,
      params.deviceId,
      params.lastSyncTime,
      params.centerId,
    );
  }
}
