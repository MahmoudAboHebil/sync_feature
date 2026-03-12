import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:sync_feature/context/data/data_source/table_five_datasource.dart';
import 'package:sync_feature/core/isar_service/collections/table_five_collection.dart';
import 'package:sync_feature/core/isar_service/collections/table_four_collection.dart';
import 'package:sync_feature/core/isar_service/collections/table_three_collection.dart';
import 'package:sync_feature/sync_engine/data/models/table_five_model.dart';
import 'package:sync_feature/sync_engine/data/models/table_four_model.dart';
import 'package:sync_feature/sync_engine/data/models/table_three_model.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_five.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_four.dart';
import 'package:sync_feature/sync_engine/domain/repository/sync_repository.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_four.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_one.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_three.dart';
import 'package:sync_feature/sync_engine/presentation/pages/table_two.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:uuid/uuid.dart';

import '../../../config/constants.dart';
import '../../../core/enums/DB_Table.dart';
import '../../../core/helper.dart';
import '../../../core/internet_service/internet_bloc/internet_bloc.dart';
import '../../../core/internet_service/internet_bloc/internet_state.dart';
import '../../../core/isar_service/isar_service.dart';
import '../../../injection_container.dart';
import '../../domain/entities/table_three.dart';
import '../../domain/repository/table_repository.dart';
import '../widgets/sync_button_widget.dart';
import 'home_page.dart';

class TableFivePage extends StatelessWidget {
  const TableFivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Uuid uuid = Uuid();
          final message = await Helper.showAddRecordDialog(context);
          List<TableThreeCollection> parentRecords = await IsarService
              .isar
              .tableThreeCollections
              .filter()
              .isDeletedEqualTo(false)
              .sortByCreatedAtDesc()
              .findAll();

          final data3 = parentRecords
              .map((e) => TableThreeModel.fromCollection(e).toEntity())
              .toList();
          final TableThree? tableThree =
              await Helper.getParentId(context, data3) as TableThree?;
          List<TableFourCollection> parentRecords2 = await IsarService
              .isar
              .tableFourCollections
              .filter()
              .isDeletedEqualTo(false)
              .sortByCreatedAtDesc()
              .findAll();

          final data4 = parentRecords2
              .map((e) => TableFourModel.fromCollection(e).toEntity())
              .toList();

          final TableFour? tableFour =
              await Helper.getParentId(context, data4) as TableFour?;
          final getResult = await sl<SyncRepository>().getDeviceId();
          if (message != null &&
              getResult.isRight &&
              tableThree != null &&
              tableFour != null) {
            final byDevice = getResult.getOrThrow();
            final newRecord = TableFive(
              forKeyTableFour: tableFour.entityId,
              forKeyTableThree: tableThree.entityId,
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
            final result = await sl<TableFiveDatasource>().create(newRecord);
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
                      message: "Response ${response}",
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
      appBar: AppBar(title: Text('Table Five')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BlocBuilder<InternetBloc, InternetState>(
            builder: (context, state) {
              if (state is InternetConnected) {
                return const SyncButtonWidget();
              } else {
                return Text('there is no internet');
              }
            },
          ),
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
            ],
          ),

          Text(' Table Five data'),
          Expanded(
            child: StreamBuilder<List<TableFiveCollection>>(
              stream: IsarService.isar.tableFiveCollections
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
                              DBTable.table_five,
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
                              DBTable.table_five,
                              record.entityId,
                              relationList,
                            );
                            if (result != null && result) {
                              final model = TableFiveModel.fromCollection(
                                record,
                              );
                              final result = await sl<TableFiveDatasource>()
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
                          final result = await sl<TableFiveDatasource>().update(
                            TableFiveModel.fromCollection(
                              data[i],
                            ).toEntity().copyWith(message: message),
                          );
                          result.fold(
                            ifLeft: (err) {
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
                          Text("tableFour ${record.forKeyTableFour} /"),
                          Text("tableThree ${record.forKeyTableThree}"),
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
