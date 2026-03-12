import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:sync_feature/core/internet_service/internet_bloc/internet_bloc.dart';
import 'package:sync_feature/core/internet_service/internet_bloc/internet_state.dart';
import 'package:sync_feature/core/isar_service/collections/operation_collection.dart';
import 'package:sync_feature/core/isar_service/isar_service.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_five.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_four.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_one.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_three.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_two.dart';
import 'package:sync_feature/sync_engine/presentation/widgets/sync_button_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          BlocBuilder<InternetBloc, InternetState>(
            builder: (context, state) {
              if (state is InternetConnected) {
                return const SyncButtonWidget();
              } else {
                return Text('there is no internet');
              }
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TableOnePage()),
                  );
                },
                child: Text('To Table 1'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TableTwoPage()),
                  );
                },
                child: Text('To Table 2'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TableThreePage()),
                  );
                },
                child: Text('To Table 3'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TableFourPage()),
                  );
                },
                child: Text('To Table 4'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TableFivePage()),
                  );
                },
                child: Text('To Table 5'),
              ),
            ],
          ),
          SizedBox(height: 60),
          Text(' Operations Queue'),
          Expanded(
            child: StreamBuilder<List<OperationCollection>>(
              stream: IsarService.isar.operationCollections
                  .where()
                  .sortByCreatedAtDesc()
                  .watch(fireImmediately: true),
              builder: (context, snapshot) {
                final operations = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: operations.length,
                  itemBuilder: (_, i) {
                    final operation = operations[i];
                    return Column(
                      children: [
                        Text("operationId ${operation.operationId}"),
                        Text("entityId ${operation.entityId}"),
                        Text(
                          "message ${jsonDecode(operation.payload)["message"]}",
                        ),
                        Text("table ${operation.table}"),
                        Text("action ${operation.action}"),
                        Text("status ${operation.status}"),
                        Text("createdAt ${operation.createdAt.toLocal()}"),
                        Text("version ${operation.version}"),
                        Text("retryCount ${operation.retryCount}"),
                        Text("nextRetryAt ${operation.nextRetryAt.toUtc()}"),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
