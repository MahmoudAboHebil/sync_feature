import 'package:supabase_flutter/supabase_flutter.dart';

import 'error/netwrok_response.dart';

class Helper {
  static Iterable<List<T>> chunk<T>(List<T> list, int size) sync* {
    for (int i = 0; i < list.length; i += size) {
      yield list.sublist(i, i + size > list.length ? list.length : i + size);
    }
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
