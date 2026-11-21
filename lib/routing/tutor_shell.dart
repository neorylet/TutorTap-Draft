import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../screens/tutor_classroom.dart';
import '../screens/tutor_dashboard.dart';
import '../screens/tutor_earnings.dart';
import '../screens/tutor_profile_verification.dart';
import '../screens/tutor_students.dart';

class TutorShell extends StatefulWidget {
  const TutorShell({super.key});

  @override
  State<TutorShell> createState() => _TutorShellState();
}

class _TutorShellState extends State<TutorShell> {
  int _index = 0;
  static const List<Widget> _pages = <Widget>[
    TutorDashboardScreen(),
    TutorStudentsScreen(),
    TutorClassroomScreen(),
    TutorEarningsScreen(),
    TutorProfileVerificationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (int index) => setState(() => _index = index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Classroom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
