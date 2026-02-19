import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_feature/config/constants.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/enums/operation_action.dart';
import 'package:sync_feature/core/enums/user_role.dart';
import 'package:sync_feature/core/helper.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_queue_datasource.dart';
import 'package:sync_feature/sync_engine/data/data_source/local/local_table_one_datasource_impl.dart';
import 'package:sync_feature/sync_engine/data/data_source/models/table_one_model.dart';
import 'package:sync_feature/sync_engine/data/repository/table_repository_impl.dart';
import 'package:sync_feature/sync_engine/domain/entities/operation.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create (first node)', (s) async {
    late SupabaseClient client;

    await Supabase.initialize(
      url: projectSupabaseUrl,
      anonKey: projectSupabaseAnonKey,
    );
    client = Supabase.instance.client;
    await Helper.login('mahmoud@gmail.com', 'Mahmoud');

    final queueDatasource = LocalQueueDatasource();
    final tableDatasource = LocalTableOneDatasource();
    final tableRepository = TableRepositoryImpl(
      queueDatasource,
      tableDatasource,
    );
    final operation = Operation(
      id: 'oper-1',
      entityId: 'c887ca56-89c8-42fd-9d8c-0b0c2be7c5d6',
      centerId: '5d242021-432d-41ea-ac04-fba60e368fd3',
      action: OperationAction.create,
      table: DBTable.table_one,
      json: TableOneModel(
        entityId: 'c887ca56-89c8-42fd-9d8c-0b0c2be7c5d6',
        message: 'hellow from table one',
        centerId: '5d242021-432d-41ea-ac04-fba60e368fd3',
        byUser: currentUser,
        byDevice: deviceId,
        isDeleted: false,
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toJson(),
      version: 1,
      userRole: currentUserRole,
      createdBy: currentUser,
      createdAt: DateTime.now(),
    );
    final response = await tableRepository.sendOperationToServer(
      operation,
      deviceId,
    );
    response.fold(
      ifLeft: (err) {
        print(err.runtimeType);
        print(err);
      },
      ifRight: (resp) {
        print(resp.runtimeType);
        print(resp);
      },
    );
  });
}
