import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';

class MainView extends StatelessWidget {
  final Widget child;

  const MainView({super.key, required this.child});

  int _selectedIndex(String location) {
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/main');
              case 1:
                context.go('/schedule');
              case 2:
                context.go('/profile');
            }
          },
          backgroundColor: BumditbulColor.black900,
          selectedItemColor: BumditbulColor.green400,
          unselectedItemColor: BumditbulColor.black600,
          selectedLabelStyle: BumditbulTextStyle.bodyMedium2.copyWith(
            color: BumditbulColor.green400,
          ),
          unselectedLabelStyle: BumditbulTextStyle.bodyMedium2.copyWith(
            color: BumditbulColor.black600,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Iconify(Ic.round_home, size: 24, color: BumditbulColor.black600),
              activeIcon: Iconify(Ic.round_home, size: 24, color: BumditbulColor.green400),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Iconify(Ic.outline_calendar_month, size: 24, color: BumditbulColor.black600),
              activeIcon: Iconify(Ic.round_calendar_month, size: 24, color: BumditbulColor.green400),
              label: '일정',
            ),
            BottomNavigationBarItem(
              icon: Iconify(Ic.outline_person, size: 24, color: BumditbulColor.black600),
              activeIcon: Iconify(Ic.round_person, size: 24, color: BumditbulColor.green400),
              label: '프로필',
            ),
          ],
        ),
      ),
    );
  }
}
