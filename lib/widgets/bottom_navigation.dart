import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return BottomNavigationBar(
      currentIndex: appState.selectedIndex,
      onTap: (index) {
        appState.setSelectedIndex(index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Jogadores'),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_soccer),
          label: 'Partidas',
        ),
      ],
    );
  }
}
