import 'package:flutter/material.dart';
import 'package:nomnomprm/screen/CartScreen.dart';

class CarAnimation extends StatefulWidget {
  @override
  _CarAnimationState createState() => _CarAnimationState();
}

class _CarAnimationState extends State<CarAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context); // Close the dialog after animation completes
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'img/car.gif',
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      ),
    );
  }
}
