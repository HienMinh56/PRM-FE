class Order {
  final String id;
  final String name;
  final DateTime date;
  final double price;
  final String status;
  final int quantity;
  final String voucher;

  Order({
    required this.id,
    required this.name,
    required this.date,
    required this.price,
    required this.status,
    required this.quantity,
    required this.voucher,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    String statusString;
    switch (json['status']) {
      case 1:
        statusString = 'Cancel';
        break;
      case 2:
        statusString = 'Done';
        break;
      case 3:
        statusString = 'Accepted';
        break;
      default:
        statusString = 'Unknown';
    }

    return Order(
      id: json['orderId'],
      name: json['storeName'],
      date: DateTime.parse(json['createdDate']).toLocal(),
      price: json['price'].toDouble(),
      status: statusString,
      quantity: json['quantity'],
      voucher: json['voucherCode'],
    );
  }
}
