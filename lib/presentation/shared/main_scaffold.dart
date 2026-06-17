import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_ai/presentation/screens/home/home_screen.dart';
import 'package:flutter_application_ai/presentation/screens/schedule/schedule_screen.dart';
import 'package:flutter_application_ai/presentation/screens/calendar/calendar_screen.dart';
import 'package:flutter_application_ai/presentation/screens/priority_matrix/matrix_screen.dart';
import 'package:flutter_application_ai/presentation/shared/components/app_bottom_nav.dart';

class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int index) => state = index;
}

final bottomNavIndexProvider =
    NotifierProvider<BottomNavNotifier, int>(BottomNavNotifier.new);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  static const _screens = [
    HomeScreen(),
    ScheduleScreen(),
    CalendarScreen(),
    MatrixScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: index,
        onTap: (i) => ref.read(bottomNavIndexProvider.notifier).set(i),
      ),
    );
  }
}
