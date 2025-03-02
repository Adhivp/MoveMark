import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movemark/screens/calender.dart';
import 'package:movemark/screens/dashboard/dashboard_screen.dart';
import 'package:movemark/screens/employees/employees_screen.dart';
import 'package:movemark/screens/gait.dart';
import 'package:movemark/screens/leave.dart';
import 'package:movemark/screens/reports/reports_screen.dart';
import 'package:movemark/screens/settings/about.dart';
import 'package:movemark/screens/splash%20screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class AttendanceDashboard extends StatefulWidget {
  const AttendanceDashboard({Key? key}) : super(key: key);

  @override
  State<AttendanceDashboard> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  bool _isDesktop = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    _isDesktop = MediaQuery.of(context).size.width > 1100;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: _isDesktop,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E2E)
                : const Color(0xFF2C3E50),
            leading: Container(
              width: _isDesktop ? 220 : 72,
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/Logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (_isDesktop) ...[
                    const SizedBox(height: 16),
                    Text(
                      'MoveMark',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_walk),
                selectedIcon: Icon(Icons.directions_walk),
                label: Text('Gait'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.mark_email_unread_outlined),
                selectedIcon: Icon(Icons.mark_email_unread),
                label: Text('Leave requests'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today_outlined),
                label: Text('Calender'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Employees'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('About'),
              ),
            ],
          ),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return Dashboard();

      case 1:
        return GaitRecognition();
      case 2:
        return LeaveRequests();
      case 3:
        return CalendarPage();
      case 4:
        return EmployeesScreen();
      case 5:
        return AboutPage();
      default:
        return Dashboard();
    }
  }
}
