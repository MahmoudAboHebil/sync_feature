enum OperationState {
  pending,
  processing,
  dead;

  static OperationState getOperationStateFromString(String state) {
    for (final act in OperationState.values) {
      if (act.name == state) return act;
    }
    throw Exception('$state is not found');
  }
}
