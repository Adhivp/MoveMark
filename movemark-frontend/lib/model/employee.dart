class Employee {
  final String name;
  final String id;
  final double attendancePercentage;
  final double salary;
  final String? email;
  final String? department;

  Employee(
    this.name,
    this.id,
    this.attendancePercentage,
    this.salary, {
    this.email,
    this.department,
  });
}
