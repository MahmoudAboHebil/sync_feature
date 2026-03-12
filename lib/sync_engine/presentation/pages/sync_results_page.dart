import 'package:flutter/material.dart';
import 'package:sync_feature/core/error/sync_response.dart';

class SyncResultsPage extends StatelessWidget {
  const SyncResultsPage({required this.response, super.key});
  final List<SyncResponse> response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: response.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Center(child: Text(response[index].toString())),
          );
        },
      ),
    );
  }
}
