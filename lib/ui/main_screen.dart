import 'package:flutter/material.dart';
import 'workbench/workbench_screen.dart';
import 'employees/employees_screen.dart';
import 'salary_report/salary_report_screen.dart';
import 'history/history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const WorkbenchScreen();
      case 1:
        return const EmployeesScreen();
      case 2:
        return const HistoryScreen();
      case 3:
        return const SalaryReportScreen();
      default:
        return const WorkbenchScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E8F5), width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: const Color(0xFF9BA3B2),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 22,
          elevation: 0,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: '工作台',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: '员工库',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: '历史工资',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.table_chart_outlined),
              activeIcon: Icon(Icons.table_chart),
              label: '工资报表',
            ),
          ],
        ),
      ),
    );
  }
}
