import 'package:flutter/material.dart';

Widget portfolioCard() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total Portfolio Value",
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 8),
        Text(
          "\$24,680.45",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "+12.4% this month",
          style: TextStyle(color: Colors.greenAccent),
        ),
      ],
    ),
  );
}
