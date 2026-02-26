//ToDo: (0) when creating objects with datatime create them as UTC()
//ToDo: (0) to save them local and remote
//ToDo: (0) isar does not care about utc or local when putting data,but
//ToDo: (0) so when getting data from it must be UTC

//ToDo: (1) create table model
//ToDo: (2) create local table datasource impl
//ToDo: (3) create table collection
//ToDo: (4) update table enum
//ToDo: (5) update tabelRelationsNotNull variable at (this file)
//ToDo: (6) update (table_repository_impl.dart)=> ALL-FUNCTIONS
//ToDo: (7) do a test

import '../isar_service/collections/table_five_collection.dart';
import '../isar_service/collections/table_four_collection.dart';
import '../isar_service/collections/table_one_collection.dart';
import '../isar_service/collections/table_three_collection.dart';
import '../isar_service/collections/table_two_collection.dart';

enum DBTable {
  table_one,
  table_two,
  table_three,
  table_four,
  table_five;

  static DBTable getDBTableFromString(String table) {
    for (final tab in DBTable.values) {
      if (tab.name == table) return tab;
    }
    throw Exception('$table is not found');
  }

  List<DBTable> getForwardNotNull() {
    final list = tabelRelationsNotNull[this]?["forward"];
    if (list == null) throw Exception('$this forward relation not found');
    return list;
  }
}

const Map<DBTable, Map<String, List<DBTable>>> tabelRelationsNotNull = {
  DBTable.table_one: {
    "forward": [DBTable.table_two],
    "backword": [],
  },
  DBTable.table_two: {
    "forward": [DBTable.table_three, DBTable.table_four],
    "backword": [DBTable.table_one],
  },
  DBTable.table_three: {
    "forward": [DBTable.table_five],
    "backword": [DBTable.table_two],
  },
  DBTable.table_four: {
    "forward": [DBTable.table_five],
    "backword": [DBTable.table_two],
  },
  DBTable.table_five: {
    "forward": [],
    "backword": [DBTable.table_three, DBTable.table_four],
  },
};

final List<TableOneCollection> tableOne = [
  TableOneCollection()
    ..id = 1
    ..entityId = 'tab-1-enti-1'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 1)
    ..createdAt = DateTime(2025, 1, 1, 1)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
  TableOneCollection()
    ..id = 2
    ..entityId = 'tab-1-enti-2'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 2)
    ..createdAt = DateTime(2025, 1, 1, 2)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
];
//---------------table two------------------------
final List<TableTwoCollection> tableTwo = [
  TableTwoCollection()
    ..id = 1
    ..entityId = 'tab-2-enti-1'
    ..forKeyTableOne = 'tab-1-enti-1'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 3)
    ..createdAt = DateTime(2025, 1, 1, 3)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
  TableTwoCollection()
    ..id = 2
    ..entityId = 'tab-2-enti-2'
    ..forKeyTableOne = 'tab-1-enti-2'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 4)
    ..createdAt = DateTime(2025, 1, 1, 4)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
];
//---------------table Three------------------------
final List<TableThreeCollection> tableThree = [
  TableThreeCollection()
    ..id = 1
    ..entityId = 'tab-3-enti-1'
    ..forKeyTableTwo = 'tab-2-enti-1'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 5)
    ..createdAt = DateTime(2025, 1, 1, 5)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
  TableThreeCollection()
    ..id = 2
    ..entityId = 'tab-3-enti-2'
    ..forKeyTableTwo = 'tab-2-enti-1'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 6)
    ..createdAt = DateTime(2025, 1, 1, 6)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
];
//---------------table Four------------------------
final List<TableFourCollection> tableFour = [
  TableFourCollection()
    ..id = 1
    ..entityId = 'tab-4-enti-1'
    ..forKeyTableTwo = 'tab-2-enti-1'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 7)
    ..createdAt = DateTime(2025, 1, 1, 7)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
  TableFourCollection()
    ..id = 2
    ..entityId = 'tab-4-enti-2'
    ..forKeyTableTwo = 'tab-2-enti-2'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 8)
    ..createdAt = DateTime(2025, 1, 1, 8)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
];
//---------------table Four------------------------
final List<TableFiveCollection> tableFive = [
  TableFiveCollection()
    ..id = 1
    ..entityId = 'tab-5-enti-1'
    ..forKeyTableThree = 'tab-3-enti-1'
    ..forKeyTableFour = 'tab-4-enti-1'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 9)
    ..createdAt = DateTime(2025, 1, 1, 9)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
  TableFiveCollection()
    ..id = 2
    ..entityId = 'tab-5-enti-2'
    ..forKeyTableThree = 'tab-3-enti-2'
    ..forKeyTableFour = 'tab-4-enti-1'
    ..byUser = '---'
    ..isDeleted = false
    ..message = '---'
    ..updatedAt = DateTime(2025, 1, 1, 10)
    ..createdAt = DateTime(2025, 1, 1, 10)
    ..version = 1
    ..byDevice = '---'
    ..centerId = '---',
];
