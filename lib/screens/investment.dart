import 'package:chasebank/widgets/constants.dart';
import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';

class InvestmentPage extends StatelessWidget {
  const InvestmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Investments"),
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: const Column(
        children: [
          Expanded(
            child: _MarketImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1444653614773-995cb1ef9efa?auto=format&fit=crop&w=1600&q=80',
              label: 'Forex Market',
            ),
          ),
          Expanded(
            child: _MarketImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1620321023374-d1a68fbc720d?auto=format&fit=crop&w=1600&q=80',
              label: 'BTC',
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketImage extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _MarketImage({
    required this.imageUrl,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'Image failed to load',
                style: TextStyle(color: Colors.white70),
              ),
            );
          },
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x66000000),
                Color(0x00000000),
                Color(0x66000000),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
