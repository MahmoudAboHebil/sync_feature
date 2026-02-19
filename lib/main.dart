import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_one_datasource_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/sync_repository_impl.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_one.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/add_entity_local.dart';
import 'package:sync_feature/sync_engine/domain/use_cases/push_single_operation.dart';

import 'core/enums/DB_Table.dart';
import 'core/enums/operation_action.dart';
import 'core/enums/user_role.dart';
import 'core/helper.dart';

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
              final tableRepository = TableRepositoryImpl(
                queueDatasource,
                tableDatasource,
              );
              final syncRepository = SyncRepositoryImpl(tableRepository);
              final token = await Helper.login(
                'testone@gmail.com',
                'testone@gmail.com',
              );
              final entityId = "c887ca56-89c8-42fd-9d8c-0b0c2be7c5d6";
              final centerId = "5d242021-432d-41ea-ac04-fba60e368fd3";
              final operationId = "3e82f13c-f9eb-4f7f-93c9-2451473a8a6f";
              final entity = TableOne(
                entityId: entityId,
                message: 'hellow from table one',
                centerId: centerId,
                byUser: currentUser,
                byDevice: deviceId,
                isDeleted: false,
                version: 1,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              // add to local
              final params = AddEntityLocalParams(
                table: DBTable.table_one,
                jsonEntity: null,
                entity: entity,
              );
              final useCase = AddEntityLocal(tableRepository);
              final result = await useCase.call(params);
              result.fold(
                ifLeft: (err) {
                  print('Entity is Not Add');
                  print(err);
                },
                ifRight: (d) async {
                  print('Entity is Added to Local Db');
                  final operation = Operation(
                    id: operationId,
                    entityId: entityId,
                    centerId: centerId,
                    action: OperationAction.create,
                    table: DBTable.table_one,
                    json: entity.toJson(),
                    version: 1,
                    userRole: currentUserRole,
                    createdBy: currentUser,
                    createdAt: DateTime.now(),
                  );
                  final pushParams = PushSingleOperationParams(
                    operation: operation,
                  );
                  final pushUseCase = PushSingleOperation(syncRepository);
                  final pushResult = await pushUseCase.call(pushParams);
                  pushResult.fold(
                    ifLeft: (err) {
                      print('failed to push flutter side');
                      print(err);
                    },
                    ifRight: (d) {
                      print(d);
                    },
                  );
                },
              );
              // push to server
            },
            child: Text('Do Test'),
          ),
        ),
      ),
    );
  }
}
