import 'package:flutter/material.dart';
import 'package:nomnomprm/model/cart_model.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  String? _currentStoreId;

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  int get totalAmount {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  String? get currentStoreId {
    return _currentStoreId;
  }

  void addItem(String foodId, String name, int price, String storeId, String imageUrl, String note, [int quantity = 1]) {
    if (_currentStoreId != null && _currentStoreId != storeId) {
      // Do not add item if it's from a different store
      return;
    }

    if (_items.containsKey(foodId)) {
      _items.update(
        foodId,
        (existingCartItem) => CartItem(
          foodId: existingCartItem.foodId,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + quantity,
          storeId: existingCartItem.storeId,
          imageUrl: existingCartItem.imageUrl,
          note: existingCartItem.note,
        ),
      );
    } else {
      _items.putIfAbsent(
        foodId,
        () => CartItem(
          foodId: foodId,
          name: name,
          price: price,
          quantity: quantity,
          storeId: storeId,
          imageUrl: imageUrl,
          note: note,
        ),
      );
      _currentStoreId = storeId;  // Set the current store ID
    }
    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.remove(foodId);
    if (_items.isEmpty) {
      _currentStoreId = null;
    }
    notifyListeners();
  }

  void updateItemQuantity(String foodId, int quantity) {
    if (_items.containsKey(foodId)) {
      _items.update(
        foodId,
        (existingCartItem) => CartItem(
          foodId: existingCartItem.foodId,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: quantity,
          storeId: existingCartItem.storeId,
          imageUrl: existingCartItem.imageUrl,
          note: existingCartItem.note,
        ),
      );
    }
    notifyListeners();
  }

  void updateItemNote(String foodId, String newNote) {
    if (_items.containsKey(foodId)) {
      _items.update(
        foodId,
        (existingCartItem) => CartItem(
          foodId: existingCartItem.foodId,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity,
          storeId: existingCartItem.storeId,
          imageUrl: existingCartItem.imageUrl,
          note: newNote,
        ),
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _items = {};
    _currentStoreId = null;
    notifyListeners();
  }
}
