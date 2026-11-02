import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ride_core/ride_core.dart';
import 'features/booking/presentation/rider_map_page.dart';

void main() => runApp(const ProviderScope(child: RiderApp()));

class RiderApp extends StatelessWidget {
  const RiderApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'RideFlow',
        debugShowCheckedModeBanner: false,
        theme: buildRideTheme(),
        home: const RiderMapPage(),
      );
}
