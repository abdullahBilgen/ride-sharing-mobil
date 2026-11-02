enum DriverApprovalStatus { pending, approved, rejected }
enum RideStatus { requested, searching, matched, inProgress, completed, cancelled }

class DriverProfile {
  const DriverProfile({required this.id, required this.name, required this.rating, required this.vehicleModel, required this.plate});
  final String id, name, vehicleModel, plate;
  final double rating;
}

class RideRequest {
  const RideRequest({required this.id, required this.pickup, required this.destination, required this.status});
  final String id, pickup, destination;
  final RideStatus status;
}

class RidePackage {
  const RidePackage({required this.id, required this.title, required this.duration, required this.price, required this.subtitle});
  final String id, title, duration, price, subtitle;
  static const available = [
    RidePackage(id: '3h', title: 'Sprint', duration: '3 saat', price: '₺149', subtitle: 'Kısa süreli sürüş'),
    RidePackage(id: '6h', title: 'Shift', duration: '6 saat', price: '₺249', subtitle: 'Yarım gün özgürlük'),
    RidePackage(id: 'day', title: 'Daily', duration: 'Tam gün', price: '₺399', subtitle: 'Gün boyu kesintisiz'),
    RidePackage(id: 'week', title: 'Weekly', duration: '7 gün', price: '₺1.899', subtitle: 'En iyi birim fiyat'),
  ];
}
