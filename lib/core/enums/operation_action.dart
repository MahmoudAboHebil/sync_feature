enum OperationAction {
  create,
  delete,
  update;

  static OperationAction getOperationActionFromString(String action) {
    for (final act in OperationAction.values) {
      if (act.name == action) return act;
    }
    throw Exception('$action is not found');
  }
}
