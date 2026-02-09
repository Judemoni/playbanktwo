import 'package:chasebank/screens/homescreen.dart';
import 'package:chasebank/screens/investment.dart';
import 'package:chasebank/screens/offers.dart';
import 'package:chasebank/screens/plan.dart';
import 'package:chasebank/screens/transferandpay.dart';
import 'package:chasebank/widgets/constants.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const PayTransferScreen(),
    const Plan(),
    const Offers(),
    const InvestmentPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: bottomNav(),
    );
  }

  Widget bottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.background,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: AppColors.lightBlue,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          label: 'Accounts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: 'Pay & Transfer',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: 'Plan & Track',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard),
          label: 'Benefits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Investments',
        ),
      ],
    );
  }
}
