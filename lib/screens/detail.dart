import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../constant/api.dart';
import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'login.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/api.dart';

class Detail extends StatefulWidget {
  final dynamic item;

  const Detail({Key? key, required this.item}) : super(key: key);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  String? currentUserName;
  String? currentStatus;
  String? assignedTo;
  String? username;
  String? report_user_tel;
  String? assigned_to_tel;
  String? role;
  String? location; // เพิ่มตัวแปรสำหรับสถานที่
  String? imageUrl; // เพิ่มตัวแปรเพื่อเก็บ URL ของรูปภาพ

  @override
  void initState() {
    super.initState();
    _loadCurrentUserName();
    fetchReportDetail();
    _loadUserName();
  }

  TextEditingController hispillcController = TextEditingController();
  TextEditingController hisdefpillcController = TextEditingController();

  Future<void> _updateHistory(String field, String newValue) async {
    try {
      String url = Api.update_report;
      final response = await http.post(
        Uri.parse(url),
        body: {
          'id': widget.item['id'].toString(),
          field: newValue,
        },
      );

      var data = json.decode(response.body);

      if (data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปเดตข้อมูลเรียบร้อย')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _loadCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserName = prefs.getString('name');
    });
  }

  Future<void> fetchReportDetail() async {
    try {
      String url = Api.get_report_detail;
      final response = await http.post(
        Uri.parse(url),
        body: {'id': widget.item['id'].toString()},
      );

      var data = json.decode(response.body);

      if (data['status'] == "success") {
        setState(() {
          currentStatus = data['report']['status'];
          assignedTo = data['report']['assigned_to'];
          username = data['report']['username']; // ดึงข้อมูล username
          location = data['report']['location']; // ดึงข้อมูล location
          report_user_tel = data['report']['report_user_tel'];
          assigned_to_tel = data['report']['assigned_to_tel'];
          imageUrl = data['report']['image'] != null
              ? "${Api.baseUrl}image_view.php?filename=${data['report']['image']}"
              : null;

          print('Response JSON: $data');
          print('imageUrl: $imageUrl');
        });
      } else {
        _showSnackBar('เกิดข้อผิดพลาด: ${data['message']}');
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      String url = Api.update_status;
      Map<String, String> body = {
        'id': widget.item['id'].toString(),
        'status': newStatus,
        'assigned_to': currentStatus == "รอดำเนินการ"
            ? currentUserName ?? ''
            : assignedTo ?? '',
      };

      // ถ้าสถานะเป็น "เสร็จสิ้น" ให้เพิ่มค่าของ completed_time เป็นเวลาปัจจุบัน
      if (newStatus == "เสร็จสิ้น") {
        body['completed_time'] = DateTime.now().toString();
      }

      final response = await http.post(Uri.parse(url), body: body);

      var data = json.decode(response.body);

      if (data['status'] == "success") {
        setState(() {
          currentStatus = newStatus;
          if (newStatus == "กำลังดำเนินการ") {
            assignedTo = currentUserName;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สถานะถูกอัปเดตเรียบร้อย')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name');
      role = prefs.getString('role');
    });
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
                    leading: Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(Icons.menu),
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
                // Main Content ฝั่งขวา
                Expanded(
                  flex: 8,
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Header ด้านบน
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          decoration: BoxDecoration(
                            color: bottoncolor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const ListTile(
                            leading: Icon(Icons.report,
                                size: 40, color: Colors.white),
                            title: Text(
                              'รายละเอียดการติดตาม',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            // subtitle: Text(
                            //   'แสดงข้อมูลการแจ้งซ่อม',
                            //   style: TextStyle(color: Colors.white70),
                            // ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // การ์ดแสดงรายละเอียดแจ้งซ่อม
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ListView(
                              children: [
                                _buildDetailItem('Diagnose การวินิจฉัย',
                                    widget.item['diagnosec']),
                                _buildDetailItem(
                                    'วิธีการรักษา', widget.item['healc']),
                                if (widget.item['detailheal'] != null &&
                                    widget.item['detailheal'] != '')
                                  _buildDetailItem('รายละเอียดการรักษา',
                                      widget.item['detailheal']),
                                const SizedBox(height: 16),
                                _buildDetailItem(
                                    'ชื่อลูกค้า', widget.item['namec']),
                                _buildDetailItem(
                                    'เบอร์โทรติดต่อ', widget.item['telc']),
                                _buildDetailItem(
                                    'ที่อยู่', widget.item['addressc']),
                                _buildDetailItem('อาชีพ', widget.item['rolec']),
                                _buildDetailItem('อายุ', widget.item['agec']),
                                const SizedBox(height: 16),
                                _buildDetailItem(
                                    'ซื้อเอง/ฝากซื้อ', widget.item['buyc']),
                                _buildDetailItem(
                                    'อาการนำ', widget.item['symptomc']),
                                _buildDetailItem(
                                    'Where/Why', widget.item['wherec']),
                                _buildDetailItem('When', widget.item['whenc']),
                                const SizedBox(height: 16),
                                _buildEditableDetailItem("ประวัติการใช้ยา",
                                    widget.item['hispillc'], "hispillc"),
                                _buildEditableDetailItem("ประวัติแพ้ยา",
                                    widget.item['hisdefpillc'], "hisdefpillc"),
                                const SizedBox(height: 16),
                                _buildDetailItem(
                                    'วันที่ เวลา บันทึก', widget.item['date']),
                                if (widget.item['completed_time'] != null &&
                                    widget.item['completed_time'] != '')
                                  _buildDetailItem('วันที่ เวลา เสร็จสิ้น',
                                      widget.item['completed_time']),

                                _buildDetailItem(
                                    'รายละเอียดอื่นๆ', widget.item['detail']),

                                _buildDetailItem('สถานะ', currentStatus ?? '-'),

                                const SizedBox(height: 16),

                                if (imageUrl != null && imageUrl!.isNotEmpty)
                                  _buildImage(), // แสดงภาพที่โหลดจาก URL

                                const SizedBox(height: 20),

                                Align(
                                  alignment: Alignment.center,
                                  child: isMobile
                                      ? Column(
                                          children: [
                                            const SizedBox(height: 8),
                                            if (currentStatus == "รอดำเนินการ")
                                              _buildActionButton(
                                                  "กำลังดำเนินการ",
                                                  "กำลังดำเนินการ"),
                                            const SizedBox(height: 8),
                                            if (currentStatus ==
                                                    "รอดำเนินการ" ||
                                                currentStatus ==
                                                    "กำลังดำเนินการ")
                                              _buildActionButtonsuccess(
                                                  "เสร็จสิ้น", "เสร็จสิ้น"),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (currentStatus == "รอดำเนินการ")
                                              _buildActionButton(
                                                  "กำลังดำเนินการ",
                                                  "กำลังดำเนินการ"),
                                            if (currentStatus == "รอดำเนินการ")
                                              const SizedBox(width: 8),
                                            if (currentStatus ==
                                                    "รอดำเนินการ" ||
                                                currentStatus ==
                                                    "กำลังดำเนินการ")
                                              _buildActionButtonsuccess(
                                                  "เสร็จสิ้น", "เสร็จสิ้น"),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildEditableDetailItem(String title, String? value, String field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              // ใช้ Row เพื่อให้ปุ่มไอคอนอยู่ข้างหลังข้อความ
              children: [
                Expanded(
                  child: Text(
                    value ?? '-',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    overflow:
                        TextOverflow.ellipsis, // ถ้าข้อความยาวให้ตัดด้วย ...
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _showEditDialog(title, value, field),
                  icon: const Icon(
                    Icons.edit, // ไอคอนแก้ไข
                    color: Color.fromARGB(255, 7, 33, 54),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String title, String? currentValue, String field) {
    TextEditingController textController =
        TextEditingController(text: currentValue ?? "");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("แก้ไข $title"),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: "กรอกข้อมูลใหม่...",
              border: OutlineInputBorder(),
            ),
            maxLines: null, // ให้รองรับข้อความยาว
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด popup
              },
              child: const Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () {
                // อัปเดตข้อมูลที่ถูกแก้ไข
                _updateHistory(field, textController.text);

                // ใช้ setState เพื่ออัปเดตหน้าจอทันที
                setState(() {
                  // ตัวอย่าง: สมมติว่าเรากำหนดค่าของ field ที่จะแก้ไขใน widget.item
                  widget.item[field] = textController.text;
                });

                Navigator.of(context).pop(); // ปิด popup หลังบันทึก
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child:
                  const Text("บันทึก", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 400,
      height: 400,
      child: FittedBox(
        fit: BoxFit.contain, // ทำให้รูปเต็มโดยไม่ถูกตัด
        child: Image.network(imageUrl!),
      ),
    );
  }

  Widget _buildActionButtonsuccess(String label, String newStatus) {
    return ElevatedButton(
      onPressed: () => _updateStatus(newStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontFamily: Font_.Fonts_T,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, String newStatus) {
    return ElevatedButton(
      onPressed: () => _updateStatus(newStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontFamily: Font_.Fonts_T,
        ),
      ),
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }
}
