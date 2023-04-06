import 'package:flutter/material.dart';
import 'main.dart';
import 'search_screen.dart';
import 'appellation.dart';

class AGreatDrawer extends StatelessWidget {
  const AGreatDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 118,
          child: DrawerHeader(
            child: Text('AGReaTWine'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
        ),
        ListTile(
          title: Text('Appellations'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TestScreen()),
              );
          },
        ),
      ],
    ),
  );
  }
}

class AGreatBottomNavigationBar extends StatelessWidget {
  const AGreatBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.grey,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.grey),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
      ],
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
            break;
        }
      },
    );
  }
}

class AGreatBottomNavigationBarH extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  
  const AGreatBottomNavigationBarH({Key? key, required this.currentIndex, required this.items}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: items,
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
            break;
        }
      },
    );
  }
}