import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movemark/model/employee.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({Key? key}) : super(key: key);

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<Employee> _employees = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  List<Employee> get _filteredEmployees => _employees
      .where((employee) =>
          employee.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.id
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://movemark-backend.onrender.com/employees/?skip=0&limit=100'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _employees = data.map((employeeData) {
            return Employee(
              employeeData['employee_name'],
              'EMP${employeeData['employee_id'].toString().padLeft(3, '0')}',
              employeeData['attendance_percentage'] ?? 0.0, // Default to 0.0 if null
              0.0, // We're not using salary from API
              email: employeeData['email'],
              department: employeeData['department'],
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load employees. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching employees: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 62, 66, 82),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchAndFilterBar(),
            const SizedBox(height: 24),
            _isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _errorMessage != null
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 60, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchEmployees,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildEmployeeTable(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new employee functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Employees',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.poppins().fontFamily,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('AD'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search employees...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            PopupMenuButton(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: const [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Filter'),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'attendance_high',
                  child: Text('Highest Attendance'),
                ),
                const PopupMenuItem(
                  value: 'attendance_low',
                  child: Text('Lowest Attendance'),
                ),
                const PopupMenuItem(
                  value: 'name_asc',
                  child: Text('Name (A-Z)'),
                ),
                const PopupMenuItem(
                  value: 'name_desc',
                  child: Text('Name (Z-A)'),
                ),
                const PopupMenuItem(
                  value: 'department',
                  child: Text('Group by Department'),
                ),
              ],
              onSelected: (String value) {
                setState(() {
                  switch (value) {
                    case 'attendance_high':
                      _employees.sort((a, b) => b.attendancePercentage
                          .compareTo(a.attendancePercentage));
                      break;
                    case 'attendance_low':
                      _employees.sort((a, b) => a.attendancePercentage
                          .compareTo(b.attendancePercentage));
                      break;
                    case 'name_asc':
                      _employees.sort((a, b) => a.name.compareTo(b.name));
                      break;
                    case 'name_desc':
                      _employees.sort((a, b) => b.name.compareTo(a.name));
                      break;
                    case 'department':
                      _employees.sort((a, b) =>
                          a.department != null && b.department != null
                              ? a.department!.compareTo(b.department!)
                              : 0);
                      break;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeTable() {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'ID',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Department',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Attendance %',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: _filteredEmployees.map((employee) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          child: Text(
                            employee.name[0],
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            employee.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(employee.id.toString())),
                  DataCell(Text(employee.department ?? 'N/A')),
                  DataCell(
                    Flexible(
                      child: Text(
                        employee.email ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _getAttendanceColor(employee.attendancePercentage),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${employee.attendancePercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getAttendanceColor(double attendance) {
    if (attendance >= 90) {
      return Colors.green;
    } else if (attendance >= 80) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}