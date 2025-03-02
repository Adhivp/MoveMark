// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({Key? key}) : super(key: key);

//   @override
//   State<ReportsScreen> createState() => _ReportsScreenState();
// }

// class _ReportsScreenState extends State<ReportsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final bool isDesktop = MediaQuery.of(context).size.width > 1100;

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 62, 66, 82),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader('Reports'),
//               const SizedBox(height: 24),

//               // Report types
//               GridView.count(
//                 crossAxisCount: isDesktop ? 3 : 2,
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//                 // children: [
//                 //   _buildReportCard('Monthly Report', Icons.calendar_today),
//                 //   _buildReportCard('Department Report', Icons.business),
//                 //   _buildReportCard('Yearly Summary', Icons.insert_chart),
//                 //   _buildReportCard('Absence Analysis', Icons.person_off),
//                 //   _buildReportCard('Custom Report', Icons.tune),
//                 //   _buildReportCard('Export Data', Icons.download),
//                 // ],
//               ),

//               const SizedBox(height: 32),

//               // Recent reports
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 color: const Color.fromARGB(
//                     255, 72, 76, 92), // Slightly lighter shade for contrast
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Recent Reports',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white, // Changed to white
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ListView.separated(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: 5,
//                         separatorBuilder: (context, index) => const Divider(
//                           color: Colors.white24, // Semi-transparent white
//                         ),
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             leading: const CircleAvatar(
//                               backgroundColor: Colors.blue,
//                               child:
//                                   Icon(Icons.description, color: Colors.white),
//                             ),
//                             title: Text(
//                               'Monthly Attendance Report - ${DateFormat('MMMM').format(DateTime.now().subtract(Duration(days: 30 * index)))}',
//                               style: const TextStyle(
//                                 color: Colors.white, // Changed to white
//                               ),
//                             ),
//                             subtitle: Text(
//                               'Generated on ${DateFormat('MMM d, yyyy').format(DateTime.now().subtract(Duration(days: index * 5)))}',
//                               style: const TextStyle(
//                                 color: Colors.white70, // Semi-transparent white
//                               ),
//                             ),
//                             trailing: IconButton(
//                               icon: const Icon(
//                                 Icons.download,
//                                 color: Colors.white, // Changed to white
//                               ),
//                               onPressed: () {},
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(String title) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         Row(
//           children: [
//             IconButton(
//               icon: const Icon(
//                 Icons.notifications_outlined,
//                 color: Colors.white,
//               ),
//               onPressed: () {},
//             ),
//             const SizedBox(width: 8),
//             const CircleAvatar(
//               backgroundColor: Colors.blue,
//               child: Text(
//                 'AD',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

// //   Widget _buildReportCard(String title, IconData icon) {
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       color: Colors.white,
// //       child: InkWell(
// //         onTap: () {},
// //         borderRadius: BorderRadius.circular(16),
// //         child: Padding(
// //           padding: const EdgeInsets.all(20.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 icon,
// //                 size: 48,
// //                 color: Colors.blue,
// //               ),
// //               const SizedBox(height: 16),
// //               Text(
// //                 title,
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                   color: Color.fromARGB(255, 62, 66, 82),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// }
