List<Map<String, dynamic>> getRecordsThatFKfieldsThatRequired(
  String entityId,
  String table,
) {
  List<Map<String, dynamic>> list = [];
  //todo: 1) find every forgine key ids (forgine keys that not-null-colum not the value itself)in $(table) for that record ( id== $entityId)
  //todo: 2) get forgine key ids records in there its tables
  //todo: 3) return them
  return list;
}

Map<String, dynamic>? getRecordInTable(String entityId, String table) {
  Map<String, dynamic> entity = {};
  // todo: return the record that (id==$entityId ) in that $table table
  return entity;
}

dynamic send_operation(
  Map<String, dynamic> operationJson,
  String device_id,
  String user_id,
  Map<String, List<String>>? tablesEntitiesIdsRemove,
) {
  Map<String, dynamic> sendedTableRecord = operationJson['table_record'];
  String action = operationJson['action'];
  String entityId = operationJson['entity_id'];
  int version = operationJson['version'] as int;
  String centerId = operationJson['center_id'];
  String by_role = operationJson['user_role'];
  String table = operationJson['table'];
  Map<String, dynamic>? serverTableRecord = getRecordInTable(entityId, table);
  final exit =
      (by_role == 'owner' && serverTableRecord!['user_role'] == 'admin');

  List<Map<String, dynamic>> parents = getRecordsThatFKfieldsThatRequired(
    entityId,
    table,
  );
  if (action == 'create') {
    final deletedRecords = parents
        .where((record) => record['is_deleted'] == true)
        .toList();

    if (deletedRecords.isNotEmpty) {
      String message = 'parent_is_deleted';
      //todo: return the $message  and  $deletedRecords as response
      return;
    } else {
      sendedTableRecord['push_time'] = DateTime.now();
      sendedTableRecord['updated_at'] = DateTime.parse(
        sendedTableRecord['updated_at'],
      );
      sendedTableRecord['created_at'] = DateTime.parse(
        sendedTableRecord['created_at'],
      );
      sendedTableRecord['version'] = 1;
      //todo: add $sendedTableRecord in that table $table
      //todo: return success as response
      return;
    }
  } else if (serverTableRecord!["is_deleted"] == true) {
    String message = 'entity_is_deleted';
    //todo: return the $message   as response
    return;
  } else if (action == 'delete') {
    sendedTableRecord['push_time'] = DateTime.now();
    sendedTableRecord['version'] = serverTableRecord['version'] + 1;
    sendedTableRecord['is_deleted'] = true;
    sendedTableRecord['updated_at'] = DateTime.parse(
      sendedTableRecord['updated_at'],
    );
    sendedTableRecord['created_at'] = DateTime.parse(
      sendedTableRecord['created_at'],
    );
    //todo: updated  record (id==$entityId) with $sendedTableRecord at $table table
    if (tablesEntitiesIdsRemove != null) {
      for (final item in tablesEntitiesIdsRemove.entries) {
        final recordTable = item.key;
        final entitiesIds = item.value;
        for (final id in entitiesIds) {
          Map<String, dynamic>? serverTableRecord = getRecordInTable(
            id,
            recordTable,
          );
          if (serverTableRecord == null) continue;
          serverTableRecord['push_time'] = DateTime.now();
          serverTableRecord['version'] = serverTableRecord['version'] + 1;
          serverTableRecord['by_user'] = user_id;
          serverTableRecord['by_device'] = device_id;
          serverTableRecord['updated_at'] = DateTime.now();
          serverTableRecord['user_role'] = by_role;
          serverTableRecord['is_deleted'] = true;
          //todo: updated  record (id==$id) with $serverTableRecord in $recordTable
        }
      }
    }
    //todo: return success as response
    return;
  } else if (version < serverTableRecord['version']) {
    String message = 'version_conflict';
    //todo: return the $message  and $serverTableRecord as response
    return;
  } else {
    final deletedRecords = parents
        .where((record) => record['is_deleted'] == true)
        .toList();

    if (deletedRecords.isNotEmpty) {
      String message = 'parent_is_deleted';
      //todo: return the $message  and  $deletedRecords as response
      return;
    } else {
      sendedTableRecord['push_time'] = DateTime.now();
      sendedTableRecord['updated_at'] = DateTime.parse(
        sendedTableRecord['updated_at'],
      );
      sendedTableRecord['created_at'] = DateTime.parse(
        sendedTableRecord['created_at'],
      );
      sendedTableRecord['version'] = serverTableRecord['version'] + 1;
      //todo: updated  record (id==$entityId) with $sendedTableRecord at $table table
      //todo: return success as response
      return;
    }
  }
}

// Future<void> syncOperationExample() async {
//   final url = Uri.parse(
//     'https://YOUR_PROJECT_ID.functions.supabase.co/sync-operation',
//   );
//
//   final payload = {
//     "operation": {
//       "operation_id": "op_123456", // 🔹 idempotency
//       "table": "my_table",
//       "entity_id": "uuid-of-entity",
//       "action": "update", // create | update | delete
//       "version": 2,
//       "table_record": {
//         "id": "uuid-of-entity",
//         "name": "Updated Name",
//         "created_at": DateTime.now()
//             .subtract(Duration(days: 2))
//             .toIso8601String(),
//         "updated_at": DateTime.now().toIso8601String(),
//       },
//       "user_role": "admin",
//       "center_id": "uuid-of-center",
//     },
//     "parent_ids": {
//       "parent_table1": ["uuid1", "uuid2"],
//     },
//     "tablesEntitiesIdsRemove": {
//       "child_table1": ["child_uuid1", "child_uuid2"],
//     },
//     "device_id": "device_123",
//     "user_id": "user_123",
//   };
//
//   final response = await http.post(
//     url,
//     body: jsonEncode(payload),
//     headers: {'Content-Type': 'application/json'},
//   );
//
//   print('Status: ${response.statusCode}');
//   print('Body: ${response.body}');
// }

/*

2️⃣ كل حالات الـ Response بصيغة JSON
✅ Success Responses
Create / Update / Delete successful
{
  "success": true
}

Operation already processed (Idempotency)
{
  "success": true,
  "message": "Operation already processed"
}

❌ Failed / Validation Responses
Parent is deleted or not found
{
  "message": "parent_is_deleted",
  "parent_ids": {
    "parent_table1": [ "uuid3"],
    "parent_table2": ["uuid2"]
  }
}

Entity not found
{
  "message": "entity_not_found"
}

Entity already deleted
{
  "message": "entity_is_deleted"
}

Version conflict
{
  "message": "version_conflict",
  "server_record": {
    "id": "uuid-of-entity",
    "name": "Server Name",
    "version": 3,
    "is_deleted": false,
    "created_at": "2026-02-17T12:00:00.000Z",
    "updated_at": "2026-02-17T14:00:00.000Z"
  }
}

Internal server error (catch-all)
{
  "error": "internal_server_error",
  "details": "Error message here"
}
*/
