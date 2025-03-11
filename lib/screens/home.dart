import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'detail.dart';
import 'login.dart';

class HomepageWeb extends StatefulWidget {
  const HomepageWeb({Key? key}) : super(key: key);

  @override
  State<HomepageWeb> createState() => _HomepageWebState();
}

class _HomepageWebState extends State<HomepageWeb> {
  String? username;
  String? role;
  String searchText = ''; // ตัวแปรสำหรับคำค้นหา

  int currentPage = 0;
  String? selectedType = 'ทั้งหมด';
  String? selectedStatus = 'ทั้งหมด';
  List<String> types = ['ทั้งหมด', 'ไฟฟ้า', 'ประปา', 'สวน', 'แอร์', 'อื่นๆ'];
  List<String> statuses = [
    'ทั้งหมด',
    'รอดำเนินการ',
    'กำลังดำเนินการ',
    'เสร็จสิ้น',
  ];

  bool isLoading = true;
  List<dynamic> reports = [];

  // ตัวแปรสำหรับตัวกรองเดือนและปี
  String? selectedMonth = 'ทั้งหมด';
  String? selectedYear = 'ทั้งหมด';

  List<String> months = [
    'ทั้งหมด',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];

  List<String> years = ['ทั้งหมด'];
  void generateYears() {
    int currentYear = DateTime.now().year;
    for (int i = 0; i < 5; i++) {
      years.add((currentYear - i).toString());
    }
  }

