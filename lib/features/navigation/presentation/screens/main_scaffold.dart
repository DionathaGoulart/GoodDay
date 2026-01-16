import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../daily_log/presentation/screens/home_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // We need to make sure this is exported correctly
    const DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color comes from theme
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          // Colors come from Theme.of(context).bottomNavigationBarTheme by default if not overridden,
          // but we can be explicit if needed or let the theme handle it.
          // AppTheme defines: 
          // backgroundColor: Color(0xFF000000)
          // selectedItemColor: primaryColor (Pastel Green)
          // unselectedItemColor: secondaryText
          
          currentIndex: _currentIndex,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? Icons.home_filled : Icons.home_outlined),
              label: 'Diário',
            ),
             BottomNavigationBarItem(
              icon: Icon(_currentIndex == 1 ? Icons.bar_chart : Icons.bar_chart_outlined), 
              label: 'Estatísticas',
            ),
          ],
        ),
      ),
    );
  }
}
