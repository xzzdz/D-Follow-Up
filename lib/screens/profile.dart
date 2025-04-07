import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/api.dart';
import '../constant/color_font.dart';

import 'package:http/http.dart' as http;

import '../constant/sidebar.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? username;
  String? role;
  String? email;
  String? tel;
  String? userId; // ตัวแปรเก็บ ID ผู้ใช้ที่ล็อกอิน
  bool _obscureText = true;

  List<dynamic> users = [];

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController telController = TextEditingController();

  Future<void> fetchUsers() async {
    String url = Api.get_users;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print("API response: $data"); // พิมพ์ข้อมูลที่ได้รับจาก API
      if (data['status'] == 'success') {
        setState(() {
          // ใช้ data['data'] แทนที่จะเป็น data['users']
          users = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        print("Failed to load users: ${data['message']}");
      }
    } else {
      print("Failed to load users");
    }
  }

  Future<void> editUser(String id) async {
    String url = Api.edit_user;

    // สร้าง body สำหรับส่งข้อมูล
    final Map<String, String> body = {
      'id': id,
      'name': nameController.text.trim(),
      'email': email ?? '',
      'role': role ?? '', // ใช้ role ที่ได้จาก _loadUserName
    };

    // ตรวจสอบและเพิ่ม password หากมี
    if (passwordController.text.isNotEmpty) {
      body['password'] = passwordController.text.trim();
    }

    if (telController.text.isNotEmpty) {
      body['tel'] = telController.text.trim();
    }

    // Debug: พิมพ์ข้อมูลที่กำลังจะส่ง
    print("Request body: $body");

    try {
      final response = await http.post(Uri.parse(url), body: body);
      final data = json.decode(response.body);

      if (data['status'] == "success") {
        print("User edited successfully.");
        fetchUsers(); // อัปเดตข้อมูลผู้ใช้
        // แสดงข้อความเตือนเมื่อการลบสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('แก้ไขข้อมูลสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print("Failed to edit user: ${data['message']}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('id'); // ดึง ID ผู้ใช้
      username = prefs.getString('name'); // ดึงค่าชื่อผู้ใช้
      role = prefs.getString('role'); // ดึงตำแหน่งผู้ใช้
      tel = prefs.getString('tel');
      email = prefs.getString('email'); // ดึงอีเมลผู้ใช้
      roleController.text = role ?? ''; // กำหนดตำแหน่งให้ในฟอร์ม
      nameController.text = username ?? ''; // กำหนดตำแหน่งให้ในฟอร์ม
    });
  }

  void initState() {
    super.initState();
    _loadUserName(); // โหลดข้อมูลก่อนแสดงผล
    fetchUsers(); // เรียกใช้งาน fetchUsers เพื่อโหลดข้อมูลผู้ใช้
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

                Expanded(
                  flex: 8,
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้าย
                        children: [
                          const SizedBox(height: 8.0),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              'โปรไฟล์',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Divider(thickness: 1.5),
                          const SizedBox(height: 16.0),
                          Center(
                            child: Container(
                              width: 150, // ขนาดของรูปโปรไฟล์
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, // รูปแบบวงกลม
                                image: const DecorationImage(
                                  image: AssetImage('assets/img/runnerx.png'),
                                  fit: BoxFit.cover, // ปรับรูปให้เต็มพื้นที่
                                ),
                                border: Border.all(
                                  color: bottoncolor, // ขอบสีขาว
                                  width: 3, // ความหนาของขอบ
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // ชิดซ้าย
                              children: [
                                const Text(
                                  'ชื่อ - นามสกุล',
                                  style: TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  username ?? '-',
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'ตำแหน่ง:',
                                  style: TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  role ?? '-',
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'ชื่อผู้ใช้งาน:',
                                  style: TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  email ?? '-',
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'เบอร์โทร:',
                                  style: TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tel ?? '-',
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    bool dialogObscureText =
                                        _obscureText; // ใช้ตัวแปรแยกใน dialog
                                    bool dialogConfirmObscureText =
                                        _obscureText; // สำหรับ confirm password
                                    TextEditingController
                                        confirmPasswordController =
                                        TextEditingController(); // เพิ่ม controller สำหรับ confirm password

                                    return StatefulBuilder(
                                      builder: (context, setDialogState) {
                                        return AlertDialog(
                                          title: const Text('แก้ไขผู้ใช้งาน'),
                                          content: Form(
                                            key: formKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // // อีเมลผู้ใช้งาน
                                                // TextFormField(
                                                //   controller: emailController,
                                                //   decoration:
                                                //       const InputDecoration(
                                                //     labelText: 'ชื่อผู้ใช้งาน',
                                                //     border:
                                                //         UnderlineInputBorder(),
                                                //   ),
                                                //   validator: (value) {
                                                //     if (value == null ||
                                                //         value.trim().isEmpty) {
                                                //       return 'กรุณาใส่ชื่อผู้ใช้งาน';
                                                //     }
                                                //     return null;
                                                //   },
                                                // ),

                                                // const SizedBox(height: 8.0),

                                                // รหัสผ่านใหม่
                                                TextFormField(
                                                  controller:
                                                      passwordController,
                                                  obscureText:
                                                      dialogObscureText,
                                                  decoration: InputDecoration(
                                                    labelText: 'รหัสผ่านใหม่',
                                                    hintText: 'ใส่รหัสผ่านใหม่',
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        dialogObscureText
                                                            ? Icons
                                                                .visibility_off
                                                            : Icons.visibility,
                                                      ),
                                                      onPressed: () {
                                                        setDialogState(() {
                                                          dialogObscureText =
                                                              !dialogObscureText;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return null; // ไม่จำเป็นต้องกรอกเบอร์โทรศัพท์
                                                    }
                                                    if (value.length < 6) {
                                                      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                                                    }
                                                    return null;
                                                  },
                                                ),

                                                const SizedBox(height: 8.0),

                                                TextFormField(
                                                  controller:
                                                      confirmPasswordController,
                                                  obscureText:
                                                      dialogConfirmObscureText,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'ยืนยันรหัสผ่านใหม่',
                                                    hintText:
                                                        'ใส่รหัสผ่านใหม่อีกครั้ง',
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        dialogConfirmObscureText
                                                            ? Icons
                                                                .visibility_off
                                                            : Icons.visibility,
                                                      ),
                                                      onPressed: () {
                                                        setDialogState(() {
                                                          dialogConfirmObscureText =
                                                              !dialogConfirmObscureText;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return null; // ไม่จำเป็นต้องกรอกเบอร์โทรศัพท์
                                                    }
                                                    if (value !=
                                                        passwordController
                                                            .text) {
                                                      return 'รหัสผ่านไม่ตรงกัน';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                TextFormField(
                                                  controller: telController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'เบอร์โทรศัพท์',
                                                    hintText:
                                                        'ใส่เบอร์โทรศัพท์',
                                                    border:
                                                        UnderlineInputBorder(),
                                                  ),
                                                  keyboardType: TextInputType
                                                      .phone, // ตั้งค่าให้คีย์บอร์ดเป็นแบบเบอร์โทร
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return null; // ไม่จำเป็นต้องกรอกเบอร์โทรศัพท์
                                                    }
                                                    // ตรวจสอบว่าเป็นเบอร์โทรศัพท์จริง (10 หลักและเริ่มต้นด้วย 0)
                                                    final RegExp telRegex =
                                                        RegExp(r'^0[0-9]{9}$');
                                                    if (!telRegex.hasMatch(
                                                        value.trim())) {
                                                      return 'กรุณาใส่เบอร์โทรศัพท์ที่ถูกต้อง (10 หลักและเริ่มต้นด้วย 0)';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text('ยกเลิก'),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                            TextButton(
                                              child: const Text('บันทึก'),
                                              onPressed: () async {
                                                // ตรวจสอบว่าฟอร์มถูกต้องหรือไม่
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  // ส่งข้อมูลไปแก้ไข
                                                  if (userId != null) {
                                                    await editUser(userId!);
                                                  } else {
                                                    print("User ID is null");
                                                  }
                                                  Navigator.of(context)
                                                      .pop(); // ปิด dialog ก่อน
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  await prefs
                                                      .clear(); // ลบข้อมูลทั้งหมด
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Login(),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              backgroundColor: bottoncolor, // สีพื้นหลัง
                              child: const Icon(
                                Icons.settings, // ไอคอน
                                color: Colors.white,
                              ),
                              tooltip:
                                  'แก้ไขผู้ใช้', // ข้อความแสดงเมื่อวางเมาส์ (Desktop)
                            ),
                          ),
                        ],
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

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn_project1');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(), // ไม่ต้องส่งชื่อผ่าน constructor
      ),
    );
  }
}
