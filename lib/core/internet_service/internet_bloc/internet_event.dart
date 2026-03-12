abstract class InternetEvent {}

class InternetStatusChanged extends InternetEvent {
  final bool isConnected;

  InternetStatusChanged(this.isConnected);
}
