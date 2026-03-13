import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:sync_feature/core/enums/DB_Table.dart';
import 'package:sync_feature/core/isar_service/collections/table_one_collection.dart';
import 'package:sync_feature/sync_engine/data/models/table_one_model.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_one.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';
import 'package:sync_feature/sync_engine/domain/repository/table_repository.dart';
import 'package:sync_feature/sync_engine/presentation/pages/home_page.dart';
import 'package:sync_feature/sync_engine/presentation/pages/sync_results_page.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_five.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_four.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_three.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_two.dart';
import 'package:uuid/uuid.dart';

import '../../../config/constants.dart';
import '../../../context/data/data_source/table_one_datasource.dart';
import '../../../core/helper.dart';
import '../../../core/internet_service/internet_bloc/internet_bloc.dart';
import '../../../core/internet_service/internet_bloc/internet_state.dart';
import '../../../core/isar_service/isar_service.dart';
import '../../../injection_container.dart';
import '../widgets/sync_button_widget.dart';

class TableOnePage extends StatefulWidget {
  const TableOnePage({super.key});

  @override
  State<TableOnePage> createState() => _TableOnePageState();
}

class _TableOnePageState extends State<TableOnePage> {
  bool isCreate = false;

  Future<void> create() async {
    final Uuid uuid = Uuid();
    final message = await Helper.showAddRecordDialog(context);
    final getResult = await sl<SyncRepository>().getDeviceId();
    if (message != null && getResult.isRight) {
      final byDevice = getResult.getOrThrow();
      final newRecord = TableOne(
        entityId: uuid.v4(),
        message: message,
        centerId: centerId,
        byUser: currentUser,
        byDevice: byDevice,
        isDeleted: false,
        version: 1,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      final result = await sl<TableOneDatasource>().create(newRecord);
      result.fold(
        ifLeft: (err) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SyncResultsPage(
                errorMessage: "Something went wrong ${err.message}",
              ),
            ),
          );
        },
        ifRight: (response) {
          if (response != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SyncResultsPage(response: [response]),
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isCreate) return;

          setState(() {
            isCreate = true;
          });

          try {
            await create();
          } finally {
            setState(() {
              isCreate = false;
            });
          }
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text('Table One')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text('To Home'),
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

          BlocBuilder<InternetBloc, InternetState>(
            builder: (context, state) {
              if (state is InternetConnected) {
                return const SyncButtonWidget();
              } else {
                return Text('there is no internet');
              }
            },
          ),
          SizedBox(height: 60),
          Text(' Table one data'),
          Expanded(
            child: StreamBuilder<List<TableOneCollection>>(
              stream: IsarService.isar.tableOneCollections
                  .filter()
                  .isDeletedEqualTo(false)
                  .sortByCreatedAtDesc()
                  .watch(fireImmediately: true),
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (_, i) {
                    final record = data[i];
                    return GestureDetector(
                      onLongPress: () async {
                        final relationResult = await sl<TableRepository>()
                            .getForwardRecursiveRelationsIds(
                              DBTable.table_one,
                              record.entityId,
                            );
                        relationResult.fold(
                          ifLeft: (err) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SyncResultsPage(
                                  errorMessage:
                                      "Something went wrong ${err.message}",
                                ),
                              ),
                            );
                          },
                          ifRight: (relationList) async {
                            final result = await Helper.confDeletion(
                              context,
                              DBTable.table_one,
                              record.entityId,
                              relationList,
                            );
                            if (result != null && result) {
                              final model = TableOneModel.fromCollection(
                                record,
                              );
                              final result = await sl<TableOneDatasource>()
                                  .softDelete(model.toEntity());
                              result.fold(
                                ifLeft: (err) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SyncResultsPage(
                                        errorMessage:
                                            "Something went wrong ${err.message}",
                                      ),
                                    ),
                                  );
                                },
                                ifRight: (response) {
                                  if (response != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SyncResultsPage(
                                          response: [response],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          },
                        );
                      },
                      onTap: () async {
                        final message = await Helper.showAddRecordDialog(
                          context,
                        );
                        if (message != null) {
                          final result = await sl<TableOneDatasource>().update(
                            TableOneModel.fromCollection(
                              data[i],
                            ).toEntity().copyWith(message: message),
                          );
                          result.fold(
                            ifLeft: (err) {
                              print('err $err');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SyncResultsPage(
                                    errorMessage:
                                        "Something went wrong ${err.message}",
                                  ),
                                ),
                              );
                            },
                            ifRight: (response) {
                              print('response $response');
                              if (response != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SyncResultsPage(response: [response]),
                                  ),
                                );
                              }
                            },
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Text("entityId ${record.entityId}"),
                          Text("message ${record.message}"),
                          Text("createdAt ${record.createdAt.toLocal()}"),
                          Text("updatedAt ${record.updatedAt.toLocal()}"),
                          Text("version ${record.version}"),
                        ],
                      ),
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
