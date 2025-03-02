import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:movemark/model/department_attendance.dart';
import 'package:movemark/model/early_comers.dart';
import 'package:movemark/model/employee.dart';
import 'package:movemark/model/monthly_attendance.dart';
import 'widgets/summary_card.dart';
import 'widgets/attendance_trend_card.dart';
import 'widgets/department_attendance_card.dart';
import 'widgets/top_performers_card.dart';
import '../../widgets/common/header.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isDesktop = false;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _targetDate;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _dashboardData;
  List<EarlyComer> _earlyComers = [];

  // Text editing controllers
  late TextEditingController _targetDateController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  // Date format
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Default data state
  final Map<String, dynamic> _defaultData = {
    "overall_stats": {"percentage": 0.0, "present": "0/0", "absent": "0/0"},
    "department_stats": {
      "Engineering": 0.0,
      "Marketing": 0.0,
      "HR": 0.0,
      "Finance": 0.0
    },
    "attendance_trend": {},
    "top_performers": [],
    "early_comers": [],
    "date_info": {
      "start_date": DateTime.now().toString(),
      "end_date": DateTime.now().toString(),
      "is_single_date": false
    }
  };

  @override
  void initState() {
    super.initState();
    _dashboardData = _defaultData;

    // Initialize date
    _targetDate = DateTime.now();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 7));

    // Initialize controllers with current values
    _targetDateController =
        TextEditingController(text: _dateFormat.format(_targetDate!));
    _startDateController =
        TextEditingController(text: _dateFormat.format(_startDate!));
    _endDateController =
        TextEditingController(text: _dateFormat.format(_endDate!));

    _fetchDashboardData();
  }

  @override
  void dispose() {
    _targetDateController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String baseUrl = 'https://movemark-backend.onrender.com/attendance-stats';
      String queryParams = '';

      if (_targetDate != null) {
        queryParams = '?target_date=${_dateFormat.format(_targetDate!)}';
      } else if (_startDate != null && _endDate != null) {
        queryParams =
            '?start_date=${_dateFormat.format(_startDate!)}&end_date=${_dateFormat.format(_endDate!)}';
      }

      print('Fetching data from: $baseUrl$queryParams');

      final response = await http.get(
        Uri.parse(baseUrl + queryParams),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          try {
            final decodedData = json.decode(response.body);
            setState(() {
              _dashboardData = decodedData;
              _isLoading = false;
            });
          } catch (e) {
            print('JSON decode error: $e');
            setState(() {
              _errorMessage =
                  'Invalid data format received from server. Please check if the API is returning valid JSON.';
              _dashboardData = _defaultData;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage =
                'Server returned non-JSON response. Content-Type: ${response.headers['content-type']}';
            _dashboardData = _defaultData;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Server error: ${response.statusCode}\nResponse: ${response.body.substring(0, min(200, response.body.length))}...';
          _dashboardData = _defaultData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Network error: $e');
      setState(() {
        _errorMessage =
            'Network error: Please check your connection and verify the API endpoint is accessible';
        _dashboardData = _defaultData;
        _isLoading = false;
      });
    }
  }

  DateTime? _tryParseDate(String text) {
    try {
      return _dateFormat.parse(text);
    } catch (e) {
      return null;
    }
  }

  Widget _buildDateSelectionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Single Date'),
                  value: true,
                  groupValue: _targetDate != null,
                  onChanged: (value) {
                    if (value == true) {
                      setState(() {
                        _targetDate = DateTime.now();
                        _targetDateController.text =
                            _dateFormat.format(_targetDate!);
                        _startDate = null;
                        _endDate = null;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Date Range'),
                  value: false,
                  groupValue: _targetDate != null,
                  onChanged: (value) {
                    if (value == false) {
                      setState(() {
                        _targetDate = null;
                        _startDate = DateTime.now();
                        _endDate = DateTime.now().add(const Duration(days: 7));
                        _startDateController.text =
                            _dateFormat.format(_startDate!);
                        _endDateController.text = _dateFormat.format(_endDate!);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_targetDate != null) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Target Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    controller: _targetDateController,
                    onChanged: (value) {
                      final parsedDate = _tryParseDate(value);
                      if (parsedDate != null) {
                        setState(() {
                          _targetDate = parsedDate;
                        });
                      }
                    },
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _targetDate!,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2025),
                      );
                      if (date != null) {
                        setState(() {
                          _targetDate = date;
                          _targetDateController.text = _dateFormat.format(date);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.find_in_page),
                  onPressed: _fetchDashboardData,
                  tooltip: 'fetch data',
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    controller: _startDateController,
                    onChanged: (value) {
                      final parsedDate = _tryParseDate(value);
                      if (parsedDate != null) {
                        setState(() {
                          _startDate = parsedDate;
                        });
                      }
                    },
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2025),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                          _startDateController.text = _dateFormat.format(date);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    controller: _endDateController,
                    onChanged: (value) {
                      final parsedDate = _tryParseDate(value);
                      if (parsedDate != null) {
                        setState(() {
                          _endDate = parsedDate;
                        });
                      }
                    },
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2025),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                          _endDateController.text = _dateFormat.format(date);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchDashboardData,
                  tooltip: 'Refresh data',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isDesktop = MediaQuery.of(context).size.width > 1100;

    return SingleChildScrollView(
      child: Container(
        color: const Color.fromARGB(255, 62, 66, 82),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(title: 'Dashboard'),
            _buildDateSelectionRow(),
            const SizedBox(height: 24),
            if (_isLoading) ...[
              const Center(
                child: CircularProgressIndicator(),
              )
            ] else if (_errorMessage != null) ...[
              _buildErrorWidget()
            ] else ...[
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: _isDesktop ? 4 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  SummaryCard(
                    title: 'Overall Attendance',
                    value:
                        '${_dashboardData!['overall_stats']['percentage'].toStringAsFixed(1)}%',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  SummaryCard(
                    title: 'Present',
                    value: _dashboardData!['overall_stats']['present'],
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  SummaryCard(
                    title: 'Absent',
                    value: _dashboardData!['overall_stats']['absent'],
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                  SummaryCard(
                    title: 'Date Range',
                    value: _targetDate != null
                        ? DateFormat('MMM d').format(_targetDate!)
                        : '${DateFormat('MMM d').format(_startDate ?? DateTime.now())} - ${DateFormat('MMM d').format(_endDate ?? DateTime.now())}',
                    icon: Icons.date_range,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (_dashboardData!['attendance_trend'].isNotEmpty) ...[
                SizedBox(
                  height: 400,
                  child: _isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: AttendanceTrendCard(
                                monthlyData: _processAttendanceTrendData(),
                                isSingleDay: _dashboardData!['date_info']
                                    ['is_single_date'],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: DepartmentAttendanceCard(
                                departmentData: _processDepartmentData(),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: AttendanceTrendCard(
                                monthlyData: _processAttendanceTrendData(),
                                isSingleDay: _dashboardData!['date_info']
                                    ['is_single_date'],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: DepartmentAttendanceCard(
                                departmentData: _processDepartmentData(),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
              const SizedBox(height: 24),
              if (_dashboardData!['date_info']['is_single_date']) ...[
                TopPerformersCard(
                  employees: _processEmployeeData(),
                  title: 'Early Comers',
                ),
              ] else ...[
                TopPerformersCard(
                  employees: _processEmployeeData(),
                  title: 'Top Performers',
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<MonthlyAttendance> _processAttendanceTrendData() {
    final trendData = _dashboardData!['attendance_trend'];
    List<MonthlyAttendance> monthlyData = [];

    if (_dashboardData!['date_info']['is_single_date']) {
      trendData.forEach((key, value) {
        try {
          final time = DateFormat('HH:mm').parse(key);
          monthlyData.add(MonthlyAttendance(
            DateTime(2024, 1, 1, time.hour, time.minute),
            value.toDouble(),
          ));
        } catch (e) {
          print('Error processing time data: $e');
        }
      });
    } else {
      trendData.forEach((key, value) {
        try {
          final date = DateFormat('yyyy-MM').parse(key);
          monthlyData.add(MonthlyAttendance(date, value.toDouble()));
        } catch (e) {
          print('Error processing date data: $e');
        }
      });
    }

    return monthlyData;
  }

  List<DepartmentAttendance> _processDepartmentData() {
    final departmentStats = _dashboardData!['department_stats'];
    return departmentStats.entries
        .map<DepartmentAttendance>(
            (entry) => DepartmentAttendance(entry.key, entry.value.toDouble()))
        .toList();
  }

  List<Employee> _processEmployeeData() {
    if (_dashboardData!['date_info']['is_single_date']) {
      // Process early comers for single date
      final earlyComers = _dashboardData!['early_comers'];
      if (earlyComers == null || earlyComers.isEmpty) {
        return [];
      }
      return earlyComers
          .map<Employee>((comer) => Employee(
              comer['name'], 'Check-in: ${comer['check_in_time']}', 100.0, 0.0))
          .toList();
    } else {
      // Process top performers for date range
      final topPerformers = _dashboardData!['top_performers'];
      if (topPerformers == null || topPerformers.isEmpty) {
        return [];
      }
      return topPerformers
          .map<Employee>((performer) => Employee(
              performer['name'], '', performer['percentage'].toDouble(), 0.0))
          .toList();
    }
  }
}
