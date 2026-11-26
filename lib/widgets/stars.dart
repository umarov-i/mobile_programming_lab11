import 'package:flutter/material.dart';

class Stars extends StatelessWidget {
  const Stars(this.rating, {super.key});
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(i <= rating ? Icons.star : Icons.star_border, size: 16, color: Colors.amber),
      ],
    );
  }
}
