import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_one_datasource_impl.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/sync_datasource.dart';
import 'package:sync_feature/sync_engine/data/repository/sync_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_server_updated_records_usecase.dart';

void main() {
  test('1) first-app-pull', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();

    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(
      queueDatasource,
      tableDatasource,
    );
    final syncRepository = SyncRepositoryImpl(tableRepository, syncDatasource);
    final getUpdatedUseCase = GetServerUpdatedRecordsUseCase(tableRepository);
    final deviceId = await syncRepository.getDeviceId();
    print('DEVICE ID:=> ${deviceId.getOrThrow()}');
    final lastSyncTime = await syncRepository.getLastSyncTime();
    print('LastSyncTime:=> ${lastSyncTime.getOrThrow()}');
    final params = GetServerUpdatedRecordsUseCaseParams(
      table: DBTable.table_five,
      deviceId: deviceId.getOrThrow(),
      centerId: centerId,
      lastSyncTime: lastSyncTime.getOrThrow(),
    );
    final response = await getUpdatedUseCase.call(params);
    response.fold(
      ifLeft: (err) {
        print('Error : get updated records');
        print(err);
      },
      ifRight: (data) {
        print('success : get updated records');
        for (var d in data) {
          print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
          print(d['message']);
        }
      },
    );
  });
  test('2) get only the push time>last sync time', () async {
    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();

    final syncDatasource = SyncDatasource();
    final tableRepository = TableRepositoryImpl(
      queueDatasource,
      tableDatasource,
    );
    final syncRepository = SyncRepositoryImpl(tableRepository, syncDatasource);
    final getUpdatedUseCase = GetServerUpdatedRecordsUseCase(tableRepository);
    final deviceId = await syncRepository.getDeviceId();
    print('DEVICE ID:=> ${deviceId.getOrThrow()}');
    final lastSyncTime = await syncRepository.getLastSyncTime();
    print('LastSyncTime:=> ${lastSyncTime.getOrThrow()}');
    final params = GetServerUpdatedRecordsUseCaseParams(
      table: DBTable.table_five,
      deviceId: deviceId.getOrThrow(),
      centerId: centerId,
      lastSyncTime: lastSyncTime.getOrThrow(),
    );
    final response = await getUpdatedUseCase.call(params);
    response.fold(
      ifLeft: (err) {
        print('Error : get updated records');
        print(err);
      },
      ifRight: (data) {
        print('success : get updated records');
        for (var d in data) {
          print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
          print(d['message']);
        }
      },
    );
  });
}
