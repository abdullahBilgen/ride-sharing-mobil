import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_core/ride_core.dart';

class RiderMapPage extends StatefulWidget {
  const RiderMapPage({super.key});
  @override
  State<RiderMapPage> createState() => _RiderMapPageState();
}

class _RiderMapPageState extends State<RiderMapPage> {
  bool _searching = false, _matched = false;
  final _pickup = TextEditingController(text: 'Konumum · Karaköy, İstanbul');
  final _destination = TextEditingController();
  static const _mapStyle = '''[{"elementType":"geometry","stylers":[{"color":"#1d2028"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#8d929d"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#1d2028"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#343946"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#12151c"}]}]''';
  @override
  void dispose() { _pickup.dispose(); _destination.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(body: Stack(children: [
    GoogleMap(initialCameraPosition: const CameraPosition(target: LatLng(41.025, 28.974), zoom: 14.5), style: _mapStyle, myLocationEnabled: true, myLocationButtonEnabled: false, zoomControlsEnabled: false, compassEnabled: false, markers: {const Marker(markerId: MarkerId('pickup'), position: LatLng(41.025, 28.974), infoWindow: InfoWindow(title: 'Alınış noktası'))}),
    SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [_roundButton(Icons.menu), const SizedBox(width: 12), const Text('RIDE', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900)), const Spacer(), _roundButton(Icons.notifications_none)]))),
    Align(alignment: Alignment.bottomCenter, child: _bookingPanel()),
  ]));
  Widget _roundButton(IconData icon) => Material(color: RideColors.surface, shape: const CircleBorder(), child: IconButton(onPressed: () {}, icon: Icon(icon)));
  Widget _bookingPanel() => Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 20, 20, 30), decoration: const BoxDecoration(color: RideColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(5)))), const SizedBox(height: 18),
    Text(_matched ? 'SÜRÜCÜN YOLDA' : _searching ? 'SANA EN UYGUN SÜRÜCÜYÜ ARIYORUZ' : 'NEREYE GİDİYORSUN?', style: const TextStyle(color: RideColors.muted, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)), const SizedBox(height: 14),
    if (!_matched) ...[_routeField(Icons.circle, _pickup, 'Alınış noktası'), const SizedBox(height: 8), _routeField(Icons.location_on, _destination, 'Varış noktasını yaz')] else _driverCard(), const SizedBox(height: 15),
    SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: _matched ? () => setState(() { _matched = false; _searching = false; }) : () { if (_destination.text.trim().isEmpty) _destination.text = 'Nişantaşı, İstanbul'; setState(() => _searching = true); Future.delayed(const Duration(seconds: 4), () { if (mounted && _searching) setState(() { _searching = false; _matched = true; }); }); }, style: FilledButton.styleFrom(backgroundColor: RideColors.coral, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(_matched ? 'YOLCULUĞU GÖRÜNTÜLE' : _searching ? 'SÜRÜCÜ ARANIYOR…' : 'SÜRÜCÜ ÇAĞIR  ·  ₺248', style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .6)))),
    if (_matched) const Padding(padding: EdgeInsets.only(top: 12), child: Text('Canlı takip ve uygulama içi sohbet yolculuk sırasında kullanılabilir.', style: TextStyle(color: RideColors.muted, fontSize: 11))),
  ]));
  Widget _routeField(IconData icon, TextEditingController controller, String hint) => Row(children: [Icon(icon, size: 16, color: icon == Icons.circle ? RideColors.coral : RideColors.purple), const SizedBox(width: 10), Expanded(child: TextField(controller: controller, style: const TextStyle(fontSize: 14), decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13))))]);
  Widget _driverCard() => Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [const CircleAvatar(radius: 25, backgroundColor: RideColors.purple, child: Icon(Icons.person, color: Colors.white)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Deniz Yılmaz  ·  ★ 4.9', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 5), Text('Tesla Model 3  ·  34 RFL 208', style: TextStyle(color: RideColors.muted, fontSize: 12))])), const Text('4 dk', style: TextStyle(color: RideColors.coral, fontWeight: FontWeight.bold))])));
}
