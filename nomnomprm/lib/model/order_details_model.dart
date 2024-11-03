class OrderDetail {
  final String orderId;
  final String foodId;
  final String foodTitle;
  final int quantity;
  final int price;
  final String image;
  final String? note;

  OrderDetail({
    required this.orderId,
    required this.foodId,
    required this.foodTitle,
    required this.quantity,
    required this.price,
    required this.image,
    required this.note,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderId: json['orderId'],
      foodId: json['foodId'],
      foodTitle: json['foodTitle'],
      quantity: json['quantity'],
      price: json['price'],
      image: json['image'],
      note: json['note'],
    );
  }
}
