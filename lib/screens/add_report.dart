import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart'; // Web image picker
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'home.dart';
import 'login.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:intl/intl.dart';

class AddReport extends StatefulWidget {
  const AddReport({super.key});

  @override
  State<AddReport> createState() => _AddReportState();
}

class _AddReportState extends State<AddReport> {
  String? username;
  String? role;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedType = 'ไฟฟ้า';
  String _selectedStatus = 'รอดำเนินการ'; //รอดำเนินการ
  // DateTime _selectedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  List<String> types = ['ไฟฟ้า', 'ประปา', 'สวน', 'แอร์', 'อื่นๆ'];
  List<String> statuses = ['รอดำเนินการ']; //รอดำเนินการ

  dynamic _selectedImage; // Change to dynamic for web image handling
  String _imageFileName = '';

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

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name');
      role = prefs.getString('role');
    });
  }

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

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      String url = "http://192.168.1.13/hotel_app_php/add_report.php";

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['username'] = username ?? '';
      request.fields['date'] = _selectedDate.toIso8601String();
      request.fields['type'] = _selectedType;
      request.fields['status'] = _selectedStatus;
      request.fields['detail'] = _detailController.text;
      request.fields['location'] = _locationController.text;

      print('username: $username');
      print('type: $_selectedType');
      print('status: $_selectedStatus');
      print('detail: ${_detailController.text}');
      print('location: ${_locationController.text}');

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

  @override
  void initState() {
    super.initState();
    _loadUserName();
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
                ),
              ),
            ),
            // Main Content
            Expanded(
              flex: 8,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'บันทึกรายละเอียดการติดตาม',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 16.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'ประเภท',
                                border: OutlineInputBorder(),
                              ),
                              items: types.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'สถานที่ ',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกสถานที่';
                                }
                                return null;
                              },
                            ),

                            Text(
                              '*หมายเหตุ ระบุให้ชัดเจน เช่น 201,401 หรือ บอกสถานที่ให้ชัดเจน',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                // fontFamily: Font_.Fonts_T
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _detailController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'รายละเอียด',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกรายละเอียด';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => _selectDateTime(context),
                                  icon: const Icon(Icons.calendar_today),
                                  label: const Text("เลือกวันที่และเวลา"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Display the selected image file name
                            if (_selectedImage != null)
                              Text(
                                "ชื่อไฟล์: $_imageFileName", // Show the file name here",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),

                            // Select image button
                            TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image),
                              label: const Text("เลือกภาพ"),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _submitReport,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 16.0),
                                  backgroundColor: bottoncolor,
                                ),
                                child: const Text("บันทึกการแจ้งซ่อม",
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 18,
                                      color: Colors.white,
                                    )),
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
          ],
        ),
      ),
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
