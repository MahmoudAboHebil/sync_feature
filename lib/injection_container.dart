import 'package:get_it/get_it.dart';
import 'package:sync_feature/context/data/data_source/table_five_datasource.dart';
import 'package:sync_feature/context/data/data_source/table_four_datasource.dart';
import 'package:sync_feature/context/data/data_source/table_one_datasource.dart';
import 'package:sync_feature/context/data/data_source/table_two_datasource.dart';
import 'package:sync_feature/core/internet_service/internet_bloc/internet_bloc.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/sync_datasource.dart';
import 'package:sync_feature/sync_engine/data/repository/queue_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/sync_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/repository/queue_repository.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_entity_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_operation_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_server_updated_records_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_table_queue_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/pull_single_table_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/push_single_operation_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/push_single_table_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/send_operation_to_server_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/sync_all_tables_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/sync_table_usecase.dart';
import 'package:sync_feature/sync_engine/presentation/blocs/sync_bloc/sync_bloc.dart';

import 'context/data/data_source/table_three_datasource.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Data Sources
  sl.registerSingleton<SyncDatasource>(SyncDatasource());
  sl.registerSingleton<LocalQueueDatasource>(LocalQueueDatasource());

  // Repositories
  sl.registerSingleton<QueueRepository>(
    QueueRepositoryImpl(sl<LocalQueueDatasource>()),
  );

  sl.registerSingleton<TableRepository>(
    TableRepositoryImpl(sl<LocalQueueDatasource>()),
  );

  sl.registerSingleton<SyncRepository>(
    SyncRepositoryImpl(
      sl<TableRepository>(),
      sl<SyncDatasource>(),
      sl<QueueRepository>(),
    ),
  );

  //UseCases
  sl.registerSingleton<SendOperationToServerUseCase>(
    SendOperationToServerUseCase(sl<SyncRepository>()),
  );
  sl.registerSingleton<PushSingleOperationUseCase>(
    PushSingleOperationUseCase(
      sl<QueueRepository>(),
      sl<TableRepository>(),
      sl<SendOperationToServerUseCase>(),
    ),
  );

  sl.registerSingleton<AddOperationLocalUseCase>(
    AddOperationLocalUseCase(sl<QueueRepository>()),
  );
  sl.registerSingleton<AddEntityLocalUseCase>(
    AddEntityLocalUseCase(sl<TableRepository>()),
  );
  sl.registerSingleton<GetServerUpdatedRecordsUseCase>(
    GetServerUpdatedRecordsUseCase(sl<TableRepository>()),
  );
  sl.registerSingleton<GetTableQueueUseCase>(
    GetTableQueueUseCase(sl<QueueRepository>()),
  );
  sl.registerSingleton<PullSingleTableUseCase>(
    PullSingleTableUseCase(
      sl<GetServerUpdatedRecordsUseCase>(),
      sl<TableRepository>(),
    ),
  );
  sl.registerSingleton<PushSingleTableUseCase>(
    PushSingleTableUseCase(
      sl<QueueRepository>(),
      sl<TableRepository>(),
      sl<GetTableQueueUseCase>(),
      sl<SendOperationToServerUseCase>(),
    ),
  );

  sl.registerSingleton<SyncTableUseCase>(
    SyncTableUseCase(
      sl<PullSingleTableUseCase>(),
      sl<PushSingleTableUseCase>(),
    ),
  );

  sl.registerSingleton<SyncAllTablesUseCase>(
    SyncAllTablesUseCase(sl<SyncTableUseCase>(), sl<SyncRepository>()),
  );

  // real work throw
  sl.registerSingleton<TableOneDatasource>(
    TableOneDatasource(
      sl<AddEntityLocalUseCase>(),
      sl<AddOperationLocalUseCase>(),
      sl<QueueRepository>(),
      sl<SyncRepository>(),
      sl<PushSingleOperationUseCase>(),
      sl<TableRepository>(),
    ),
  );
  sl.registerSingleton<TableTwoDatasource>(
    TableTwoDatasource(
      sl<AddEntityLocalUseCase>(),
      sl<AddOperationLocalUseCase>(),
      sl<QueueRepository>(),
      sl<SyncRepository>(),
      sl<PushSingleOperationUseCase>(),
      sl<TableRepository>(),
    ),
  );
  sl.registerSingleton<TableThreeDatasource>(
    TableThreeDatasource(
      sl<AddEntityLocalUseCase>(),
      sl<AddOperationLocalUseCase>(),
      sl<QueueRepository>(),
      sl<SyncRepository>(),
      sl<PushSingleOperationUseCase>(),
      sl<TableRepository>(),
    ),
  );
  sl.registerSingleton<TableFourDatasource>(
    TableFourDatasource(
      sl<AddEntityLocalUseCase>(),
      sl<AddOperationLocalUseCase>(),
      sl<QueueRepository>(),
      sl<SyncRepository>(),
      sl<PushSingleOperationUseCase>(),
      sl<TableRepository>(),
    ),
  );
  sl.registerSingleton<TableFiveDatasource>(
    TableFiveDatasource(
      sl<AddEntityLocalUseCase>(),
      sl<AddOperationLocalUseCase>(),
      sl<QueueRepository>(),
      sl<SyncRepository>(),
      sl<PushSingleOperationUseCase>(),
      sl<TableRepository>(),
    ),
  );
  //Blocs
  sl.registerFactory<SyncBloc>(() => SyncBloc(sl<SyncAllTablesUseCase>()));
  sl.registerFactory<InternetBloc>(() => InternetBloc());
}
