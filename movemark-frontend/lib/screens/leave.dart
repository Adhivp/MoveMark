import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaveRequests extends StatefulWidget {
  const LeaveRequests({Key? key}) : super(key: key);

  @override
  _LeaveRequestsState createState() => _LeaveRequestsState();
}

class _LeaveRequestsState extends State<LeaveRequests> {
  List<dynamic> leaveRequests = [];
  Map<int, String> employeeNames = {};

  @override
  void initState() {
    super.initState();
    fetchLeaveRequests();
    fetchEmployeeNames();
  }

  Future<void> fetchLeaveRequests() async {
    final response = await http.get(
      Uri.parse('https://movemark-backend.onrender.com/leave_requests/get'),
      
    );

    if (response.statusCode == 200) {
      setState(() {
        leaveRequests = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load leave requests');
    }
  }

  Future<void> fetchEmployeeNames() async {
    final response = await http.get(
      Uri.parse('https://movemark-backend.onrender.com/employees/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> employees = json.decode(response.body);
      setState(() {
        employeeNames = {
          for (var employee in employees)
            employee['employee_id']: employee['employee_name']
        };
      });
    } else {
      throw Exception('Failed to load employee names');
    }
  }

  void approveLeaveRequest(int id) {
    // Simulate API call to approve leave request
    // You can replace this with an actual API call
    setState(() {
      leaveRequests.removeWhere((request) => request['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave request $id approved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Requests'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: leaveRequests.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: leaveRequests.length,
              itemBuilder: (context, index) {
                final request = leaveRequests[index];
                final employeeName =
                    employeeNames[request['employee_id']] ?? 'Unknown Employee';

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Employee: $employeeName',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Date: ${request['date_to_be_on_leave']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Reason: ${request['reason']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => approveLeaveRequest(request['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Approve',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
