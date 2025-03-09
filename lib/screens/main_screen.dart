import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/app_state.dart';
import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'players_screen.dart';
import 'match_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        final appState = Provider.of<MyAppState>(context, listen: false);
        _updateMatchesStatus(appState);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<MyAppState>(context, listen: false);
      _updateMatchesStatus(appState);
    });
  }

  Future<void> _updateMatchesStatus(MyAppState appState) async {
    try {
      await appState.updateMatchesStatus();
    } catch (e) {
      debugPrint('Erro ao atualizar status das partidas: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final List<Widget> screens = [
      const HomeScreen(),
      const PlayersScreen(),
      const MatchScreen(),
    ];

    return Scaffold(
      body: screens[appState.selectedIndex],

      bottomNavigationBar: const AppBottomNavigation(),
    );
  }
}
