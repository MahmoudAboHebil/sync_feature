import 'package:equatable/equatable.dart';
import 'package:sync_feature/sync_engine/data/models/standard_table_record_model.dart';

import '../../../../core/isar_service/collections/table_four_collection.dart';
import '../../domain/entities/table_four.dart';

class TableFourModel extends StandardTableRecordModel with EquatableMixin {
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
      entityId: json['id'],
      forKeyTableTwo: json['table_two_id'],
      centerId: json['center_id'],
      byUser: json['by_user'],
      byDevice: json['by_device'],
      isDeleted: json['is_deleted'] as bool,
      version: json['version'] as int,
      createdAt: DateTime.parse(json['created_at']).toUtc(),
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
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
  factory TableFourModel.fromEntity(TableFour entity) {
    return TableFourModel(
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