  // ฟังก์ชันในการดึงข้อมูลทั้งหมดจาก API
  Future<List<dynamic>> allReport() async {
    var url = "http://192.168.1.13/hotel_app_php/report.php";
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
      // print(response.body);
    } else {
      throw Exception("เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์");
    }
  }

  // ฟังก์ชันสำหรับลบข้อมูล
  Future<bool> deleteReport(String id) async {
    // แปลง id จาก String เป็น int
    int reportId = int.parse(id);

    final response = await http.post(
      Uri.parse('http://192.168.1.13/hotel_app_php/delete_report.php'),
      body: {'id': reportId.toString()},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // แสดงข้อความเตือนเมื่อการลบสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบข้อมูลสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        // แสดงข้อความเตือนเมื่อไม่สามารถลบได้
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถลบข้อมูลได้'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else {
      // แสดงข้อความเตือนเมื่อมีข้อผิดพลาดจากการเชื่อมต่อ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  // ฟังก์ชันในการดึงชื่อผู้ใช้จาก SharedPreferences
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
    generateYears();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar
            Expanded(
              flex: 2,
              child: Card(
                  child: Sidebar(
                username: username,
                role: role,
                bottonColor: bottoncolor,
                onLogout: logout,
              )),
            ),
            // Main Content
            Expanded(
              flex: 8,
              child: FutureBuilder<List<dynamic>>(
                future: allReport(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredData = snapshot.data!.where((item) {
                    DateTime reportDate = DateTime.parse(item['date']);
                    final matchesType = selectedType == 'ทั้งหมด' ||
                        item['type'] == selectedType;
                    final matchesStatus = selectedStatus == 'ทั้งหมด' ||
                        item['status'] == selectedStatus;
                    final matchesMonth = selectedMonth == 'ทั้งหมด' ||
                        reportDate.month.toString().padLeft(2, '0') ==
                            selectedMonth;
                    final matchesYear = selectedYear == 'ทั้งหมด' ||
                        reportDate.year.toString() == selectedYear;

                    final matchesSearch = searchText.isEmpty ||
                        item['detail']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item['location']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item['date']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item['type']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item['status']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item['username']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item['assigned_to']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase());
                    return matchesType &&
                        matchesStatus &&
                        matchesSearch &&
                        matchesMonth &&
                        matchesYear;
                  }).toList();

                  int rowsPerPage = 5; // กำหนดจำนวนแถวต่อหน้า
                  int totalPages = (filteredData.length / rowsPerPage).ceil();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "รายการติดตามลูกค้า",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            const Divider(thickness: 1.5),
                            const SizedBox(height: 16.0),
                            // Dashboard Section
                            Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildDashboardItemWithStyle(
                                      title: "รอดำเนินการ",
                                      count: filteredData
                                          .where((item) =>
                                              item['status'] == 'รอดำเนินการ')
                                          .length,
                                      color: Colors.orange,
                                      icon: Icons.hourglass_empty,
                                    ),
                                    _buildDashboardItemWithStyle(
                                      title: "กำลังดำเนินการ",
                                      count: filteredData
                                          .where((item) =>
                                              item['status'] ==
                                              'กำลังดำเนินการ')
                                          .length,
                                      color: Colors.blue,
                                      icon: Icons.autorenew,
                                    ),
                                    _buildDashboardItemWithStyle(
                                      title: "เสร็จสิ้น",
                                      count: filteredData
                                          .where((item) =>
                                              item['status'] == 'เสร็จสิ้น')
                                          .length,
                                      color: Colors.green,
                                      icon: Icons.check_circle,
                                    ),
                                    // _buildDashboardItemWithStyle(
                                    //   title: "ส่งซ่อมภายนอก",
                                    //   count: filteredData
                                    //       .where((item) =>
                                    //           item['status'] == 'ส่งซ่อมภายนอก')
                                    //       .length,
                                    //   color: Colors.red,
                                    //   icon: Icons.hardware,
                                    // ),
                                    _buildDashboardItemWithStyle(
                                      title: "ทั้งหมด",
                                      count: filteredData
                                          .where((item) =>
                                              item['status'] == 'รอดำเนินการ' ||
                                              item['status'] ==
                                                  'กำลังดำเนินการ' ||
                                              item['status'] == 'เสร็จสิ้น')
                                          .length,
                                      color: Colors.purple,
                                      icon: Icons.list_alt,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'พิมพ์คำค้นหา',
                                labelStyle:
                                    const TextStyle(fontFamily: Font_.Fonts_T),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () {
                                    setState(() {});
                                  },
                                ),
                              ),
                              onChanged: (value) {
                                searchText = value;
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 20),
                            // Filters Section
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                      "ประเภท", types, selectedType, (value) {
                                    setState(() {
                                      selectedType = value;
                                    });
                                  }),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdown(
                                      "สถานะ", statuses, selectedStatus,
                                      (value) {
                                    setState(() {
                                      selectedStatus = value;
                                    });
                                  }),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 120,
                                  child: Expanded(
                                    child: _buildDropdown(
                                        "เดือน", months, selectedMonth,
                                        (value) {
                                      setState(() {
                                        selectedMonth = value;
                                      });
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 120,
                                  child: Expanded(
                                    child: _buildDropdown(
                                        "ปี", years, selectedYear, (value) {
                                      setState(() {
                                        selectedYear = value;
                                      });
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Data Table with Pagination
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minWidth: constraints.maxWidth),
                                            child: DataTable(
                                              columnSpacing: 16.0,
                                              headingRowHeight: 50,
                                              dataRowHeight: 60,
                                              columns: const [
                                                DataColumn(
                                                  label: Text(
                                                    "วันที่ เวลา",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                // DataColumn(
                                                //   label: Text(
                                                //     "ประเภท",
                                                //     style: TextStyle(
                                                //         fontWeight:
                                                //             FontWeight.bold),
                                                //   ),
                                                // ),
                                                DataColumn(
                                                  label: Text(
                                                    "ชื่อลูกค้า",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "เบอร์โทรติดต่อ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "วินิจฉัย",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "ระยะเวลารอดำเนินการ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "สถานะ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "ดูเพิ่มเติม",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "จัดการ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                              rows: filteredData
                                                  .skip(
                                                      currentPage * rowsPerPage)
                                                  .take(rowsPerPage)
                                                  .map((item) {
                                                Color statusColor;

                                                // กำหนดสีและไอคอนตามสถานะ
                                                switch (item['status']) {
                                                  case 'รอดำเนินการ':
                                                    statusColor = Colors.orange;
                                                    break;
                                                  case 'กำลังดำเนินการ':
                                                    statusColor = Colors.blue;
                                                    break;
                                                  case 'เสร็จสิ้น':
                                                    statusColor = Colors.green;
                                                    break;
                                                  default:
                                                    statusColor = Colors.red;
                                                }

                                                return DataRow(cells: [
                                                  DataCell(Text(item['date'])),
                                                  DataCell(Text(item['type'])),

                                                  DataCell(
                                                      Text(item['location'])),
                                                  DataCell(Text(item['type'])),
                                                  // DataCell(
                                                  //   SizedBox(
                                                  //     width:
                                                  //         200, // กำหนดความกว้างที่ต้องการ
                                                  //     child: Text(
                                                  //       item['detail'].length >
                                                  //               20
                                                  //           ? item['detail']
                                                  //                   .substring(
                                                  //                       0, 20) +
                                                  //               '...'
                                                  //           : item[
                                                  //               'detail'], // ตัดข้อความที่เกิน 20 ตัวอักษร
                                                  //       overflow: TextOverflow
                                                  //           .ellipsis,
                                                  //       maxLines: 1,
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  DataCell(
                                                      Text(item['location'])),
                                                  DataCell(Row(
                                                    children: [
                                                      // const SizedBox(width: 8),
                                                      Text(
                                                        item['status'],
                                                        style: TextStyle(
                                                          color: statusColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ), // สีของข้อความสถานะ
                                                      ),
                                                    ],
                                                  )),
                                                  DataCell(
                                                    IconButton(
                                                      color: bottoncolor,
                                                      icon: const Icon(
                                                          Icons.info),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Detail(
                                                              item: item,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  // DataCell(
                                                  //   // ตรวจสอบ username ก่อนแสดงไอคอน
                                                  //   username == item['username']
                                                  //       ? IconButton(
                                                  //           color: Colors.red,
                                                  //           icon: const Icon(
                                                  //               Icons.delete),
                                                  //           onPressed:
                                                  //               () async {
                                                  //             // แสดงกล่องยืนยันการลบ
                                                  //             bool isConfirmed =
                                                  //                 await showDialog(
                                                  //               context:
                                                  //                   context,
                                                  //               builder:
                                                  //                   (BuildContext
                                                  //                       context) {
                                                  //                 return AlertDialog(
                                                  //                   title: Text(
                                                  //                       'ยืนยันการลบ'),
                                                  //                   content: Text(
                                                  //                       'คุณแน่ใจว่าต้องการลบรายการนี้?'),
                                                  //                   actions: <Widget>[
                                                  //                     TextButton(
                                                  //                       onPressed:
                                                  //                           () {
                                                  //                         Navigator.of(context)
                                                  //                             .pop(false); // ผู้ใช้กด "ยกเลิก"
                                                  //                       },
                                                  //                       child: Text(
                                                  //                           'ยกเลิก'),
                                                  //                     ),
                                                  //                     TextButton(
                                                  //                       onPressed:
                                                  //                           () {
                                                  //                         Navigator.of(context)
                                                  //                             .pop(true); // ผู้ใช้กด "ยืนยัน"
                                                  //                       },
                                                  //                       child: Text(
                                                  //                           'ยืนยัน'),
                                                  //                     ),
                                                  //                   ],
                                                  //                 );
                                                  //               },
                                                  //             );

                                                  //             // ถ้าผู้ใช้ยืนยันการลบ
                                                  //             if (isConfirmed) {
                                                  //               bool isSuccess =
                                                  //                   await deleteReport(
                                                  //                       item[
                                                  //                           'id']);
                                                  //               if (isSuccess) {
                                                  //                 // รีเฟรชข้อมูลหลังจากลบ
                                                  //                 setState(() {
                                                  //                   filteredData
                                                  //                       .remove(
                                                  //                           item);
                                                  //                 });
                                                  //               }
                                                  //             }
                                                  //           },
                                                  //         )
                                                  //       : const SizedBox(), // ไม่แสดงอะไรหาก username ไม่ตรงกัน
                                                  // ),
                                                  DataCell(
                                                    // ตรวจสอบ role และ username ก่อนแสดงไอคอน
                                                    role == 'ผู้ดูแลระบบ' ||
                                                            username ==
                                                                item['username']
                                                        ? IconButton(
                                                            color: Colors.red,
                                                            icon: const Icon(
                                                                Icons.delete),
                                                            onPressed:
                                                                () async {
                                                              // แสดงกล่องยืนยันการลบ
                                                              bool isConfirmed =
                                                                  await showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'ยืนยันการลบ'),
                                                                    content:
                                                                        const Text(
                                                                            'คุณแน่ใจว่าต้องการลบรายการนี้?'),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop(false); // ผู้ใช้กด "ยกเลิก"
                                                                        },
                                                                        child: const Text(
                                                                            'ยกเลิก'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop(true); // ผู้ใช้กด "ยืนยัน"
                                                                        },
                                                                        child: const Text(
                                                                            'ยืนยัน'),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );

                                                              // ถ้าผู้ใช้ยืนยันการลบ
                                                              if (isConfirmed) {
                                                                bool isSuccess =
                                                                    await deleteReport(
                                                                        item[
                                                                            'id']);
                                                                if (isSuccess) {
                                                                  // รีเฟรชข้อมูลหลังจากลบ
                                                                  setState(() {
                                                                    filteredData
                                                                        .remove(
                                                                            item);
                                                                  });
                                                                }
                                                              }
                                                            },
                                                          )
                                                        : const SizedBox(), // ไม่แสดงอะไรหากไม่มีสิทธิ์ลบ
                                                  )
                                                ]);
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Pagination Controls
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: bottoncolor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.first_page,
                                              color: Colors.white),
                                          label: const Text(
                                            "หน้าแรก",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          onPressed: currentPage > 0
                                              ? () {
                                                  setState(() {
                                                    currentPage = 0;
                                                  });
                                                }
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: bottoncolor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.arrow_back,
                                              color: Colors.white),
                                          label: const Text(
                                            "ก่อนหน้า",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          onPressed: currentPage > 0
                                              ? () {
                                                  setState(() {
                                                    currentPage--;
                                                  });
                                                }
                                              : null,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Text(
                                            "หน้า ${currentPage + 1} จาก ${totalPages}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: bottoncolor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.arrow_forward,
                                              color: Colors.white),
                                          label: const Text(
                                            "ถัดไป",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          onPressed:
                                              currentPage < totalPages - 1
                                                  ? () {
                                                      setState(() {
                                                        currentPage++;
                                                      });
                                                    }
                                                  : null,
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: bottoncolor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.last_page,
                                              color: Colors.white),
                                          label: const Text(
                                            "หน้าสุดท้าย",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                          onPressed:
                                              currentPage < totalPages - 1
                                                  ? () {
                                                      setState(() {
                                                        currentPage =
                                                            totalPages - 1;
                                                      });
                                                    }
                                                  : null,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItemWithStyle({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
          radius: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "$count",
          style: TextStyle(
              fontSize: 20, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDashboardItem(String title, int count) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(), // ไม่ต้องส่งชื่อผ่าน constructor
      ),
    );
  }
}
