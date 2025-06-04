import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'app_drawer.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final Function(int) onNavigationItemSelected;

  const ResponsiveLayout({
    Key? key,
    required this.child,
    required this.selectedIndex,
    required this.onNavigationItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop layout (width >= 1200px)
        if (constraints.maxWidth >= 1200) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 280,
                  child: AppDrawer(),
                ),
                Expanded(
                  child: child,
                ),
              ],
            ),
          );
        }
        
        // Mobile layout
        return Scaffold(
          body: child,
          drawer: AppDrawer(),
          bottomNavigationBar: BottomNavBar(
            currentIndex: selectedIndex,
            onTap: onNavigationItemSelected,
          ),
        );
      },
    );
  }
} 