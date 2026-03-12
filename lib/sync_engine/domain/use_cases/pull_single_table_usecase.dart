import 'package:dart_either/dart_either.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/error/failure.dart';
import 'package:sync_feature/core/error/sync_response.dart';
import 'package:sync_feature/core/use_cases/use_case.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_server_updated_records_usecase.dart';

class PullSingleTableUseCaseParams {
  final DBTable table;
  final String deviceId;
  final String centerId;
  final DateTime lastSyncTime;
  const PullSingleTableUseCaseParams({
    required this.table,
    required this.deviceId,
    required this.centerId,
    required this.lastSyncTime,
  });
}

class PullSingleTableUseCase
    implements
        UseCase<
          Either<Failure, List<SyncResponse>>,
          PullSingleTableUseCaseParams
        > {
  final GetServerUpdatedRecordsUseCase _getServerUpdatedRecordsUseCase;
  final TableRepository _tableRepository;

  const PullSingleTableUseCase(
    this._getServerUpdatedRecordsUseCase,
    this._tableRepository,
  );

  @override
  Future<Either<Failure, List<SyncResponse>>> call(
    PullSingleTableUseCaseParams params,
  ) async {
    List<SyncResponse> resList = [];
    final result = await _getServerUpdatedRecordsUseCase.call(
      GetServerUpdatedRecordsUseCaseParams(
        table: params.table,
        deviceId: params.deviceId,
        centerId: params.centerId,
        lastSyncTime: params.lastSyncTime,
      ),
    );
    print(' lastSyncTime=> ${params.lastSyncTime}');

    if (result.isLeft) {
      return Left(
        result.fold(
          ifLeft: (l) => l,
          ifRight: (_) => ProcessingFailure(message: 'Please Try again Later'),
        ),
      );
    }
    final updatedRecords = result.getOrThrow();
    print('pull Data${params.table} =>${updatedRecords}');

    for (var updatedRd in updatedRecords) {
      final findResult = await _tableRepository.getEntityFromTable(
        params.table,
        updatedRd["id"],
      );

      if (findResult.isLeft) {
        return Left(
          findResult.fold(
            ifLeft: (l) => l,
            ifRight: (_) =>
                ProcessingFailure(message: 'Please Try again Later'),
          ),
        );
      }
      final localEntity = findResult.getOrThrow();

      if (localEntity == null) {
        final insertResult = await _tableRepository.insertEntityToTable(
          params.table,
          updatedRd,
          null,
        );
        if (insertResult.isLeft) {
          return Left(
            insertResult.fold(
              ifLeft: (l) => l,
              ifRight: (_) =>
                  ProcessingFailure(message: 'Please Try again Later'),
            ),
          );
        }
        final result = SyncResponse(isPull: true, insertPullData: updatedRd);
        resList.add(result);

        continue;
      }
      if ((updatedRd['version'] as int) == (localEntity['version'] as int)) {
        continue;
      }
      if ((updatedRd['version'] as int) > (localEntity['version'] as int)) {
        final replaceResult = await _tableRepository
            .replaceEntityLocalWithServer(params.table, updatedRd);
        if (replaceResult.isLeft) {
          return Left(
            replaceResult.fold(
              ifLeft: (l) => l,
              ifRight: (_) =>
                  ProcessingFailure(message: 'Please Try again Later'),
            ),
          );
        }
        if (updatedRd['is_deleted'] == true) {
          final result = SyncResponse(
            isPull: true,
            updatedPullData: updatedRd,
            isPullRecordeDeleted: true,
          );
          resList.add(result);
        } else {
          final result = SyncResponse(isPull: true, updatedPullData: updatedRd);
          resList.add(result);
        }

        continue;
      }
    }
    return Right(resList);
  }
}
