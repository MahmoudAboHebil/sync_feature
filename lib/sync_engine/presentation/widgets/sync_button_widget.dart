import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_feature/sync_engine/presentation/blocs/sync_bloc/sync_bloc.dart';
import 'package:sync_feature/sync_engine/presentation/blocs/sync_bloc/sync_event.dart';
import 'package:sync_feature/sync_engine/presentation/blocs/sync_bloc/sync_state.dart';
import 'package:sync_feature/sync_engine/presentation/pages/sync_results_page.dart';

class SyncButtonWidget extends StatefulWidget {
  const SyncButtonWidget({super.key});

  @override
  State<SyncButtonWidget> createState() => _SyncButtonWidgetState();
}

class _SyncButtonWidgetState extends State<SyncButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        if (state is SyncDone) {
          return Container(
            height: 200,
            child: Row(
              children: [
                state.results.isNotEmpty
                    ? TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SyncResultsPage(response: state.results),
                            ),
                          );
                        },
                        child: Text('go to Results ${state.results.length}'),
                      )
                    : Text('Every Thing is Oky'),
                SizedBox(width: 150),
                TextButton(
                  onPressed: () {
                    context.read<SyncBloc>().add(StartSync());
                  },
                  child: Text('Sync'),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.green),
                  ),
                ),
              ],
            ),
          );
        }
        if (state is SyncError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error'),
              Text(state.failure.message),
              Text('All Details'),
              Text(state.failure.toString()),
            ],
          );
        }

        return CircularProgressIndicator();
      },
    );
  }
}
