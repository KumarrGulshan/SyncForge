import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'dashboard_service.dart';

class DashboardScreen extends StatefulWidget {

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  Map<String, dynamic>? data;

  bool loading = true;

  @override
  void initState() {

    super.initState();

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {

    try {

      final result =
          await DashboardService
              .getTaskAnalytics();

      setState(() {

        data = result;

        loading = false;
      });

    } catch (e) {

      print("Dashboard error: $e");

      setState(() {
        loading = false;
      });
    }
  }

  Widget statCard({

    required String title,

    required String value,

    required IconData icon,

    required Color color,
  }) {

    return Card(

      elevation: 4,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(18),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 34,
              color: color,
            ),

            const SizedBox(height: 12),

            Text(

              value,

              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(

              title,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPieChart() {

    return Card(

      elevation: 4,

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(

              "Task Status",

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(

              height: 240,

              child: PieChart(

                PieChartData(

                  centerSpaceRadius: 45,

                  sectionsSpace: 2,

                  sections: [

                    PieChartSectionData(

                      value: (data![
                                  "todoTasks"]
                              as int)
                          .toDouble(),

                      color: Colors.orange,

                      radius: 55,

                      title:
                          "TODO\n${data!["todoTasks"]}",

                      titleStyle:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),

                    PieChartSectionData(

                      value: (data![
                                  "progressTasks"]
                              as int)
                          .toDouble(),

                      color: Colors.blue,

                      radius: 55,

                      title:
                          "PROGRESS\n${data!["progressTasks"]}",

                      titleStyle:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),

                    PieChartSectionData(

                      value: (data![
                                  "doneTasks"]
                              as int)
                          .toDouble(),

                      color: Colors.green,

                      radius: 55,

                      title:
                          "DONE\n${data!["doneTasks"]}",

                      titleStyle:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Dashboard"),
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : data == null

              ? const Center(
                  child: Text(
                    "Failed to load dashboard",
                  ),
                )

              : RefreshIndicator(

                  onRefresh:
                      _loadDashboard,

                  child: SingleChildScrollView(

                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(16),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        GridView.count(

                          shrinkWrap: true,

                          physics:
                              const NeverScrollableScrollPhysics(),

                          crossAxisCount: 2,

                          crossAxisSpacing: 12,

                          mainAxisSpacing: 12,

                          childAspectRatio: 1.15,

                          children: [

                            statCard(

                              title:
                                  "Projects",

                              value: data![
                                      "projects"]
                                  .toString(),

                              icon:
                                  Icons.folder,

                              color:
                                  Colors.blue,
                            ),

                            statCard(

                              title:
                                  "Total Tasks",

                              value: data![
                                      "totalTasks"]
                                  .toString(),

                              icon:
                                  Icons.task,

                              color:
                                  Colors.orange,
                            ),

                            statCard(

                              title:
                                  "Completed",

                              value:
                                  "${data!["completionRate"]}%",

                              icon: Icons
                                  .check_circle,

                              color:
                                  Colors.green,
                            ),

                            statCard(

                              title:
                                  "Overdue Tasks",

                              value: data![
                                      "overdueTasks"]
                                  .toString(),

                              icon:
                                  Icons.warning,

                              color:
                                  Colors.red,
                            ),

                            statCard(

                              title:
                                  "High Priority",

                              value: data![
                                      "highPriorityTasks"]
                                  .toString(),

                              icon: Icons
                                  .priority_high,

                              color:
                                  Colors.purple,
                            ),

                            statCard(

                              title:
                                  "Completed Tasks",

                              value: data![
                                      "completedTasks"]
                                  .toString(),

                              icon: Icons
                                  .done_all,

                              color:
                                  Colors.teal,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        buildPieChart(),
                      ],
                    ),
                  ),
                ),
    );
  }
}