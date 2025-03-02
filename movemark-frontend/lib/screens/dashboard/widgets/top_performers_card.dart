import 'package:flutter/material.dart';
import 'package:movemark/model/employee.dart';

class TopPerformersCard extends StatelessWidget {
  final List<Employee> employees;
  final String title;

  const TopPerformersCard({
    Key? key,
    required this.employees,
    this.title = 'Top Performers',
  }) : super(key: key);

  List<Employee> _getTopPerformers() {
    List<Employee> topPerformers = List.from(employees)
      ..sort(
          (a, b) => b.attendancePercentage.compareTo(a.attendancePercentage));

    return topPerformers.length > 5
        ? topPerformers.sublist(0, 5)
        : topPerformers;
  }

  @override
  Widget build(BuildContext context) {
    final topPerformers = _getTopPerformers();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, // Use the title parameter instead of hardcoded string
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topPerformers
                .map((employee) => _buildEmployeeRow(employee))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeRow(Employee employee) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Text(employee.name.substring(0, 1)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  employee.id.toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${employee.attendancePercentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
