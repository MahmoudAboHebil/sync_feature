import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_one_datasource_impl.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/sync_datasource.dart';
import 'package:sync_feature/sync_engine/data/repository/queue_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/sync_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_five.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_entity_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_operation_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_table_queue_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/push_single_table_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/send_operation_to_server_usecase.dart';

import 'core/enums/DB_Table.dart';
import 'core/enums/operation_action.dart';
import 'core/enums/operation_status.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: projectSupabaseUrl,
    anonKey: projectSupabaseAnonKey,
  );
  await IsarService.getInstance();

  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async {
              final queueDatasource = LocalQueueDatasource();
              final tableDatasource = LocalTableOneDatasource();
              final syncDatasource = SyncDatasource();
              final tableRepository = TableRepositoryImpl(
                queueDatasource,
                tableDatasource,
              );
              final queueRepo = QueueRepositoryImpl(queueDatasource);
              final syncRepository = SyncRepositoryImpl(
                tableRepository,
                syncDatasource,
                queueRepo,
              );
              final getTableQueueUseCase = GetTableQueueUseCase(queueRepo);
              final sendOperationToServerUseCase = SendOperationToServerUseCase(
                syncRepository,
              );
              final addOperationLocalUseCase = AddOperationLocalUseCase(
                queueRepo,
              );
              final addEntityToLocalUseCase = AddEntityLocalUseCase(
                tableRepository,
              );
              final pushSyncUseCase = PushSingleTableUseCase(
                queueRepo,
                tableRepository,
                getTableQueueUseCase,
                sendOperationToServerUseCase,
              );

              final tableFiveEntity = TableFive(
                entityId: "e4e0ffca-18d0-4df6-ad40-d84307f9fcaa",
                forKeyTableThree: "a01ecd92-e27b-46b6-9ee3-432b1f798bbe",
                forKeyTableFour: "2968e74e-a3f1-4fed-8796-91fd5ab3ee52",
                message: 'hellow from table two',
                centerId: centerId,
                byUser: currentUser,
                byDevice: deviceId,
                isDeleted: false,
                version: 3,
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              );
              final fiveOperation = Operation(
                id: "e5e693b1-9ddd-4aae-9ae2-09e47e9f0dfa",
                entityId: 'e4e0ffca-18d0-4df6-ad40-d84307f9fcaa',
                centerId: centerId,
                action: OperationAction.update,
                table: DBTable.table_five,
                json: tableFiveEntity.toJson(),
                version: 3,
                userRole: currentUserRole,
                createdBy: currentUser,
                createdAt: DateTime.now(),
                retryCount: 0,
                lastAttemptAt: DateTime.now(),
                nextRetryAt: DateTime.now(),
                status: OperationState.pending,
              );

              //todo: add operation to queue
              final fiveResultOpera = await addOperationLocalUseCase.call(
                AddOperationLocalUseCaseParams(operation: fiveOperation),
              );
              fiveResultOpera.fold(
                ifLeft: (err) {
                  print('Error : add oper 1 to queue');
                  print(err);
                },
                ifRight: (e) {
                  print('Success : add oper 1 to queue');
                },
              );

              //todo: push operation to server
              final pushResult1 = await pushSyncUseCase.call(
                PushSingleTableUseCaseParams(
                  table: DBTable.table_five,
                  deviceId: deviceId,
                ),
              );
              pushResult1.fold(
                ifLeft: (err) {
                  print('Error : push 1 to server');
                  print(err);
                },
                ifRight: (e) {
                  print(e);
                  print('Success : push 1 to server');
                },
              );
            },
            child: Text('Do Test'),
          ),
        ),
      ),
    );
  }
}
