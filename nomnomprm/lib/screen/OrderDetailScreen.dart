import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:NomDeli/model/order_details_model.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  OrderDetailsPage({required this.orderId});

  Future<List<OrderDetail>> fetchOrderDetails() async {
    final url =
        'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/order-details?orderId=$orderId';
    print('Fetching order details from URL: $url');

    try {
      final response =
          await http.get(Uri.parse(url), headers: {'accept': '*/*'});

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['isSuccess']) {
          List<OrderDetail> details = (data['data'] as List)
              .map((detail) => OrderDetail.fromJson(detail))
              .toList();
          return details;
        } else {
          throw Exception('Failed to load order details: ${data['message']}');
        }
      } else {
        throw Exception(
            'Failed to load order details: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Note is nothing');
      throw Exception('Failed to load order details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<OrderDetail>>(
        future: fetchOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No details found'));
          } else {
            List<OrderDetail> details = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...details
                      .map((detail) => OrderItem(detail: detail))
                      .toList(),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Thank you for using our service!',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final OrderDetail detail;

  OrderItem({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Container to constrain the image size
              Container(
                width: 100,
                height: 100,
                child: Image.network(
                  detail.image, // Use the image URL from the model
                  fit: BoxFit
                      .cover, // Ensure the image covers the entire container
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail
                        .foodTitle, // Display the food title instead of food ID
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${detail.price.toStringAsFixed(0)} Nom Coin',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Quantity: ${detail.quantity}',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Note: ${detail.note}', // Display the note
                    style: TextStyle(
                        fontSize: 16,
                        color:
                            Colors.black), // Adjust color and style as needed
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
