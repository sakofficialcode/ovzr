import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'home.dart';
import 'post.dart';
import 'profile.dart';
import 'trip.dart';

class base extends StatefulWidget {
  const base({super.key});

  @override
  State<base> createState() => _baseState();
}

class _baseState extends State<base> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Ionicons.car_outline),
        title: Text("OVZR"),
      ),
      body: [
        home(),
        trip(),
        post(),
        profile(),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Ionicons.home),
            icon: Icon(Ionicons.home_outline),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Ionicons.navigate),
            icon: Icon(Ionicons.navigate_outline),
            label: 'Trips',
          ),
          NavigationDestination(
            selectedIcon: Icon(Ionicons.camera),
            icon: Icon(Ionicons.camera_outline),
            label: 'Post',
          ),
          NavigationDestination(
            selectedIcon: Icon(Ionicons.person_circle),
            icon: Icon(Ionicons.person_circle_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
