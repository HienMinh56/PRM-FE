class CartItem {
  final String foodId;
  final String name;
  final int price;
  int quantity;
  final String storeId;
  final String imageUrl; 
   String note; // Add note field

  CartItem({
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.storeId,
    required this.imageUrl, 
    required this.note, // Include note in constructor
  });
}
