import 'package:equatable/equatable.dart';
import 'package:sync_feature/core/isar_service/collections/table_two_collection.dart';
import 'package:sync_feature/sync_engine/domain/entities/standard_table_record.dart';

class TableTwoModel extends StandardTableRecord with EquatableMixin {
  final String message;
  final String forkeyTableOne;
  const TableTwoModel({
    required super.entityId,
    required this.forkeyTableOne,
    required this.message,
    required super.centerId,
    required super.byUser,
    required super.byDevice,
    required super.isDeleted,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
  });

  @override
  List<Object> get props => [
    entityId,
    forkeyTableOne,
    centerId,
    message,
    byUser,
    byDevice,
    isDeleted,
    version,
    createdAt,
    updatedAt,
  ];
  factory TableTwoModel.fromJson(Map<String, dynamic> json) {
    return TableTwoModel(
      forkeyTableOne: json['forkey_table_one'],
      entityId: json['entity_id'],
      centerId: json['center_id'],
      byUser: json['by_user'],
      byDevice: json['by_device'],
      isDeleted: json['is_deleted'] as bool,
      version: json['version'] as int,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      message: json['message'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'entity_id': entityId,
      'forkey_table_one': forkeyTableOne,
      'center_id': centerId,
      'by_user': byUser,
      'by_device': byDevice,
      'is_deleted': isDeleted,
      'version': version,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'message': message,
    };
  }

  @override
  TableTwoCollection toCollection() {
    return TableTwoCollection()
      ..entityId = entityId
      ..forKeyTableOne = forkeyTableOne
      ..centerId = centerId
      ..byUser = byUser
      ..byDevice = byDevice
      ..isDeleted = isDeleted
      ..version = version
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..message = message;
  }
}
