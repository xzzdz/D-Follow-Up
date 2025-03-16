import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart'; // Web image picker
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../constant/api.dart';
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

  String _selectedStatus = 'รอดำเนินการ'; //รอดำเนินการ
  DateTime _selectedDate = DateTime.now();

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
                  child: SingleChildScrollView(
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
                              Autocomplete<Map<String, String>>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) async {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<
                                        Map<String, String>>.empty();
                                  }
                                  return await _fetchCustomers(
                                      textEditingValue.text);
                                },
                                displayStringForOption: (option) =>
                                    option['namec']!,
                                onSelected: (Map<String, String> selection) {
                                  setState(() {
                                    _namecController.text = selection['namec']!;
                                    _telcController.text = selection['telc']!;
                                    _addresscController.text =
                                        selection['addressc']!;
                                    _rolecController.text = selection['rolec']!;
                                    _agecController.text = selection['agec']!;
                                    _buycController.text = selection['buyc']!;
                                    _symptomcController.text =
                                        selection['symptomc']!;
                                    _wherecController.text =
                                        selection['wherec']!;
                                    _whencController.text = selection['whenc']!;
                                    _hispillcController.text =
                                        selection['hispillc']!;
                                    _hisdefpillcController.text =
                                        selection['hisdefpillc']!;
                                    _diagnosecController.text =
                                        selection['diagnosec']!;
                                    _detailController.text =
                                        selection['detail']!;
                                    _healcController.text = selection['healc']!;
                                  });
                                },
                                fieldViewBuilder: (context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted) {
                                  return TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      labelText: 'ชื่อลูกค้า:',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'กรุณากรอกชื่อลูกค้า';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _namecController.text =
                                          value; // อัปเดตค่า _namecController
                                    },
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
                                  labelText: 'การรักษา:',
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
                                        backgroundColor:
                                            Colors.red, // ปุ่มสีฟ้า
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
                                    const SizedBox(
                                        height: 10), // ระยะห่างระหว่างปุ่ม
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
                                        backgroundColor:
                                            Colors.green, // ปุ่มสีเขียว
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
