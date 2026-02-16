import 'package:equatable/equatable.dart';
import 'package:sync_feature/sync_engine/domain/entities/standard_table_record.dart';

import '../../../../core/isar_service/collections/table_four_collection.dart';

class TableFourModel extends StandardTableRecord with EquatableMixin {
  final String message;
  final String forKeyTableTwo;
  const TableFourModel({
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
    forKeyTableTwo,
    centerId,
    message,
    byUser,
    byDevice,
    isDeleted,
    version,
    createdAt,
    updatedAt,
  ];
  factory TableFourModel.fromJson(Map<String, dynamic> json) {
    return TableFourModel(
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
  factory TableFourModel.fromCollection(TableFourCollection collection) {
    return TableFourModel(
      entityId: collection.entityId,
      centerId: collection.centerId,
      byUser: collection.byUser,
      byDevice: collection.byDevice,
      isDeleted: collection.isDeleted,
      version: collection.version,
      createdAt: collection.createdAt,
      updatedAt: collection.updatedAt,
      message: collection.message,
      forKeyTableTwo: collection.forKeyTableTwo,
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
  TableFourCollection toCollection() {
    return TableFourCollection()
      ..entityId = entityId
      ..forKeyTableTwo = forKeyTableTwo
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
