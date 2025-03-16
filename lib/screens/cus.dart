import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/color_font.dart';
import '../constant/sidebar.dart';
import 'detail.dart';
import 'login.dart';
import '../constant/api.dart';

class Cus extends StatefulWidget {
  const Cus({Key? key}) : super(key: key);

  @override
  State<Cus> createState() => _HomepageWebState();
}

class _HomepageWebState extends State<Cus> {
  String? username;
  String? role;
  String searchText = '';

  bool isLoading = true;
  List<dynamic> reports = [];

  Future<List<dynamic>> allReport() async {
    var url = Api.report;
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์");
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

                  final seenNames = <String>{}; // ใช้เก็บค่าที่เจอแล้ว
                  final filteredData = snapshot.data!.where((item) {
                    final namec = item['namec'].toString().toLowerCase();
                    if (seenNames.contains(namec)) {
                      return false; // ถ้าเจอซ้ำให้ตัดออก
                    }
                    seenNames.add(namec); // เพิ่มเข้าไปใน Set
                    final matchesSearch = searchText.isEmpty ||
                        namec.contains(searchText.toLowerCase()) ||
                        item['telc']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item['addressc']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item['agec']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        item['rolec']
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase());
                    return matchesSearch;
                  }).toList();

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ทะเบียนลูกค้า",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Divider(thickness: 1.5),
                        const SizedBox(height: 16.0),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'พิมพ์คำค้นหา',
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
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final item = filteredData[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ชื่อผู้ใช้ + ไอคอน
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              color: bottoncolor, size: 28),
                                          const SizedBox(width: 8),
                                          Text(
                                            item['namec'] ?? 'ไม่มีชื่อ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(thickness: 1.0),
                                      const SizedBox(height: 5),

                                      // เบอร์โทร
                                      Row(
                                        children: [
                                          Text(
                                            'เบอร์โทร: ${item['telc'] ?? '-'}',
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),

                                      // ที่อยู่
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'ที่อยู่: ${item['addressc'] ?? '-'}',
                                              style: TextStyle(
                                                  color: Colors.black54),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // อายุ
                                      Row(
                                        children: [
                                          Text(
                                            'อายุ: ${item['agec'] ?? '-'} ปี',
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),

                                      // อาชีพ
                                      Row(
                                        children: [
                                          Text(
                                            'อาชีพ: ${item['rolec'] ?? 'ไม่ระบุ'}',
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
