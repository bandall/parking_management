import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parking_management/api/parking_api.dart';
import 'package:parking_management/key_pad.dart';
import 'package:parking_management/manage_page.dart';
import 'package:parking_management/popup/assets.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    setSession();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void setSession() async {
    try {
      await dotenv.load(fileName: ".env");
      await ParkingApi().idpwLogin();
    } on Exception catch (e) {
      Assets().showPopupAutoPop(context, '로그인에 실패했습니다. $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '주차 등록'),
              Tab(text: '차량 목록'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            FourDigitNumberPad(),
            CarInfoTablePage(),
          ],
        ),
      ),
    );
  }
}
