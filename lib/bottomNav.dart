import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ecampus/home.dart';
import 'package:ecampus/lending.dart';
import 'package:ecampus/request.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 1;

  late List<Widget> pages;
  late Widget currentPage;
  late HomePage homePage;
  late LendingPage lendingPage;
  late BookingScreen requestPage;

  @override
  void initState() {
    super.initState();
    homePage = HomePage();
    lendingPage = LendingPage();
    requestPage = BookingScreen();

    pages = [lendingPage, homePage, requestPage];
    currentTabIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Render the current page as the background
        Positioned.fill(
          child: pages[currentTabIndex],
        ),

        // Place the navigation bar on top of the pages
        Align(
          alignment: Alignment.bottomCenter,
          child: CurvedNavigationBar(
            height: 75,
            backgroundColor: Colors.transparent, // Transparent navbar
            color:
                const Color.fromARGB(255, 51, 50, 50), // Navbar's primary color
            animationDuration: Duration(milliseconds: 500),
            index: currentTabIndex,
            onTap: (int index) {
              setState(() {
                currentTabIndex = index;
              });
            },
            items: [
              Icon(
                Icons.shopping_cart,
                color: currentTabIndex == 0
                    ? Colors.white // Active color
                    : Color.fromARGB(255, 42, 254, 169),
              ),
              Icon(
                Icons.home_rounded,
                color: currentTabIndex == 1
                    ? Colors.white // Active color
                    : Color.fromARGB(255, 42, 254, 169),
              ),
              Icon(
                Icons.calendar_month_outlined,
                color: currentTabIndex == 2
                    ? Colors.white // Active color
                    : Color.fromARGB(255, 42, 254, 169),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
