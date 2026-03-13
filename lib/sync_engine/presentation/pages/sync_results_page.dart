import 'package:flutter/material.dart';
import 'package:sync_feature/core/error/sync_response.dart';

class SyncResultsPage extends StatelessWidget {
  const SyncResultsPage({this.response, this.errorMessage, super.key});
  final List<SyncResponse>? response;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: errorMessage == null
          ? ListView.builder(
              itemCount: response?.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Center(child: Text(response![index].toString())),
                );
              },
            )
          : Column(children: [Text(errorMessage!)]),
    );
  }
}
