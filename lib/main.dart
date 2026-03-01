import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/repository/queue_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_five.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_operation_local_usecase.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/get_table_queue_usecase.dart';

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
              final queueDataSource = LocalQueueDatasource();
              final queueRepo = QueueRepositoryImpl(queueDataSource);
              final addUseCase = AddOperationLocalUseCase(queueRepo);
              final getUseCase = GetTableQueueUseCase(queueRepo);
              final entityData = DateTime.now().toUtc();
              final entityTwo = TableFive(
                forKeyTableThree: "x3x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
                forKeyTableFour: "x4x87ca56-89c8-42fd-9d8c-0b0c2be7c5d6",
                entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
                message: 'hellow from table five 1',
                centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
                byUser: currentUser,
                byDevice: deviceId,
                isDeleted: false,
                version: 1,
                createdAt: entityData,
                updatedAt: entityData,
              );
              print('entity_data= $entityData');
              final operationFive = Operation(
                id: "2",
                entityId: "811100ea-4383-4710-a6e6-9fee6b61034d",
                centerId: "5d242021-432d-41ea-ac04-fba60e368fd3",
                action: OperationAction.delete,
                table: DBTable.table_five,
                json: entityTwo.toJson(),
                version: 1,
                userRole: currentUserRole,
                createdBy: currentUser,
                createdAt: entityData,
                nextRetryAt: DateTime.now(),
                lastAttemptAt: DateTime.now(),
                retryCount: 0,
                status: OperationState.pending,
              );

              final addParams = AddOperationLocalUseCaseParams(
                operation: operationFive,
              );
              final getParams = GetTableQueueUseCaseParams(
                table: DBTable.table_five,
              );
              final result = await addUseCase.call(addParams);
              await result.fold(
                ifLeft: (err) {
                  print('Error: add operation to queue');
                  print(err);
                },
                ifRight: (d) async {
                  print('Success: add operation to queue');
                  final result = await getUseCase.call(getParams);
                  result.fold(
                    ifLeft: (err) {
                      print('Error: get Queue operations');
                      print(err);
                    },
                    ifRight: (data) {
                      print('Success: get Queue operations');
                      for (var d in data) {
                        print('ddddddddddddddddddddddddddddd');
                        print("oper_data: ${d.createdAt}");
                        print("entity_id: ${d.json['id']}");
                        print("entity_data: ${d.json['created_at']}");
                      }
                    },
                  );
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
