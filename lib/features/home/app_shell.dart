import 'package:flutter/material.dart';

import '../../shared/brand_mark.dart';

import '../hobbies/explore_page.dart';
import '../listings/post_page.dart';
import '../messages/messages_page.dart';
import '../profile/profile_page.dart';
import 'home_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;

  /// Bumped to make Home reload listings from the server.
  final _listingsReload = ValueNotifier<int>(0);

  @override
  void dispose() {
    _listingsReload.dispose();
    super.dispose();
  }

  void _select(int index) {
    // Returning to Home shows listings other people posted in the meantime.
    if (index == 0 && _selected != 0) _listingsReload.value++;
    setState(() => _selected = index);
  }

  static const _labels = ['Home', 'Explore', 'Post', 'Messages', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.add_circle_outline,
    Icons.chat_bubble_outline,
    Icons.person_outline,
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: _selected == 0
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandMark(size: 34),
                SizedBox(width: 10),
                Text('HobbySwap'),
              ],
            )
          : Text(_labels[_selected]),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: IndexedStack(
            index: _selected,
            children: [
              HomePage(
                onExplore: () => _select(1),
                onPost: () => _select(2),
                listingsReload: _listingsReload,
              ),
              const ExplorePage(),
              PostPage(onPosted: () => _listingsReload.value++),
              const MessagesPage(),
              const ProfilePage(),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selected,
      onDestinationSelected: _select,
      destinations: List.generate(
        _labels.length,
        (index) => NavigationDestination(
          icon: Icon(_icons[index]),
          label: _labels[index],
        ),
      ),
    ),
  );
}
