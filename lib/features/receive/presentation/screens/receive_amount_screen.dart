import 'package:bb_mobile/app_router.dart';
import 'package:bb_mobile/features/receive/presentation/bloc/receive_bloc.dart';
import 'package:bb_mobile/features/receive/receive_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ReceiveAmountScreen extends StatelessWidget {
  const ReceiveAmountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Receive Amount Screen'),
          FilledButton(
            onPressed: () {
              final state = context.read<ReceiveBloc>().state;
              final baseRoute = state is ReceiveLightning
                  ? AppRoute.receiveLightning
                  : state is ReceiveLiquid
                      ? AppRoute.receiveLiquid
                      : AppRoute.receiveBitcoin;
              context.replace(
                '${baseRoute.path}/${ReceiveSubroute.invoice.path}',
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
