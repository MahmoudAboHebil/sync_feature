import 'package:equatable/equatable.dart';
import 'package:sync_feature/sync_engine/data/data_source/models/standard_table_record_model.dart';
import 'package:sync_feature/sync_engine/domain/entities/table_three.dart';

import '../../../../core/isar_service/collections/table_three_collection.dart';

class TableThreeModel extends StandardTableRecordModel with EquatableMixin {
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
      entityId: json['id'],
      forKeyTableTwo: json['table_two_id'],
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

  factory TableThreeModel.fromCollection(TableThreeCollection collection) {
    return TableThreeModel(
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
  factory TableThreeModel.fromEntity(TableThree entity) {
    return TableThreeModel(
      entityId: entity.entityId,
      centerId: entity.centerId,
      byUser: entity.byUser,
      byDevice: entity.byDevice,
      isDeleted: entity.isDeleted,
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      message: entity.message,
      forKeyTableTwo: entity.forKeyTableTwo,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': entityId,
      'table_two_id': forKeyTableTwo,
      'center_id': centerId,
      'by_user': byUser,
      'by_device': byDevice,
      'is_deleted': isDeleted,
      'version': version,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
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
