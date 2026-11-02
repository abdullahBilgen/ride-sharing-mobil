import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ride_core/ride_core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DriverHome extends StatefulWidget { const DriverHome({super.key}); @override State<DriverHome> createState() => _DriverHomeState(); }
class _DriverHomeState extends State<DriverHome> {
  bool _online = false;
  String? _activePackage;
  DateTime? _expiresAt;
  Duration _remaining = Duration.zero;
  Timer? _ticker;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  WebSocketChannel? _socket;
  final _iap = InAppPurchase.instance;
  final _products = <String, ProductDetails>{};
  static const _productIds = {'3h', '6h', 'day', 'week'};
  @override void initState() { super.initState(); _purchaseSubscription = _iap.purchaseStream.listen(_onPurchases, onError: (_) {}); _loadProducts(); }
  Future<void> _loadProducts() async { if (!await _iap.isAvailable()) return; final result = await _iap.queryProductDetails(_productIds); if (mounted) setState(() { for (final product in result.productDetails) { _products[product.id] = product; } }); }
  void _onPurchases(List<PurchaseDetails> purchases) { for (final p in purchases) { if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) { final duration = p.productID == '3h' ? const Duration(hours: 3) : p.productID == '6h' ? const Duration(hours: 6) : p.productID == 'day' ? const Duration(hours: 24) : const Duration(days: 7); _activatePackage(p.productID, duration); } if (p.pendingCompletePurchase) _iap.completePurchase(p); } }
  void _activatePackage(String id, Duration duration) { setState(() { _activePackage = id; _expiresAt = DateTime.now().add(duration); }); _ticker?.cancel(); _ticker = Timer.periodic(const Duration(seconds: 1), (_) { final left = _expiresAt!.difference(DateTime.now()); if (mounted) setState(() => _remaining = left.isNegative ? Duration.zero : left); if (left.isNegative) { _ticker?.cancel(); if (mounted) setState(() => _activePackage = null); } }); }
  Future<void> _buy(RidePackage plan) async { final product = _products[plan.id]; if (product == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket mağaza ürünü olarak henüz yapılandırılmadı.'))); return; } await _iap.buyConsumable(purchaseParam: PurchaseParam(productDetails: product)); }
  Future<void> _toggleOnline(bool value) async {
    if (value && (_activePackage == null || _remaining == Duration.zero)) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Çevrimiçi olmak için önce aktif bir paket seç.'))); return; }
    if (!value) { await _positionSubscription?.cancel(); await _socket?.sink.close(); setState(() => _online = false); return; }
    var permission = await Geolocator.checkPermission(); if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Çevrimiçi olmak için konum izni gerekli.'))); return; }
    // Configure RIDE_WS_URL and an authenticated socket before release.
    final endpoint = const String.fromEnvironment('RIDE_WS_URL', defaultValue: 'wss://api.example.com/ws/driver/location');
    _socket = WebSocketChannel.connect(Uri.parse(endpoint)); await _socket!.ready;
    _positionSubscription = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15)).listen((p) => _socket?.sink.add(jsonEncode({'type': 'driver.location', 'lat': p.latitude, 'lng': p.longitude, 'at': DateTime.now().toUtc().toIso8601String()})));
    if (mounted) setState(() => _online = true);
  }
  @override void dispose() { _ticker?.cancel(); _positionSubscription?.cancel(); _purchaseSubscription?.cancel(); _socket?.sink.close(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('RIDEFLOW  /  DRIVER', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.account_circle_outlined))]), body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 6, 20, 28), children: [
    const Text('Günün güzel geçsin,', style: TextStyle(color: RideColors.muted)), const SizedBox(height: 4), const Text('Mert 👋', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)), const SizedBox(height: 20), _statusCard(), const SizedBox(height: 24),
    Row(children: [const Expanded(child: Text('SÜRÜŞ PAKETİNİ SEÇ', style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: RideColors.muted, fontWeight: FontWeight.bold))), if (_activePackage != null) _countdown()]), const SizedBox(height: 12), ...RidePackage.available.map(_packageCard), const SizedBox(height: 18), _requestCard(), const SizedBox(height: 14), const Text('Belgeler: Onaylandı  ✓', style: TextStyle(color: RideColors.muted, fontSize: 12)),
  ])));
  Widget _statusCard() => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: _online ? RideColors.coral : RideColors.muted, shape: BoxShape.circle, boxShadow: _online ? [BoxShadow(color: RideColors.coral.withValues(alpha: .6), blurRadius: 12)] : null)), const SizedBox(width: 10), Expanded(child: Text(_online ? 'Yolculuklara açıksın' : 'Çevrimdışısın', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))), Switch.adaptive(value: _online, activeTrackColor: RideColors.coral, onChanged: _toggleOnline)]), const SizedBox(height: 8), const Divider(color: Colors.white10), const SizedBox(height: 8), Row(children: [const Icon(Icons.my_location, color: RideColors.purple), const SizedBox(width: 10), Expanded(child: Text(_online ? 'Konumun yolculuk eşleşmeleri için paylaşılıyor' : 'Yakındaki yolculukları görmek için çevrimiçi ol', style: const TextStyle(fontSize: 12, color: RideColors.muted)))] )])));
  Widget _countdown() => Text('${_remaining.inHours.toString().padLeft(2, '0')}:${(_remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(color: RideColors.coral, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()]));
  Widget _packageCard(RidePackage plan) { final selected = _activePackage == plan.id; final product = _products[plan.id]; return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: RideColors.purple.withValues(alpha: .16), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt, color: RideColors.purple)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${plan.title}  ·  ${plan.duration}', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(selected ? 'Aktif paket' : plan.subtitle, style: const TextStyle(color: RideColors.muted, fontSize: 11))])), Text(product?.price ?? plan.price, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(width: 8), if (!selected) IconButton(onPressed: () => _buy(plan), icon: const Icon(Icons.arrow_forward, color: RideColors.coral)) else const Icon(Icons.check_circle, color: RideColors.coral)]))); }
  Widget _requestCard() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.notifications_active_outlined, color: RideColors.coral), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Yeni yolculuk teklifi', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Teklif geldiğinde 15 saniyede yanıtla', style: TextStyle(color: RideColors.muted, fontSize: 11))])), TextButton(onPressed: () {}, child: const Text('ÖRNEK'))])));
}
