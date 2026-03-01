import 'package:sync_feature/core/helper.dart';

class NetworkResponse {
  final String? details;
  final Map<String, dynamic>? data;
  const NetworkResponse({this.details, this.data});
}

// done
class NetworkSuccess extends NetworkResponse {
  @override
  String toString() {
    return '''NetworkSuccess ''';
  }
}

// done
class OperationAlreadyProcessed extends NetworkSuccess {
  @override
  String toString() {
    return '''NetworkSuccess (OperationAlreadyProcessed)''';
  }
}

class NetworkFailure extends NetworkResponse {
  const NetworkFailure({super.details, super.data});
  @override
  String toString() {
    return '''NetworkFailure  details=> \n$details \ndata=> \n$data''';
  }
}

//done
class ParentIsDeleted extends NetworkFailure {
  ParentIsDeleted(Map<String, dynamic> parentIds)
    : super(data: Helper.cleanParentIds(parentIds));
  @override
  String toString() {
    return '''NetworkFailure (ParentIsDeleted) data=> \n$data''';
  }
}

// done
class EntityIsNotFound extends NetworkFailure {
  const EntityIsNotFound({required super.data});
  @override
  String toString() {
    return '''NetworkFailure (EntityIsNotFound) data=> \n$data''';
  }
}

// done
class EntityIsDeleted extends NetworkFailure {
  const EntityIsDeleted({required super.data});
  @override
  String toString() {
    return '''NetworkFailure (EntityIsDeleted) data=> \n$data''';
  }
}

//done
class VersionConflict extends NetworkFailure {
  const VersionConflict({required super.data});
  @override
  String toString() {
    return '''NetworkFailure (VersionConflict)  data=>\n $data''';
  }
}

class InternalServerError extends NetworkFailure {
  const InternalServerError({required super.details});
  @override
  String toString() {
    return '''NetworkFailure (InternalServerError) details=> \n$details''';
  }
}
