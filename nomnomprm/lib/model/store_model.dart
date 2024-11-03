// store_model.dart
class Store {
  final String storeId;
  final String areaId;
  final String name;
  final String address;
  final int status;
  final String phone;
  final String openTime;
  final String closeTime;
  final String areaName;
  final List<String> session;

  Store({
    required this.storeId,
    required this.areaId,
    required this.name,
    required this.address,
    required this.status,
    required this.phone,
    required this.openTime,
    required this.closeTime,
    required this.areaName,
    required this.session,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['storeId'],
      areaId: json['areaId'],
      name: json['name'],
      address: json['address'],
      status: json['status'],
      phone: json['phone'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      areaName: json['areaName'],
      session: List<String>.from(json['session']),
    );
  }
}
