import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/api.dart';
import '../constant/color_font.dart';
import '../constant/form_add_users.dart';
import '../constant/sidebar.dart';
import 'login.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _AddUsersState();
}

class _AddUsersState extends State<ManageUsers> {
  // Variables for storing user data
  bool _obscureText = true;
  String? username;
  String? role;
  String? selectedRole = 'ทั้งหมด';
  List<String> roles = [
    'ทั้งหมด',
    'ผู้ดูแลระบบ',
    'พนักงาน',
    'แพทย์',
    'ญาติ',
  ];

  List<dynamic> users = [];

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController telController = TextEditingController();

  // Function to fetch users
  Future<void> fetchUsers() async {
    String url = Api.get_users;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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

  // Function to add users
  Future<void> AddUsers() async {
    String url = Api.add_users;

    final response = await http.post(Uri.parse(url), body: {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'role': roleController.text,
      'tel': telController.text
    });

    print(response.body);

    var data = json.decode(response.body);
    if (data['status'] == "success") {
      fetchUsers(); // อัปเดตข้อมูลผู้ใช้
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      roleController.clear();
      telController.clear();
    } else {
      print("Failed to add user: ${data['message']}");
    }
  }

  // Function to delete a user
  Future<void> deleteUser(String id) async {
    String url = Api.delete_user;

    final response = await http.post(Uri.parse(url), body: {
      'id': id,
    });

    var data = json.decode(response.body);
    if (data['status'] == "success") {
      fetchUsers(); // อัปเดตข้อมูลผู้ใช้
      // แสดงข้อความเตือนเมื่อการลบสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลบข้อมูลสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("Failed to delete user: ${data['message']}");
    }
  }

  Future<void> editUser(String id) async {
    String url = Api.edit_user;

    // สร้าง body สำหรับส่งข้อมูล
    final Map<String, String> body = {
      'id': id,
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'role': roleController.text.trim(),
    };

    // ตรวจสอบและเพิ่ม password หากมี
    if (passwordController.text.isNotEmpty) {
      body['password'] = passwordController.text.trim();
    }

    // ตรวจสอบและเพิ่ม tel หากมี
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
      username = prefs.getString('name');
      role = prefs.getString('role');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    fetchUsers();
  }

  // Function เปิดฟอร์มใน Dialog
  void openAddUserForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'เพิ่มผู้ใช้ใหม่',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 24,
            fontFamily: Font_.Fonts_T,
          ),
        ),
        content: SingleChildScrollView(
          child: AddUserForm(
            formKey: formKey,
            roleController: roleController,
            nameController: nameController,
            emailController: emailController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            telController: telController,
            onSubmit: AddUsers,
          ),
        ),
      ),
    );
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

                // Form Section
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
                            'จัดการผู้ใช้งาน',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Divider(thickness: 1.5),
                          const SizedBox(height: 16.0),

                          // ค้นหาตำแหน่งงาน
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedRole,
                                  decoration: const InputDecoration(
                                    labelText: 'ค้นหาตำแหน่งงาน',
                                  ),
                                  items: roles.map((role) {
                                    return DropdownMenuItem<String>(
                                      value: role,
                                      child: Text(role),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedRole = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Expanded(
                            child: isMobile
                                ? Expanded(
                                    child: ListView(
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            columnSpacing:
                                                100.0, // เพิ่มระยะห่างระหว่างคอลัมน์
                                            dataRowHeight:
                                                60.0, // เพิ่มระยะห่างระหว่างเซลล์
                                            columns: const [
                                              DataColumn(
                                                  label: Text('ชื่อ - นามสกุล',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('ชื่อผู้ใช้งาน',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('ตำแหน่ง',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('เบอร์โทรศัพท์',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              DataColumn(
                                                  label: Text('     จัดการ',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            ],
                                            rows: users.where((user) {
                                              // กรองผู้ใช้ตามตำแหน่งงาน
                                              return selectedRole ==
                                                      'ทั้งหมด' ||
                                                  user['role'] == selectedRole;
                                            }).map((user) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(Text(user['name'] ??
                                                      'No Name')),
                                                  DataCell(Text(user['email'] ??
                                                      'No Email')),
                                                  DataCell(Text(user['role'] ??
                                                      'No Role')),
                                                  DataCell(Text(user['tel'] ??
                                                      'No Role')),
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.edit,
                                                            color: bottoncolor,
                                                          ),
                                                          onPressed: () {
                                                            nameController
                                                                    .text =
                                                                user['name'];
                                                            emailController
                                                                    .text =
                                                                user['email'];
                                                            roleController
                                                                    .text =
                                                                user['role'];
                                                            passwordController
                                                                    .text =
                                                                ""; // ตั้งค่าเริ่มต้นให้เป็นค่าว่าง
                                                            TextEditingController
                                                                confirmPasswordController =
                                                                TextEditingController(); // เพิ่ม controller สำหรับยืนยันรหัสผ่าน

                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                bool
                                                                    dialogObscureText =
                                                                    _obscureText; // ใช้ตัวแปรแยกใน dialog
                                                                bool
                                                                    dialogConfirmObscureText =
                                                                    _obscureText; // ใช้สำหรับ confirm password
                                                                return StatefulBuilder(
                                                                  builder: (context,
                                                                      setDialogState) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'แก้ไขผู้ใช้งาน'),
                                                                      content:
                                                                          Form(
                                                                        key:
                                                                            formKey,
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            // ชื่อผู้ใช้งาน
                                                                            TextFormField(
                                                                              controller: nameController,
                                                                              decoration: const InputDecoration(
                                                                                labelText: 'ชื่อ - นามสกุล',
                                                                                hintText: 'ใส่ชื่อ - นามสกุล',
                                                                                border: UnderlineInputBorder(),
                                                                              ),
                                                                              validator: (value) {
                                                                                if (value == null || value.trim().isEmpty) {
                                                                                  return 'กรุณาใส่ชื่อ - นามสกุล';
                                                                                }
                                                                                return null;
                                                                              },
                                                                            ),

                                                                            const SizedBox(height: 8.0),

                                                                            // อีเมลผู้ใช้งาน
                                                                            TextFormField(
                                                                              controller: emailController,
                                                                              decoration: const InputDecoration(
                                                                                labelText: 'ชื่อผู้ใช้งาน',
                                                                                hintText: 'ใส่ชื่อผู้ใช้งาน',
                                                                                border: UnderlineInputBorder(),
                                                                              ),
                                                                              validator: (value) {
                                                                                if (value == null || value.trim().isEmpty) {
                                                                                  return 'กรุณาใส่ชื่อผู้ใช้งาน';
                                                                                }
                                                                                return null;
                                                                              },
                                                                            ),

                                                                            const SizedBox(height: 8.0),

                                                                            // ตำแหน่งงานผู้ใช้งาน
                                                                            DropdownButtonFormField<String>(
                                                                              value: roleController.text.isNotEmpty ? roleController.text : null,
                                                                              items: [
                                                                                'ผู้ดูแลระบบ',
                                                                                'พนักงาน',
                                                                                'แพทย์',
                                                                                'ญาติ'
                                                                              ].map((role) {
                                                                                return DropdownMenuItem(
                                                                                  value: role,
                                                                                  child: Text(role),
                                                                                );
                                                                              }).toList(),
                                                                              onChanged: (value) {
                                                                                roleController.text = value!;
                                                                              },
                                                                              decoration: const InputDecoration(
                                                                                labelText: 'ตำแหน่งงาน',
                                                                                border: UnderlineInputBorder(),
                                                                              ),
                                                                              validator: (value) {
                                                                                if (value == null || value.trim().isEmpty) {
                                                                                  return 'กรุณาเลือก ตำแหน่งงาน';
                                                                                }
                                                                                return null;
                                                                              },
                                                                            ),

                                                                            const SizedBox(height: 8.0),

                                                                            // รหัสผ่านใหม่
                                                                            TextFormField(
                                                                              controller: passwordController,
                                                                              obscureText: dialogObscureText,
                                                                              decoration: InputDecoration(
                                                                                labelText: 'รหัสผ่านใหม่',
                                                                                hintText: 'ใส่รหัสผ่านใหม่',
                                                                                suffixIcon: IconButton(
                                                                                  icon: Icon(
                                                                                    dialogObscureText ? Icons.visibility_off : Icons.visibility,
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    setDialogState(() {
                                                                                      dialogObscureText = !dialogObscureText;
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              validator: (value) {
                                                                                if (value == null || value.trim().isEmpty) {
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
                                                                              controller: confirmPasswordController,
                                                                              obscureText: dialogConfirmObscureText,
                                                                              decoration: InputDecoration(
                                                                                labelText: 'ยืนยันรหัสผ่านใหม่',
                                                                                hintText: 'ใส่รหัสผ่านใหม่อีกครั้ง',
                                                                                suffixIcon: IconButton(
                                                                                  icon: Icon(
                                                                                    dialogConfirmObscureText ? Icons.visibility_off : Icons.visibility,
                                                                                  ),
                                                                                  onPressed: () {
                                                                                    setDialogState(() {
                                                                                      dialogConfirmObscureText = !dialogConfirmObscureText;
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              validator: (value) {
                                                                                if (value == null || value.trim().isEmpty) {
                                                                                  return null; // ไม่จำเป็นต้องกรอกเบอร์โทรศัพท์
                                                                                }
                                                                                if (value != passwordController.text) {
                                                                                  return 'รหัสผ่านไม่ตรงกัน';
                                                                                }
                                                                                return null;
                                                                              },
                                                                            ),
                                                                            TextFormField(
                                                                              controller: telController,
                                                                              decoration: const InputDecoration(
                                                                                labelText: 'เบอร์โทรศัพท์',
                                                                                hintText: 'ใส่เบอร์โทรศัพท์',
                                                                                border: UnderlineInputBorder(),
                                                                              ),
                                                                              keyboardType: TextInputType.phone, // ตั้งค่าให้คีย์บอร์ดเป็นแบบเบอร์โทร
                                                                              validator: (value) {
                                                                                if (value == null || value.trim().isEmpty) {
                                                                                  return null; // ไม่จำเป็นต้องกรอกเบอร์โทรศัพท์
                                                                                }
                                                                                // ตรวจสอบว่าเป็นเบอร์โทรศัพท์จริง (10 หลักและเริ่มต้นด้วย 0)
                                                                                final RegExp telRegex = RegExp(r'^0[0-9]{9}$');
                                                                                if (!telRegex.hasMatch(value.trim())) {
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
                                                                          child:
                                                                              const Text('ยกเลิก'),
                                                                          onPressed: () =>
                                                                              Navigator.of(context).pop(),
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              const Text('บันทึก'),
                                                                          onPressed:
                                                                              () {
                                                                            // ตรวจสอบว่าฟอร์มถูกต้องหรือไม่
                                                                            if (formKey.currentState!.validate()) {
                                                                              editUser(user['id']);
                                                                              Navigator.of(context).pop();
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
                                                        ),
                                                        IconButton(
                                                          color: Colors.red,
                                                          icon: const Icon(
                                                              Icons.delete),
                                                          onPressed: () async {
                                                            // แสดงกล่องยืนยันการลบ
                                                            bool isConfirmed =
                                                                await showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'ยืนยันการลบ'),
                                                                  content: Text(
                                                                      'คุณแน่ใจว่าต้องการลบผู้ใช้นี้?'),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(false); // ผู้ใช้กด "ยกเลิก"
                                                                      },
                                                                      child: Text(
                                                                          'ยกเลิก'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(true); // ผู้ใช้กด "ยืนยัน"
                                                                      },
                                                                      child: Text(
                                                                          'ยืนยัน'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );

                                                            // ถ้าผู้ใช้ยืนยันการลบ
                                                            if (isConfirmed ==
                                                                true) {
                                                              deleteUser(
                                                                  user['id']);
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : // DataTable ที่กรองตามตำแหน่งงาน
                                Expanded(
                                    child: ListView(
                                      children: [
                                        DataTable(
                                          columns: const [
                                            DataColumn(
                                                label: Text('ชื่อ - นามสกุล',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            DataColumn(
                                                label: Text('ชื่อผู้ใช้งาน',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            DataColumn(
                                                label: Text('ตำแหน่ง',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            DataColumn(
                                                label: Text('เบอร์โทรศัพท์',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            DataColumn(
                                                label: Text('     จัดการ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ],
                                          rows: users.where((user) {
                                            // กรองผู้ใช้ตามตำแหน่งงาน
                                            return selectedRole == 'ทั้งหมด' ||
                                                user['role'] == selectedRole;
                                          }).map((user) {
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(
                                                    user['name'] ?? 'No Name')),
                                                DataCell(Text(user['email'] ??
                                                    'No Email')),
                                                DataCell(Text(
                                                    user['role'] ?? 'No Role')),
                                                DataCell(Text(
                                                    user['tel'] ?? 'No Role')),
                                                DataCell(
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          color: bottoncolor,
                                                        ),
                                                        onPressed: () {
                                                          nameController.text =
                                                              user['name'];
                                                          emailController.text =
                                                              user['email'];
                                                          roleController.text =
                                                              user['role'];
                                                          passwordController
                                                                  .text =
                                                              ""; // ตั้งค่าเริ่มต้นให้เป็นค่าว่าง
                                                          TextEditingController
                                                              confirmPasswordController =
                                                              TextEditingController(); // เพิ่ม controller สำหรับยืนยันรหัสผ่าน

                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              bool
                                                                  dialogObscureText =
                                                                  _obscureText; // ใช้ตัวแปรแยกใน dialog
                                                              bool
                                                                  dialogConfirmObscureText =
                                                                  _obscureText; // ใช้สำหรับ confirm password
                                                              return StatefulBuilder(
                                                                builder: (context,
                                                                    setDialogState) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'แก้ไขผู้ใช้งาน'),
                                                                    content:
                                                                        Form(
                                                                      key:
                                                                          formKey,
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          // ชื่อผู้ใช้งาน
                                                                          TextFormField(
                                                                            controller:
                                                                                nameController,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              labelText: 'ชื่อ - นามสกุล',
                                                                              hintText: 'ใส่ชื่อ - นามสกุล',
                                                                              border: UnderlineInputBorder(),
                                                                            ),
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.trim().isEmpty) {
                                                                                return 'กรุณาใส่ชื่อ - นามสกุล';
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),

                                                                          const SizedBox(
                                                                              height: 8.0),

                                                                          // อีเมลผู้ใช้งาน
                                                                          TextFormField(
                                                                            controller:
                                                                                emailController,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              labelText: 'ชื่อผู้ใช้งาน',
                                                                              hintText: 'ใส่ชื่อผู้ใช้งาน',
                                                                              border: UnderlineInputBorder(),
                                                                            ),
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.trim().isEmpty) {
                                                                                return 'กรุณาใส่ชื่อผู้ใช้งาน';
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),

                                                                          const SizedBox(
                                                                              height: 8.0),

                                                                          // ตำแหน่งงานผู้ใช้งาน
                                                                          DropdownButtonFormField<
                                                                              String>(
                                                                            value: roleController.text.isNotEmpty
                                                                                ? roleController.text
                                                                                : null,
                                                                            items:
                                                                                [
                                                                              'ผู้ดูแลระบบ',
                                                                              'พนักงาน',
                                                                              'แพทย์',
                                                                              'ญาติ'
                                                                            ].map((role) {
                                                                              return DropdownMenuItem(
                                                                                value: role,
                                                                                child: Text(role),
                                                                              );
                                                                            }).toList(),
                                                                            onChanged:
                                                                                (value) {
                                                                              roleController.text = value!;
                                                                            },
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              labelText: 'ตำแหน่งงาน',
                                                                              border: UnderlineInputBorder(),
                                                                            ),
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.trim().isEmpty) {
                                                                                return 'กรุณาเลือก ตำแหน่งงาน';
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),

                                                                          const SizedBox(
                                                                              height: 8.0),

                                                                          // รหัสผ่านใหม่
                                                                          TextFormField(
                                                                            controller:
                                                                                passwordController,
                                                                            obscureText:
                                                                                dialogObscureText,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              labelText: 'รหัสผ่านใหม่',
                                                                              hintText: 'ใส่รหัสผ่านใหม่',
                                                                              suffixIcon: IconButton(
                                                                                icon: Icon(
                                                                                  dialogObscureText ? Icons.visibility_off : Icons.visibility,
                                                                                ),
                                                                                onPressed: () {
                                                                                  setDialogState(() {
                                                                                    dialogObscureText = !dialogObscureText;
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ),
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.trim().isEmpty) {
                                                                                return null; // ไม่จำเป็นต้องกรอกเบอร์โทรศัพท์
                                                                              }
                                                                              if (value.length < 6) {
                                                                                return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),

                                                                          const SizedBox(
                                                                              height: 8.0),
                                                                          TextFormField(
                                                                            controller:
                                                                                confirmPasswordController,
                                                                            obscureText:
                                                                                dialogConfirmObscureText,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              labelText: 'ยืนยันรหัสผ่านใหม่',
                                                                              hintText: 'ใส่รหัสผ่านใหม่อีกครั้ง',
                                                                              suffixIcon: IconButton(
                                                                                icon: Icon(
                                                                                  dialogConfirmObscureText ? Icons.visibility_off : Icons.visibility,
                                                                                ),
                                                                                onPressed: () {
                                                                                  setDialogState(() {
                                                                                    dialogConfirmObscureText = !dialogConfirmObscureText;
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ),
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.trim().isEmpty) {
                                                                                return null; // ไม่จำเป็นต้องกรอกเบอร์โทรศัพท์
                                                                              }
                                                                              if (value != passwordController.text) {
                                                                                return 'รหัสผ่านไม่ตรงกัน';
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),
                                                                          TextFormField(
                                                                            controller:
                                                                                telController,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              labelText: 'เบอร์โทรศัพท์',
                                                                              hintText: 'ใส่เบอร์โทรศัพท์',
                                                                              border: UnderlineInputBorder(),
                                                                            ),
                                                                            keyboardType:
                                                                                TextInputType.phone, // ตั้งค่าให้คีย์บอร์ดเป็นแบบเบอร์โทร
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.trim().isEmpty) {
                                                                                return null; // ไม่จำเป็นต้องกรอกเบอร์โทรศัพท์
                                                                              }
                                                                              // ตรวจสอบว่าเป็นเบอร์โทรศัพท์จริง (10 หลักและเริ่มต้นด้วย 0)
                                                                              final RegExp telRegex = RegExp(r'^0[0-9]{9}$');
                                                                              if (!telRegex.hasMatch(value.trim())) {
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
                                                                        child: const Text(
                                                                            'ยกเลิก'),
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.of(context).pop(),
                                                                      ),
                                                                      TextButton(
                                                                        child: const Text(
                                                                            'บันทึก'),
                                                                        onPressed:
                                                                            () {
                                                                          // ตรวจสอบว่าฟอร์มถูกต้องหรือไม่
                                                                          if (formKey
                                                                              .currentState!
                                                                              .validate()) {
                                                                            editUser(user['id']);
                                                                            Navigator.of(context).pop();
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
                                                      ),
                                                      IconButton(
                                                        color: Colors.red,
                                                        icon: const Icon(
                                                            Icons.delete),
                                                        onPressed: () async {
                                                          // แสดงกล่องยืนยันการลบ
                                                          bool isConfirmed =
                                                              await showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    'ยืนยันการลบ'),
                                                                content: Text(
                                                                    'คุณแน่ใจว่าต้องการลบผู้ใช้นี้?'),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              false); // ผู้ใช้กด "ยกเลิก"
                                                                    },
                                                                    child: Text(
                                                                        'ยกเลิก'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true); // ผู้ใช้กด "ยืนยัน"
                                                                    },
                                                                    child: Text(
                                                                        'ยืนยัน'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );

                                                          // ถ้าผู้ใช้ยืนยันการลบ
                                                          if (isConfirmed ==
                                                              true) {
                                                            deleteUser(
                                                                user['id']);
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          // Add User Form
                          Container(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              onPressed:
                                  openAddUserForm, // เปิด Dialog เมื่อกดปุ่ม
                              backgroundColor: bottoncolor, // สีพื้นหลัง
                              child: const Icon(
                                Icons.add, // ไอคอนเครื่องหมาย "+"
                                color: Colors.white,
                              ),
                              tooltip:
                                  'เพิ่มผู้ใช้', // ข้อความแสดงเมื่อวางเมาส์ (Desktop)
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
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(), // ไม่ต้องส่งชื่อผ่าน constructor
      ),
    );
  }
}
