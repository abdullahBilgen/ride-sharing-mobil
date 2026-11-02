import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_core/ride_core.dart';
import 'features/driver_dashboard/presentation/driver_dashboard.dart';

void main() => runApp(const ProviderScope(child: DriverApp()));

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'RideFlow Driver',
        debugShowCheckedModeBanner: false,
        theme: buildRideTheme(),
        home: const DriverHome(),
      );
}
