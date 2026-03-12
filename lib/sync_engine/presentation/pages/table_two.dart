import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:sync_feature/context/data/data_source/table_two_datasource.dart';
import 'package:sync_feature/core/isar_service/collections/table_two_collection.dart';
import 'package:sync_feature/sync_engine/data/models/table_one_model.dart';
import 'package:sync_feature/sync_engine/data/models/table_two_model.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_one.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_two.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_five.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_four.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_one.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_three.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:uuid/uuid.dart';

import '../../../config/constants.dart';
import '../../../core/enums/DB_Table.dart';
import '../../../core/helper.dart';
import '../../../core/internet_service/internet_bloc/internet_bloc.dart';
import '../../../core/internet_service/internet_bloc/internet_state.dart';
import '../../../core/isar_service/collections/table_one_collection.dart';
import '../../../core/isar_service/isar_service.dart';
import '../../../injection_container.dart';
import '../../domain/repository/table_repository.dart';
import '../widgets/sync_button_widget.dart';
import 'home_page.dart';

class TableTwoPage extends StatelessWidget {
  const TableTwoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Uuid uuid = Uuid();
          List<TableOneCollection> parentRecords = await IsarService
              .isar
              .tableOneCollections
              .filter()
              .isDeletedEqualTo(false)
              .sortByCreatedAtDesc()
              .findAll();

          final data = parentRecords
              .map((e) => TableOneModel.fromCollection(e).toEntity())
              .toList();
          final TableOne? tableOne =
              await Helper.getParentId(context, data) as TableOne?;
          final message = await Helper.showAddRecordDialog(context);

          final getResult = await sl<SyncRepository>().getDeviceId();
          if (message != null && getResult.isRight && tableOne != null) {
            final byDevice = getResult.getOrThrow();
            final newRecord = TableTwo(
              entityId: uuid.v4(),
              message: message,
              centerId: centerId,
              byUser: currentUser,
              byDevice: byDevice,
              isDeleted: false,
              version: 1,
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
              forkeyTableOne: tableOne.entityId,
            );
            final result = await sl<TableTwoDatasource>().create(newRecord);
            result.fold(
              ifLeft: (err) {
                showTopSnackBar(
                  displayDuration: Duration(minutes: 3),
                  Overlay.of(context),
                  CustomSnackBar.error(
                    maxLines: 10,

                    message: "Something went wrong ${err.message}",
                  ),
                );
              },
              ifRight: (response) {
                if (response != null) {
                  showTopSnackBar(
                    displayDuration: Duration(minutes: 3),
                    Overlay.of(context),
                    CustomSnackBar.info(
                      message: "Response ${response},",
                      maxLines: 10,
                    ),
                  );
                }
              },
            );
          }
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text('Table two')),
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
                    MaterialPageRoute(builder: (context) => TableOnePage()),
                  );
                },
                child: Text('To Table 1'),
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
          Text(' Table Two data'),
          Expanded(
            child: StreamBuilder<List<TableTwoCollection>>(
              stream: IsarService.isar.tableTwoCollections
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
                              DBTable.table_two,
                              record.entityId,
                            );
                        relationResult.fold(
                          ifLeft: (err) {
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.error(
                                maxLines: 10,

                                message: "Something went wrong ${err.message}",
                              ),
                            );
                          },
                          ifRight: (relationList) async {
                            final result = await Helper.confDeletion(
                              context,
                              DBTable.table_two,
                              record.entityId,
                              relationList,
                            );
                            if (result != null && result) {
                              final model = TableTwoModel.fromCollection(
                                record,
                              );
                              final result = await sl<TableTwoDatasource>()
                                  .softDelete(model.toEntity());
                              result.fold(
                                ifLeft: (err) {
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.error(
                                      maxLines: 10,

                                      message:
                                          "Something went wrong ${err.message}",
                                    ),
                                  );
                                },
                                ifRight: (response) {
                                  if (response != null) {
                                    showTopSnackBar(
                                      displayDuration: Duration(minutes: 3),
                                      Overlay.of(context),
                                      CustomSnackBar.info(
                                        maxLines: 10,

                                        message: "Response ${response}",
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
                          final model = TableTwoModel.fromCollection(data[i]);
                          final result = await sl<TableTwoDatasource>().update(
                            model.toEntity().copyWith(message: message),
                          );
                          result.fold(
                            ifLeft: (err) {
                              print('cccccccccccccccccccccccccccccccccccc');
                              print(err);
                              showTopSnackBar(
                                displayDuration: Duration(minutes: 3),
                                Overlay.of(context),
                                CustomSnackBar.error(
                                  maxLines: 10,

                                  message:
                                      "Something went wrong ${err.message}",
                                ),
                              );
                            },
                            ifRight: (response) {
                              if (response != null) {
                                showTopSnackBar(
                                  displayDuration: Duration(minutes: 3),
                                  Overlay.of(context),
                                  CustomSnackBar.info(
                                    maxLines: 10,

                                    message: "Response ${response}",
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
                          Text("tableOne ${record.forKeyTableOne}"),
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
