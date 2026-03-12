import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_feature/sync_engine/domain/entities/standard_table_record.dart';

import 'enums/DB_Table.dart';
import 'error/netwrok_response.dart';

class Helper {
  static Iterable<List<T>> chunk<T>(List<T> list, int size) sync* {
    for (int i = 0; i < list.length; i += size) {
      yield list.sublist(i, i + size > list.length ? list.length : i + size);
    }
  }

  static Future<StandardTableRecord?> getParentId(
    BuildContext context,
    List<StandardTableRecord> data,
  ) async {
    final formKey = GlobalKey<FormState>();

    StandardTableRecord? tableEntity;

    final result = await showDialog<StandardTableRecord?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(" Get parent"),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /// المرحلة التعليمية
                        DropdownButtonFormField<StandardTableRecord>(
                          decoration: const InputDecoration(
                            labelText: "المرحلة التعليمية",
                          ),
                          items: data
                              .map<DropdownMenuItem<StandardTableRecord>>((
                                entity,
                              ) {
                                return DropdownMenuItem(
                                  value: entity,
                                  child: Column(
                                    children: [Text(entity.entityId)],
                                  ),
                                );
                              })
                              .toList(),
                          onChanged: (value) {
                            tableEntity = value;
                          },
                          validator: (value) =>
                              value == null ? "Chose one" : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      Navigator.pop(context, tableEntity);
                    }
                  },
                  child: const Text("حفظ"),
                ),
              ],
            );
          },
        );
      },
    );
    return result;
  }

  static Future<String?> showAddRecordDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String name = '';

    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("إضافة record"),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /// الاسم
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Message",
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "ادخل Message"
                              : null,
                          onSaved: (value) => name = value!,
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      Navigator.pop(context, name);
                    }
                  },
                  child: const Text("حفظ"),
                ),
              ],
            );
          },
        );
      },
    );
    return result;
  }

  static Future<bool?> confDeletion(
    BuildContext context,
    DBTable startTable,
    String startEntity,
    Map<DBTable, List<String>> deletedEntities,
  ) async {
    List<Widget> relationDeletedWidgets() {
      List<Text> list = [];
      for (var item in deletedEntities.entries) {
        list.add(Text('${item.key.name} -=> ${item.value}'));
      }
      return list;
    }

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Delete a record"),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text('delete $startEntity in ${startTable.name}'),
                        Text('and those will be deleted'),
                        Column(children: relationDeletedWidgets()),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context, true);
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          },
        );
      },
    );
    return result;
  }

  static Map<String, List<String>> cleanParentIds(
    Map<String, dynamic> parentIds,
  ) {
    final Map<String, List<String>> result = {};

    parentIds.forEach((table, ids) {
      final List<String> cleanedIds = [];
      for (final id in ids as List) {
        // Remove _deleted or _not_found suffix
        String cleanId = id.toString();
        if (cleanId.endsWith('_deleted')) {
          cleanId = cleanId.replaceAll('_deleted', '');
        }
        if (cleanId.endsWith('_not_found')) {
          cleanId = cleanId.replaceAll('_not_found', '');
        }
        cleanedIds.add(cleanId);
      }
      result[table] = cleanedIds;
    });

    return result;
  }

  static NetworkResponse handleSyncOperationResponse(
    Map<String, dynamic> json,
  ) {
    final message = json['message'];
    switch (message) {
      case 'parent_is_deleted':
        return ParentIsDeleted(json['parent_ids'] as Map<String, dynamic>);
      case 'entity_not_found':
        return EntityIsNotFound(data: json);
      case 'Operation already processed':
        return OperationAlreadyProcessed();
      case 'entity_is_deleted':
        return EntityIsDeleted(data: json);
      case 'version_conflict':
        return VersionConflict(
          data: json['server_record'] as Map<String, dynamic>,
        );
      case 'internal_server_error':
        return InternalServerError(details: json['error']);
      case null: // success case
        return NetworkSuccess();
      default:
        return NetworkFailure(details: message, data: json);
    }
  }

  static Future<String?> login(String email, String password) async {
    final supabase = Supabase.instance.client;

    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session != null) {
      print("Login Success");
      return response.session!.accessToken;
    } else {
      print("Login Failed");
      return null;
    }
  }
}
