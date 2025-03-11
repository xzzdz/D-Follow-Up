import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'login.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _loadCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserName = prefs.getString('name');
    });
  }

  Future<void> fetchReportDetail() async {
    try {
      String url = "http://192.168.1.13/hotel_app_php/get_report_detail.php";
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
              ? "http://192.168.1.13/hotel_app_php/image_view.php?filename=${data['report']['image']}"
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
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Sidebar ฝั่งซ้าย
            Expanded(
              flex: 2,
              child: Sidebar(
                username: currentUserName,
                role: role,
                bottonColor: bottoncolor,
                onLogout: logout,
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
                        leading:
                            Icon(Icons.report, size: 40, color: Colors.white),
                        title: Text(
                          'รายละเอียดการแจ้งซ่อม',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'แสดงข้อมูลการแจ้งซ่อม',
                          style: TextStyle(color: Colors.white70),
                        ),
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
                            _buildDetailItem('รหัสแจ้งซ่อม', widget.item['id']),
                            _buildDetailItem(
                                'ผู้แจ้งซ่อม', username ?? '-'), // ใช้ username
                            _buildDetailItem(
                                'เบอร์โทรผู้แจ้งซ่อม', report_user_tel ?? '-'),

                            _buildDetailItem('ประเภท', widget.item['type']),
                            _buildDetailItem(
                                'สถานที่', location ?? '-'), // แสดงสถานที่
                            _buildDetailItem(
                                'รายละเอียด', widget.item['detail']),
                            _buildDetailItem('สถานะ', currentStatus ?? '-'),
                            _buildDetailItem('วันที่แจ้ง', widget.item['date']),

                            if (assignedTo != null && assignedTo!.isNotEmpty)
                              _buildDetailItem('ช่างซ่อม', assignedTo ?? '-'),

                            if (assignedTo != null && assignedTo!.isNotEmpty)
                              _buildDetailItem(
                                  'เบอร์โทรช่างซ่อม', assigned_to_tel ?? '-'),
                            const SizedBox(height: 16),

                            if (imageUrl != null && imageUrl!.isNotEmpty)
                              _buildImage(), // แสดงภาพที่โหลดจาก URL
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
      ),
    );
  }

  Widget _buildDetailItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // 'https://upload.wikimedia.org/wikipedia/commons/4/43/Cute_dog.jpg',
  // http://www.comdept.cmru.ac.th/64143168/hotel_app_php/uploads/679b234aa937e_img.jpg

  // 'http://www.comdept.cmru.ac.th/64143168/hotel_app_php/image_view.php?filename=uploads/67a1c1dfa406e_img.jpg'true

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

  Widget _buildActionButton(String label, String newStatus) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _updateStatus(newStatus),
        style: ElevatedButton.styleFrom(
          backgroundColor: bottoncolor,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      String url = "http://192.168.1.13/hotel_app_php/update_status.php";
      final response = await http.post(
        Uri.parse(url),
        body: {
          'id': widget.item['id'].toString(),
          'status': newStatus,
          'assigned_to':
              currentStatus == "รอดำเนินการ" ? currentUserName : assignedTo,
        },
      );

      var data = json.decode(response.body);

      if (data['status'] == "success") {
        setState(() {
          currentStatus = newStatus;
          if (newStatus == "กำลังดำเนินการ") {
            assignedTo = currentUserName;
          }
        });
        _showSnackBar('สถานะถูกอัปเดตเรียบร้อย');
      } else {
        _showSnackBar('เกิดข้อผิดพลาด: ${data['message']}');
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e');
    }
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
