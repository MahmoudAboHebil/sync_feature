import 'package:equatable/equatable.dart';
import 'package:sync_feature/sync_engine/domain/entities/standard_table_record.dart';

import '../../../../core/isar_service/collections/table_three_collection.dart';

class TableThreeModel extends StandardTableRecord with EquatableMixin {
  final String message;
  final String forKeyTableTwo;

  const TableThreeModel({
    required super.entityId,
    required this.message,
    required this.forKeyTableTwo,
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
    centerId,
    forKeyTableTwo,
    message,
    byUser,
    byDevice,
    isDeleted,
    version,
    createdAt,
    updatedAt,
  ];
  factory TableThreeModel.fromJson(Map<String, dynamic> json) {
    return TableThreeModel(
      entityId: json['entity_id'],
      forKeyTableTwo: json['forkey_table_two'],
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
      'forkey_table_two': forKeyTableTwo,
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
  TableThreeCollection toCollection() {
    return TableThreeCollection()
      ..entityId = entityId
      ..centerId = centerId
      ..forKeyTableTwo = forKeyTableTwo
      ..byUser = byUser
      ..byDevice = byDevice
      ..isDeleted = isDeleted
      ..version = version
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..message = message;
  }
}
