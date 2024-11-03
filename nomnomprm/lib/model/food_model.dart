class Food {
  final int id;
  final String foodId;
  final String name;
  final String storeId;
  final double price;
  final String title;
  final String description;
  final int cate;
  final String image;
  final int status;
  final String createdDate;
  final String createdBy;
  final String? deletedDate;
  final String? deletedBy;
  final List<dynamic> orderDetails;
   final int orderCount;

  Food({
    required this.id,
    required this.foodId,
    required this.name,
    required this.storeId,
    required this.price,
    required this.title,
    required this.description,
    required this.cate,
    required this.image,
    required this.status,
    required this.createdDate,
    required this.createdBy,
    this.deletedDate,
    this.deletedBy,
    required this.orderDetails,
    required this.orderCount,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      foodId: json['foodId'],
      name: json['name'],
      storeId: json['storeId'],
      price: json['price'].toDouble(),
      title: json['title'],
      description: json['description'],
      cate: json['cate'],
      image: json['image'],
      status: json['status'],
      createdDate: json['createdDate'],
      createdBy: json['createdBy'],
      deletedDate: json['deletedDate'],
      deletedBy: json['deletedBy'],
      orderDetails: json['orderDetails'],
      orderCount: json['orderCount'],
    );
  }
}
