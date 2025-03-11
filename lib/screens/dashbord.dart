import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'login.dart';

class Dashbord extends StatefulWidget {
  const Dashbord({super.key});

  @override
  State<Dashbord> createState() => _DashbordState();
}

class _DashbordState extends State<Dashbord> {
  String? username;
  String? role;
  String selectedYear = DateTime.now().year.toString(); // กำหนดปีปัจจุบัน

  Future<List<dynamic>> fetchReports() async {
    const url = "http://192.168.1.13/hotel_app_php/report.php";
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      // แปลงข้อมูล JSON
      List<dynamic> reports = json.decode(utf8.decode(response.bodyBytes));
      // กรองข้อมูลตามปีที่เลือก
      return reports.where((report) {
        String reportYear = report['date'].split('-')[0]; // ดึงปีจาก 'date'
        return reportYear == selectedYear;
      }).toList();
    } else {
      throw Exception("Failed to load reports");
    }
  }

  Map<String, int> processDataByMonth(List<dynamic> reports) {
    Map<String, int> monthCounts = {
      'มกราคม': 0,
      'กุมภาพันธ์': 0,
      'มีนาคม': 0,
      'เมษายน': 0,
      'พฤษภาคม': 0,
      'มิถุนายน': 0,
      'กรกฎาคม': 0,
      'สิงหาคม': 0,
      'กันยายน': 0,
      'ตุลาคม': 0,
      'พฤศจิกายน': 0,
      'ธันวาคม': 0,
    };

    for (var report in reports) {
      String month = report['date'].split('-')[1]; // ดึงเดือนจาก 'date'
      switch (month) {
        case '01':
          monthCounts['มกราคม'] = (monthCounts['มกราคม'] ?? 0) + 1;
          break;
        case '02':
          monthCounts['กุมภาพันธ์'] = (monthCounts['กุมภาพันธ์'] ?? 0) + 1;
          break;
        case '03':
          monthCounts['มีนาคม'] = (monthCounts['มีนาคม'] ?? 0) + 1;
          break;
        case '04':
          monthCounts['เมษายน'] = (monthCounts['เมษายน'] ?? 0) + 1;
          break;
        case '05':
          monthCounts['พฤษภาคม'] = (monthCounts['พฤษภาคม'] ?? 0) + 1;
          break;
        case '06':
          monthCounts['มิถุนายน'] = (monthCounts['มิถุนายน'] ?? 0) + 1;
          break;
        case '07':
          monthCounts['กรกฎาคม'] = (monthCounts['กรกฎาคม'] ?? 0) + 1;
          break;
        case '08':
          monthCounts['สิงหาคม'] = (monthCounts['สิงหาคม'] ?? 0) + 1;
          break;
        case '09':
          monthCounts['กันยายน'] = (monthCounts['กันยายน'] ?? 0) + 1;
          break;
        case '10':
          monthCounts['ตุลาคม'] = (monthCounts['ตุลาคม'] ?? 0) + 1;
          break;
        case '11':
          monthCounts['พฤศจิกายน'] = (monthCounts['พฤศจิกายน'] ?? 0) + 1;
          break;
        case '12':
          monthCounts['ธันวาคม'] = (monthCounts['ธันวาคม'] ?? 0) + 1;
          break;
      }
    }

    return monthCounts;
  }

  Map<String, int> processDataByType(List<dynamic> reports) {
    Map<String, int> typeCounts = {};
    for (var report in reports) {
      String type = report['type'];
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }
    return typeCounts;
  }

  Map<String, int> processDataByStatus(List<dynamic> reports) {
    Map<String, int> statusCounts = {};
    for (var report in reports) {
      String status = report['status'];
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    return statusCounts;
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name');
      role = prefs.getString('role');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Sidebar(
                  username: username,
                  role: role,
                  bottonColor: bottoncolor,
                  onLogout: logout,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 8,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ปุ่มเลือกปี
                        _buildYearSelector(),
                        const SizedBox(height: 20),
                        FutureBuilder<List<dynamic>>(
                          future: fetchReports(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error: ${snapshot.error}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text(
                                  "ไม่มีข้อมูลการแจ้งซ่อม",
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            } else {
                              final reports = snapshot.data!;
                              final typeData = processDataByType(reports);
                              final statusData = processDataByStatus(reports);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("จำนวนการติดตามลูกค้า"),
                                  const SizedBox(height: 16),
                                  _buildBarChartm(processDataByMonth(reports)),
                                  const SizedBox(height: 20),
                                  Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Expanded(
                                      //   flex: 5,
                                      //   child: Column(
                                      //     crossAxisAlignment:
                                      //         CrossAxisAlignment.start,
                                      //     children: [
                                      //       const Text(
                                      //         "ประเภท",
                                      //         style: TextStyle(
                                      //           fontSize: 18,
                                      //           fontWeight: FontWeight.bold,
                                      //           color: Colors.black87,
                                      //         ),
                                      //       ),
                                      //       const SizedBox(height: 16),
                                      //       _buildBarChartt(typeData),
                                      //     ],
                                      //   ),
                                      // ),
                                      // const SizedBox(width: 30),
                                      Expanded(
                                        // flex: 5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 60),
                                            const Text(
                                              "สถานะดําเนินการ",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            _buildPieChart(statusData),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Text(
            "เลือกปี:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: selectedYear,
            onChanged: (String? newYear) {
              setState(() {
                selectedYear = newYear!;
              });
            },
            items: List.generate(5, (index) {
              int year = DateTime.now().year - index;
              return DropdownMenuItem<String>(
                value: year.toString(),
                child: Text(year.toString()),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBarChartm(Map<String, int> data) {
    final maxValue = data.values.isNotEmpty
        ? data.values.reduce((a, b) => a > b ? a : b)
        : 0;
    final interval = (maxValue / 5).ceil(); // คำนวณช่วงระยะห่างจากค่ามากสุด

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: data.entries.map((entry) {
            final index = data.keys.toList().indexOf(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.primaries[index % Colors.primaries.length],
                  width: 24,
                  borderRadius: BorderRadius.circular(3),
                  // กำหนดให้เป็นเหลี่ยม
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval:
                    interval.toDouble(), // กำหนดช่วงระยะห่างของตัวเลขฝั่งซ้าย
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final keys = data.keys.toList();
                  if (value.toInt() < 0 || value.toInt() >= keys.length) {
                    return const Text('');
                  }
                  return Text(
                    keys[value.toInt()],
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: true),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding:
                  const EdgeInsets.only(top: 6, bottom: 6, left: 16, right: 16),
              tooltipMargin: 8,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(color: Colors.white, fontSize: 14),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartt(Map<String, int> data) {
    final maxValue = data.values.isNotEmpty
        ? data.values.reduce((a, b) => a > b ? a : b)
        : 0;
    final interval = (maxValue / 5).ceil(); // คำนวณช่วงระยะห่างจากค่ามากสุด

    final List<String> fixedOrder = ['ไฟฟ้า', 'ประปา', 'สวน', 'แอร์', 'อื่นๆ'];

    final Map<String, Color> fixedColors = {
      'ไฟฟ้า': Colors.orange,
      'ประปา': Colors.lightBlue,
      'สวน': Colors.green,
      'แอร์': Colors.red,
      'อื่นๆ': Colors.purple,
    };

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: fixedOrder.asMap().entries.map((entry) {
            final index = entry.key;
            final key = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data[key]?.toDouble() ?? 0,
                  color: fixedColors[key] ?? Colors.grey,
                  width: 24,
                  borderRadius: BorderRadius.circular(3),
                  rodStackItems: [],
                  borderSide: BorderSide.none,
                  backDrawRodData: BackgroundBarChartRodData(show: false),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval.toDouble(),
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= fixedOrder.length) {
                    return const Text('');
                  }
                  return Text(
                    fixedOrder[value.toInt()],
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: true),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding:
                  const EdgeInsets.only(top: 6, bottom: 6, left: 16, right: 16),
              tooltipMargin: 8,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(color: Colors.white, fontSize: 14),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    final List<String> fixedOrder = [
      'รอดำเนินการ',
      'กำลังดำเนินการ',
      'เสร็จสิ้น',
    ];

    Map<String, Color> sectionColors = {
      'รอดำเนินการ': Colors.orange[300]!,
      'กำลังดำเนินการ': Colors.blue[300]!,
      'เสร็จสิ้น': Colors.green[300]!,
    };

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: fixedOrder.map((key) {
                return PieChartSectionData(
                  title: '',
                  value: data[key]?.toDouble() ?? 0,
                  color: sectionColors[key] ?? Colors.grey,
                  radius: 150,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: fixedOrder.map((key) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: sectionColors[key] ?? Colors.grey,
                    shape: BoxShape.rectangle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "$key ${data[key] ?? 0}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }
}
