import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/api.dart';
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

  String? selectedStatus = 'ทั้งหมด';

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
    var url = Api.report;
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
      Uri.parse(Api.delete_report),
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

  String _calculateHoursBetween(String startTime, String? completedTime) {
    try {
      DateTime start = DateTime.parse(startTime); // เวลาที่แจ้งซ่อม
      DateTime end = (completedTime != null && completedTime.isNotEmpty)
          ? DateTime.parse(completedTime) // เวลาที่ซ่อมเสร็จ
          : DateTime.now(); // ถ้าไม่มีข้อมูล ให้ใช้เวลาปัจจุบันแทน

      Duration difference = end.difference(start); // คำนวณเวลาที่ใช้ไป

      if (difference.inHours < 1) {
        return 'น้อยกว่า 1 ชั่วโมง'; // ถ้าน้อยกว่า 1 ชั่วโมง
      } else {
        return '${difference.inHours} ชั่วโมง'; // แสดงผลเป็นชั่วโมง
      }
    } catch (e) {
      return '-'; // กรณีข้อมูลผิดพลาด
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _namecController = TextEditingController();
  final TextEditingController _telcController = TextEditingController();
  final TextEditingController _addresscController = TextEditingController();
  final TextEditingController _rolecController = TextEditingController();
  final TextEditingController _agecController = TextEditingController();
  final TextEditingController _buycController = TextEditingController();
  final TextEditingController _symptomcController = TextEditingController();
  final TextEditingController _wherecController = TextEditingController();
  final TextEditingController _whencController = TextEditingController();
  final TextEditingController _hispillcController = TextEditingController();
  final TextEditingController _hisdefpillcController = TextEditingController();
  final TextEditingController _diagnosecController = TextEditingController();
  final TextEditingController _healcController = TextEditingController();
  final TextEditingController _pedController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _followController = TextEditingController();
  final TextEditingController _pfuController = TextEditingController();

  String _selectedStatus = 'รอดำเนินการ'; //รอดำเนินการ
  DateTime _selectedDate = DateTime.now();

  // List<String> statuses = ['รอดำเนินการ']; //รอดำเนินการ

  dynamic _selectedImage; // Change to dynamic for web image handling
  String _imageFileName = '';

  Future<void> _pickImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _selectedImage = reader.result as Uint8List;
            _imageFileName = file.name; // ใช้ชื่อไฟล์จริงที่เลือก
          });
        });
      }
    });
  }

  Future<List<Map<String, String>>> _fetchCustomers(String query) async {
    String url = Api.getCustomers;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      return data
          .where((item) =>
              item['namec'] != null &&
              item['namec'].toString().contains(query)) // ป้องกัน null
          .map((item) => {
                'namec': item['namec']
                    .toString(), // แปลงเป็น String เพื่อป้องกันปัญหา
                'telc':
                    item['telc']?.toString() ?? '', // ป้องกัน null ใน 'telc'
                'addressc': item['addressc']?.toString() ??
                    '', // ป้องกัน null ใน 'addressc'
                'rolec':
                    item['rolec']?.toString() ?? '', // ป้องกัน null ใน 'rolec'
                'agec':
                    item['agec']?.toString() ?? '', // ป้องกัน null ใน 'agec'
                'buyc':
                    item['buyc']?.toString() ?? '', // ป้องกัน null ใน 'buyc'
                'symptomc': item['symptomc']?.toString() ??
                    '', // ป้องกัน null ใน 'symptomc'
                'wherec': item['wherec']?.toString() ??
                    '', // ป้องกัน null ใน 'wherec'
                'whenc':
                    item['whenc']?.toString() ?? '', // ป้องกัน null ใน 'whenc'
                'hispillc': item['hispillc']?.toString() ??
                    '', // ป้องกัน null ใน 'hispillc'
                'hisdefpillc': item['hisdefpillc']?.toString() ??
                    '', // ป้องกัน null ใน 'hisdefpillc'
                'diagnosec': item['diagnosec']?.toString() ??
                    '', // ป้องกัน null ใน 'diagnosec'
                'detail': item['detail']?.toString() ??
                    '', // ป้องกัน null ใน 'detail'
                'healc':
                    item['healc']?.toString() ?? '', // ป้องกัน null ใน 'healc'
                'ped': item['ped']?.toString() ?? '', // ป้องกัน null ใน 'ped'
                'plan':
                    item['plan']?.toString() ?? '', // ป้องกัน null ใน 'plan'
                'follow': item['follow']?.toString() ??
                    '', // ป้องกัน null ใน 'follow'
                'pfu': item['pfu']?.toString() ?? '', // ป้องกัน null ใน 'pfu'
              })
          .toList();
    } else {
      return [];
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      String url = Api.add_report;

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['username'] = username ?? '';
      request.fields['date'] = _selectedDate.toIso8601String();
      request.fields['status'] = _selectedStatus;
      request.fields['detail'] = _detailController.text;
      request.fields['namec'] = _namecController.text;
      request.fields['telc'] = _telcController.text;
      request.fields['addressc'] = _addresscController.text;
      request.fields['rolec'] = _rolecController.text;
      request.fields['agec'] = _agecController.text;
      request.fields['buyc'] = _buycController.text;
      request.fields['symptomc'] = _symptomcController.text;
      request.fields['wherec'] = _wherecController.text;
      request.fields['whenc'] = _whencController.text;
      request.fields['hispillc'] = _hispillcController.text;
      request.fields['hisdefpillc'] = _hisdefpillcController.text;
      request.fields['diagnosec'] = _diagnosecController.text;
      request.fields['healc'] = _healcController.text;
      request.fields['ped'] = _pedController.text;
      request.fields['plan'] = _planController.text;
      request.fields['follow'] = _followController.text;
      request.fields['pfu'] = _pfuController.text;

      print(request.fields);

      // For web (dart:io not available)
      if (kIsWeb && _selectedImage != null) {
        // ดึงนามสกุลไฟล์ (เช่น .jpg, .png เป็นต้น)
        String extension = _getFileExtension(_selectedImage);

        // สร้าง MultipartFile โดยใช้ชื่อไฟล์ที่ตั้งแบบไดนามิก
        var imageFile = http.MultipartFile.fromBytes(
          'image',
          _selectedImage,
          filename: 'img$extension', // ใช้ชื่อไฟล์ที่ได้จากนามสกุล
        );
        request.files.add(imageFile); // เพิ่มไฟล์ภาพ
      }

      // ถ้าสถานะเป็น "เสร็จสิ้น" ให้เพิ่มค่าของ completed_time เป็นเวลาปัจจุบัน
      if (_selectedStatus == "เสร็จสิ้น") {
        request.fields['completed_time'] = DateTime.now().toString();
      }

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          print(responseData);

          if (responseData['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("บันทึกข้อมูลสำเร็จ!"),
                  backgroundColor: Colors.green),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomepageWeb()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("เกิดข้อผิดพลาด: ${responseData['message']}")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("เกิดข้อผิดพลาด: ${response.statusCode}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์")),
        );
      }
    }
  }

  // ฟังก์ชันในการดึงนามสกุลไฟล์ (เช่น .jpg, .png)
  String _getFileExtension(Uint8List imageBytes) {
    // หากคุณทราบประเภทของไฟล์ (เช่น jpeg หรือ png) คุณสามารถตรวจสอบจากไบต์แรกๆ ของไฟล์ได้
    String extension = ".jpg"; // กำหนดเป็น .jpg ถ้าไม่ทราบ (สามารถขยายได้)
    if (_selectedImage.isNotEmpty) {
      var byteHeader = _selectedImage.sublist(0, 4);
      if (byteHeader[0] == 0x89 && byteHeader[1] == 0x50) {
        extension = '.png'; // PNG
      } else if (byteHeader[0] == 0xFF && byteHeader[1] == 0xD8) {
        extension = '.jpg'; // JPG
      }
      // คุณสามารถขยายตรรกะนี้ให้รองรับรูปแบบอื่นๆ ได้ตามต้องการ
    }
    return extension;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 1020;
            return isMobile
                ? AppBar(
                    backgroundColor: bottoncolor,
                    leading: Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(Icons.menu),
                          color: Colors.white,
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 1020;
          return isMobile
              ? Drawer(
                  child: Sidebar(
                    username: username,
                    role: role,
                    bottonColor: bottoncolor,
                    onLogout: logout,
                  ),
                )
              : Container();
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile =
              constraints.maxWidth < 1020; // เช็คว่าหน้าจอเล็กหรือใหญ่

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar
                if (!isMobile) // แสดง Sidebar เฉพาะตอนที่หน้าจอใหญ่
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Sidebar(
                        username: username,
                        role: role,
                        bottonColor: bottoncolor,
                        onLogout: logout,
                      ),
                    ),
                  ),

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
                            FutureBuilder<List<dynamic>>(
                              future: allReport(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                    child:
                                        Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"),
                                  );
                                }

                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                final filteredData =
                                    snapshot.data!.where((item) {
                                  DateTime reportDate =
                                      DateTime.parse(item['date']);

                                  final matchesStatus =
                                      selectedStatus == 'ทั้งหมด' ||
                                          item['status'] == selectedStatus;
                                  final matchesMonth =
                                      selectedMonth == 'ทั้งหมด' ||
                                          reportDate.month
                                                  .toString()
                                                  .padLeft(2, '0') ==
                                              selectedMonth;
                                  final matchesYear =
                                      selectedYear == 'ทั้งหมด' ||
                                          reportDate.year.toString() ==
                                              selectedYear;

                                  final matchesSearch = searchText.isEmpty ||
                                      item.values.any((value) => value
                                          .toString()
                                          .toLowerCase()
                                          .contains(searchText.toLowerCase()));
                                  return matchesStatus &&
                                      matchesSearch &&
                                      matchesMonth &&
                                      matchesYear;
                                }).toList();

                                // 👉 จัดเรียงให้ "เสร็จสิ้น" ไปอยู่ข้างล่าง
                                filteredData.sort((a, b) {
                                  if (a['status'] == 'เสร็จสิ้น' &&
                                      b['status'] != 'เสร็จสิ้น') {
                                    return 1;
                                  } else if (a['status'] != 'เสร็จสิ้น' &&
                                      b['status'] == 'เสร็จสิ้น') {
                                    return -1;
                                  } else {
                                    return 0;
                                  }
                                });

                                int rowsPerPage = 15; // กำหนดจำนวนแถวต่อหน้า
                                int totalPages =
                                    (filteredData.length / rowsPerPage).ceil();

                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "รายการติดตามลูกค้า",
                                                      style: TextStyle(
                                                        fontSize: 26,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Container(
                                                    width: 200,
                                                    child: TextField(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'พิมพ์คำค้นหา',
                                                        labelStyle:
                                                            const TextStyle(
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        suffixIcon: IconButton(
                                                          icon: const Icon(
                                                              Icons.search),
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
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8.0),
                                              const Divider(thickness: 1.5),
                                              const SizedBox(height: 16.0),

                                              //Dashboard Section
                                              Column(
                                                children: [
                                                  Card(
                                                    elevation: 4,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 16),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          _buildDashboardItemWithStyle(
                                                            title:
                                                                "รอดำเนินการ",
                                                            count: filteredData
                                                                .where((item) =>
                                                                    item[
                                                                        'status'] ==
                                                                    'รอดำเนินการ')
                                                                .length,
                                                            color:
                                                                Colors.orange,
                                                            icon: Icons
                                                                .hourglass_empty,
                                                            isSelected:
                                                                selectedStatus ==
                                                                    'รอดำเนินการ',
                                                            onTap: () {
                                                              setState(() {
                                                                selectedStatus =
                                                                    'รอดำเนินการ';
                                                              });
                                                            },
                                                          ),
                                                          _buildDashboardItemWithStyle(
                                                            title:
                                                                "กำลังดำเนินการ",
                                                            count: filteredData
                                                                .where((item) =>
                                                                    item[
                                                                        'status'] ==
                                                                    'กำลังดำเนินการ')
                                                                .length,
                                                            color: Colors.blue,
                                                            icon:
                                                                Icons.autorenew,
                                                            isSelected:
                                                                selectedStatus ==
                                                                    'กำลังดำเนินการ',
                                                            onTap: () {
                                                              setState(() {
                                                                selectedStatus =
                                                                    'กำลังดำเนินการ';
                                                              });
                                                            },
                                                          ),
                                                          _buildDashboardItemWithStyle(
                                                            title: "เสร็จสิ้น",
                                                            count: filteredData
                                                                .where((item) =>
                                                                    item[
                                                                        'status'] ==
                                                                    'เสร็จสิ้น')
                                                                .length,
                                                            color: Colors.green,
                                                            icon: Icons
                                                                .check_circle,
                                                            isSelected:
                                                                selectedStatus ==
                                                                    'เสร็จสิ้น',
                                                            onTap: () {
                                                              setState(() {
                                                                selectedStatus =
                                                                    'เสร็จสิ้น';
                                                              });
                                                            },
                                                          ),
                                                          _buildDashboardItemWithStyle(
                                                            title: "ทั้งหมด",
                                                            count: filteredData
                                                                .length,
                                                            color:
                                                                Colors.purple,
                                                            icon:
                                                                Icons.list_alt,
                                                            isSelected:
                                                                selectedStatus ==
                                                                    'ทั้งหมด',
                                                            onTap: () {
                                                              setState(() {
                                                                selectedStatus =
                                                                    'ทั้งหมด';
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 20),
                                                  //Filters Section
                                                  if (constraints.maxWidth <
                                                      500) // กำหนดขนาดหน้าจอเอง
                                                    Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              child: _buildDropdown(
                                                                  "สถานะ",
                                                                  statuses,
                                                                  selectedStatus,
                                                                  (value) {
                                                                setState(() {
                                                                  selectedStatus =
                                                                      value;
                                                                });
                                                              }),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              child: _buildDropdown(
                                                                  "เดือน",
                                                                  months,
                                                                  selectedMonth,
                                                                  (value) {
                                                                setState(() {
                                                                  selectedMonth =
                                                                      value;
                                                                });
                                                              }),
                                                            ),
                                                            const SizedBox(
                                                                width: 16),
                                                            Container(
                                                              child: _buildDropdown(
                                                                  "ปี",
                                                                  years,
                                                                  selectedYear,
                                                                  (value) {
                                                                setState(() {
                                                                  selectedYear =
                                                                      value;
                                                                });
                                                              }),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    Row(
                                                      children: [
                                                        Container(
                                                          child: _buildDropdown(
                                                              "สถานะ",
                                                              statuses,
                                                              selectedStatus,
                                                              (value) {
                                                            setState(() {
                                                              selectedStatus =
                                                                  value;
                                                            });
                                                          }),
                                                        ),
                                                        const SizedBox(
                                                            width: 16),
                                                        Container(
                                                          // width: 120,
                                                          child: Container(
                                                            child: _buildDropdown(
                                                                "เดือน",
                                                                months,
                                                                selectedMonth,
                                                                (value) {
                                                              setState(() {
                                                                selectedMonth =
                                                                    value;
                                                              });
                                                            }),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 16),
                                                        Container(
                                                          // width: 120,
                                                          child: Container(
                                                            child:
                                                                _buildDropdown(
                                                                    "ปี",
                                                                    years,
                                                                    selectedYear,
                                                                    (value) {
                                                              setState(() {
                                                                selectedYear =
                                                                    value;
                                                              });
                                                            }),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  const SizedBox(height: 16),

                                                  // Data Table with Pagination

                                                  ///////////////////////////////
                                                  SingleChildScrollView(
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              BoxConstraints(
                                                                  minWidth:
                                                                      constraints
                                                                          .maxWidth),
                                                          child: DataTable(
                                                            columnSpacing: 16.0,
                                                            headingRowHeight:
                                                                50,
                                                            dataRowHeight: 60,
                                                            columns: const [
                                                              DataColumn(
                                                                label: Text(
                                                                  "วันที่ เวลา",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  "ชื่อลูกค้า",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  "เบอร์โทรติดต่อ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  "วินิจฉัย",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  "ระยะเวลารอดำเนินการ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  "สถานะ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  "ดูเพิ่มเติม",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  "จัดการ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                            rows: filteredData
                                                                .skip(currentPage *
                                                                    rowsPerPage)
                                                                .take(
                                                                    rowsPerPage)
                                                                .map((item) {
                                                              Color statusColor;

                                                              // กำหนดสีและไอคอนตามสถานะ
                                                              switch (item[
                                                                  'status']) {
                                                                case 'รอดำเนินการ':
                                                                  statusColor =
                                                                      Colors
                                                                          .orange;
                                                                  break;
                                                                case 'กำลังดำเนินการ':
                                                                  statusColor =
                                                                      Colors
                                                                          .blue;
                                                                  break;
                                                                case 'เสร็จสิ้น':
                                                                  statusColor =
                                                                      Colors
                                                                          .green;
                                                                  break;
                                                                default:
                                                                  statusColor =
                                                                      Colors
                                                                          .red;
                                                              }

                                                              return DataRow(
                                                                  cells: [
                                                                    DataCell(
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => Detail(item: item),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Text(
                                                                            item['date']),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => Detail(item: item),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Text(
                                                                            item['namec']),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => Detail(item: item),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Text(
                                                                            item['telc']),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => Detail(item: item),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              200,
                                                                          child:
                                                                              Text(
                                                                            item['diagnosec'].length > 20
                                                                                ? item['diagnosec'].substring(0, 20) + '...'
                                                                                : item['diagnosec'],
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => Detail(item: item),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          _calculateHoursBetween(
                                                                              item['date'],
                                                                              item['completed_time']),
                                                                          style:
                                                                              TextStyle(fontSize: 16),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => Detail(item: item),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          item[
                                                                              'status'],
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                statusColor,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      IconButton(
                                                                        color:
                                                                            bottoncolor,
                                                                        icon: const Icon(
                                                                            Icons.info),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => Detail(
                                                                                item: item,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      role == "ผู้ดูแลระบบ" ||
                                                                              role == "พนักงาน"
                                                                          ? IconButton(
                                                                              color: Colors.red,
                                                                              icon: const Icon(Icons.delete),
                                                                              onPressed: () async {
                                                                                bool isConfirmed = await showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return AlertDialog(
                                                                                      title: const Text('ยืนยันการลบ'),
                                                                                      content: const Text('คุณแน่ใจว่าต้องการลบรายการนี้?'),
                                                                                      actions: <Widget>[
                                                                                        TextButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop(false);
                                                                                          },
                                                                                          child: const Text('ยกเลิก'),
                                                                                        ),
                                                                                        TextButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop(true);
                                                                                          },
                                                                                          child: const Text('ยืนยัน'),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                );

                                                                                if (isConfirmed) {
                                                                                  bool isSuccess = await deleteReport(item['id'].toString());

                                                                                  if (isSuccess) {
                                                                                    setState(() {
                                                                                      filteredData.remove(item);
                                                                                    });
                                                                                  }
                                                                                }
                                                                              })
                                                                          : const SizedBox(), // ไม่แสดงอะไรหากไม่มีสิทธิ์ลบ
                                                                    )
                                                                  ]);
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // ปุ่มเปลี่ยนหน้าไว้ชิดซ้าย
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons
                                                                    .arrow_back),
                                                            onPressed:
                                                                currentPage > 0
                                                                    ? () {
                                                                        setState(
                                                                            () {
                                                                          currentPage--;
                                                                        });
                                                                      }
                                                                    : null,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                            child: Text(
                                                              "${currentPage + 1} / $totalPages",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(Icons
                                                                .arrow_forward),
                                                            onPressed: currentPage <
                                                                    totalPages -
                                                                        1
                                                                ? () {
                                                                    setState(
                                                                        () {
                                                                      currentPage++;
                                                                    });
                                                                  }
                                                                : null,
                                                          ),
                                                        ],
                                                      ),

                                                      // FloatingActionButton ไว้ชิดขวา
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child:
                                                            FloatingActionButton(
                                                          backgroundColor:
                                                              bottoncolor,
                                                          child: const Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () {
                                                            _showCustomerFormDialog(
                                                                context);
                                                          },
                                                          tooltip:
                                                              "เพิ่มรายละเอียด",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
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
          );
        },
      ),
    );
  }

  void _showCustomerFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('บันทึกรายละเอียดการติดตาม'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.3, // ปรับขนาดให้พอดี
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // ให้ขนาดเล็กสุดที่เป็นไปได้
                  children: [
                    // Autocomplete สำหรับค้นหาลูกค้า
                    Autocomplete<Map<String, String>>(
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Map<String, String>>.empty();
                        }
                        return await _fetchCustomers(textEditingValue.text);
                      },
                      displayStringForOption: (option) => option['namec']!,
                      onSelected: (Map<String, String> selection) {
                        setState(() {
                          _namecController.text = selection['namec']!;
                          _telcController.text = selection['telc']!;
                          _addresscController.text = selection['addressc']!;
                          _rolecController.text = selection['rolec']!;
                          _agecController.text = selection['agec']!;
                          _buycController.text = selection['buyc']!;
                          _symptomcController.text = selection['symptomc']!;
                          _wherecController.text = selection['wherec']!;
                          _whencController.text = selection['whenc']!;
                          _hispillcController.text = selection['hispillc']!;
                          _hisdefpillcController.text =
                              selection['hisdefpillc']!;
                          _diagnosecController.text = selection['diagnosec']!;
                          _detailController.text = selection['detail']!;
                          _healcController.text = selection['healc']!;
                          _pedController.text = selection['ped']!;
                          _planController.text = selection['plan']!;
                          _followController.text = selection['follow']!;
                          _pfuController.text = selection['pfu']!;
                        });
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'ชื่อลูกค้า:',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกชื่อลูกค้า';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _namecController.text = value;
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.3, // กำหนดขนาดของ dropdown
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(
                                      option['namec']!,
                                      style: const TextStyle(
                                          fontSize:
                                              16), // ปรับขนาดตัวอักษรที่แสดง
                                    ),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ช่องกรอกเบอร์โทรลูกค้า
                    TextFormField(
                      controller: _telcController,
                      decoration: const InputDecoration(
                        labelText: 'เบอร์โทรลูกค้า:',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกเบอร์โทรลูกค้า';
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return 'กรุณากรอกเบอร์โทรให้ถูกต้อง (10 หลัก)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addresscController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'ที่อยู่:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _rolecController,
                      decoration: const InputDecoration(
                        labelText: 'อาชีพ:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _agecController,
                      decoration: const InputDecoration(
                        labelText: 'อายุ:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _buycController,
                      decoration: const InputDecoration(
                        labelText: 'ซื้อเอง/ฝากซื้อ:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _symptomcController,
                      decoration: const InputDecoration(
                        labelText: 'อาการนำ:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _wherecController,
                      decoration: const InputDecoration(
                        labelText: 'Where/Why:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _whencController,
                      decoration: const InputDecoration(
                        labelText: 'When:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _hispillcController,
                      decoration: const InputDecoration(
                        labelText: 'ประวัติการใช้ยา:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _hisdefpillcController,
                      decoration: const InputDecoration(
                        labelText: 'ประวัติแพ้ยา:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _diagnosecController,
                      decoration: const InputDecoration(
                        labelText: 'Diagnose การวินิจฉัย:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _detailController,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียดอื่นๆ:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _healcController,
                      decoration: const InputDecoration(
                        labelText: 'การรักษา/Rx Name /Regimen:',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _pedController,
                      decoration: const InputDecoration(
                        labelText: 'Platient ED:',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _planController,
                      decoration: const InputDecoration(
                        labelText: 'Plan:',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _followController,
                      decoration: const InputDecoration(
                        labelText: 'Follow:',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _pfuController,
                      decoration: const InputDecoration(
                        labelText: 'Plan หลัง F/U:',
                        labelStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _selectDateTime(context),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text("เลือกวันที่และเวลา:"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (_selectedImage != null)
                      Text(
                        "ชื่อไฟล์: $_imageFileName",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),

                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("เลือกภาพ:"),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedStatus = 'รอดำเนินการ';
                              });
                              _submitReport();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0, vertical: 16.0),
                              backgroundColor: Colors.red, // ปุ่มสีฟ้า
                            ),
                            child: const Text(
                              "บันทึกรายละเอียด (รอดำเนินการ)",
                              style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10), // ระยะห่างระหว่างปุ่ม
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedStatus = 'เสร็จสิ้น';
                              });
                              _submitReport();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0, vertical: 16.0),
                              backgroundColor: Colors.green, // ปุ่มสีเขียว
                            ),
                            child: const Text(
                              "บันทึกรายละเอียด (ดำเนินการเสร็จสิ้น)",
                              style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildDashboardItemWithStyle({
  //   required String title,
  //   required int count,
  //   required Color color,
  //   required IconData icon,
  // }) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       CircleAvatar(
  //         backgroundColor: color.withOpacity(0.2),
  //         child: Icon(icon, color: color),
  //         radius: 24,
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         title,
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         "$count",
  //         style: TextStyle(
  //             fontSize: 20, color: color, fontWeight: FontWeight.bold),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDashboardItemWithStyle({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor:
                isSelected ? color.withOpacity(0.4) : color.withOpacity(0.2),
            child: Icon(icon, color: color),
            radius: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? color : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$count",
            style: TextStyle(
                fontSize: 20, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
    // await prefs.clear();
    await prefs.remove('isLoggedIn_project1');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(), // ไม่ต้องส่งชื่อผ่าน constructor
      ),
    );
  }
}
