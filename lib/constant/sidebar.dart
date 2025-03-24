import 'package:flutter/material.dart';
import 'package:hotel_web/constant/color_font.dart';

import 'package:hotel_web/screens/profile.dart';

import '../screens/add_report.dart';
import '../screens/cus.dart';
import '../screens/dashbord.dart';
import '../screens/manageusers.dart';
import '../screens/home.dart';

class Sidebar extends StatelessWidget {
  final String? username;
  final String? role;
  final Color bottonColor;
  final VoidCallback onLogout;

  const Sidebar({
    Key? key,
    required this.username,
    required this.role,
    required this.bottonColor,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bottonColor, // สีพื้นหลัง
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: Column(
                  children: [
                    Container(
                      width: 80, // ขนาดของรูปโปรไฟล์
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // รูปแบบวงกลม
                        image: const DecorationImage(
                          image: AssetImage('assets/img/runnerx.png'),
                          fit: BoxFit.cover, // ปรับรูปให้เต็มพื้นที่
                        ),
                        border: Border.all(
                          color: Colors.white, // ขอบสีขาว
                          width: 2, // ความหนาของขอบ
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      username ?? '', // แสดงเฉพาะชื่อ
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: FontWeight_.Fonts_T,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ตำแหน่ง : ${role ?? ''}', // แสดงตำแหน่ง
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("รายการติดตามลูกค้า",
                style: TextStyle(fontFamily: Font_.Fonts_T)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomepageWeb(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("เพิ่มรายละเอียด",
                style: TextStyle(fontFamily: Font_.Fonts_T)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddReport(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("ทะเบียนลูกค้า",
                style: TextStyle(fontFamily: Font_.Fonts_T)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Cus(),
                ),
              );
            },
          ),
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.border_color),
          //   title: const Text("เพิ่มประเภทการแจ้งซ่อม",
          //       style: TextStyle(fontFamily: Font_.Fonts_T)),
          //   onTap: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const AddType(),
          //       ),
          //     );
          //   },
          // ),
          const Divider(),
          // เงื่อนไขสำหรับการแสดงเมนูจัดการผู้ใช้งาน
          if (role == "ผู้ดูแลระบบ" || role == "พนักงาน") ...[
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("รายงานสรุป",
                  style: TextStyle(fontFamily: Font_.Fonts_T)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Dashbord(),
                  ),
                );
              },
            ),
            const Divider(),
          ],
          // เงื่อนไขสำหรับการแสดงเมนูจัดการผู้ใช้งาน
          if (role == "ผู้ดูแลระบบ") ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("จัดการผู้ใช้งาน",
                  style: TextStyle(fontFamily: Font_.Fonts_T)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageUsers(),
                  ),
                );
              },
            ),
            const Divider(),
          ],
          // เงื่อนไขสำหรับการแสดงเมนูจัดการผู้ใช้งาน
          if (role == "พนักงาน") ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("ข้อมูลส่วนตัว",
                  style: TextStyle(fontFamily: Font_.Fonts_T)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Profile(),
                  ),
                );
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("ออกจากระบบ",
                style: TextStyle(fontFamily: Font_.Fonts_T)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
