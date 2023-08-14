import 'package:flutter/material.dart';
import 'package:parking_management/data/car_info.dart';
import 'package:parking_management/data/db_helper.dart';
import 'package:parking_management/popup/assets.dart';

class CarInfoTablePage extends StatefulWidget {
  const CarInfoTablePage({Key? key}) : super(key: key);

  @override
  State<CarInfoTablePage> createState() => _CarInfoTablePageState();
}

class _CarInfoTablePageState extends State<CarInfoTablePage> {
  List<CarInfo> carInfos = [
    CarInfo(id: 0, carNumber: '테스트 데이터', date: DateTime.now(), isChecked: 0)
  ];

  String carNumberFilter = '';
  DateTime? startDate;
  TextEditingController carNumberController = TextEditingController();
  int unconfirmedCount = 0;
  int todayCount = 0;

  @override
  void initState() {
    setInitData();
    super.initState();
  }

  void setInitData() async {
    late List<CarInfo> fetchedCarInfos;
    try {
      fetchedCarInfos = await ParkingInfoDb()
          .getAllCarInfosByDate(DateTime.now().toString().substring(0, 10));
      setState(() {
        carInfos = fetchedCarInfos;
        unconfirmedCount = carInfos.where((info) => info.isChecked == 0).length;
        todayCount = fetchedCarInfos.length;
      });
    } catch (e) {
      Assets().showPopup(context, '데이터베이스 조회 중 오류가 발생했습니다.');
    }
  }

  void onSearch() async {
    late List<CarInfo> fetchedCarInfos;

    try {
      if (carNumberFilter != '' && startDate != null) {
        fetchedCarInfos = await ParkingInfoDb()
            .getAllCarInfosByCarNumberAndDate(
                carNumberFilter, startDate.toString().substring(0, 10));
      } else if (carNumberFilter != '') {
        fetchedCarInfos =
            await ParkingInfoDb().getAllCarInfosByCarNumber(carNumberFilter);
      } else if (startDate != null) {
        fetchedCarInfos = await ParkingInfoDb()
            .getAllCarInfosByDate(startDate.toString().substring(0, 10));
      } else {
        fetchedCarInfos = await ParkingInfoDb().getAllCarInfos();
      }

      setState(() {
        carInfos = fetchedCarInfos;
      });
    } catch (e) {
      debugPrint(e.toString());
      Assets().showPopup(context, '데이터베이스 조회 중 오류가 발생했습니다.');
    }
  }

  void resetFilter() async {
    setState(() {
      carNumberFilter = '';
      startDate = null;
      carNumberController.clear();
    });
  }

  void setTodayData() async {
    late List<CarInfo> fetchedCarInfos;
    try {
      fetchedCarInfos = await ParkingInfoDb()
          .getAllCarInfosByDate(DateTime.now().toString().substring(0, 10));

      setState(() {
        carInfos = fetchedCarInfos;
      });
    } catch (e) {
      debugPrint(e.toString());
      Assets().showPopup(context, '데이터베이스 조회 중 오류가 발생했습니다.');
    }
  }

  void onConfirm(int? id) async {
    late List<CarInfo> fetchedCarInfos;
    try {
      await ParkingInfoDb().updateConfirm(id, true);
      fetchedCarInfos = await ParkingInfoDb().getAllCarInfos();
    } catch (e) {
      Assets().showPopup(context, '데이터베이스 조회 중 오류가 발생했습니다.');
    }
    setState(() {
      carInfos = fetchedCarInfos;
      unconfirmedCount = carInfos.where((info) => info.isChecked == 0).length;
    });
  }

  void deleteRow(int? id) async {
    late List<CarInfo> fetchedCarInfos;
    try {
      await ParkingInfoDb().delete(id);
      fetchedCarInfos = await ParkingInfoDb().getAllCarInfos();
    } catch (e) {
      Assets().showPopup(context, '데이터베이스 조회 중 오류가 발생했습니다.');
    }
    setState(() {
      carInfos = fetchedCarInfos;
      unconfirmedCount = carInfos.where((info) => info.isChecked == 0).length;
    });
  }

  void onDelete(int? id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('이 데이터를 정말 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                deleteRow(id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(left: screenWidth * 0.04),
                      child: DataTable(
                        columns: [
                          DataColumn(
                              label: SizedBox(
                            width: screenWidth * 0.05,
                            child: Text(
                              'ID',
                              style: TextStyle(
                                  color: themeData.colorScheme.primary),
                            ),
                          )),
                          DataColumn(
                              label: SizedBox(
                            width: screenWidth * 0.1,
                            child: Text(
                              '차량 번호',
                              style: TextStyle(
                                  color: themeData.colorScheme.primary),
                            ),
                          )),
                          DataColumn(
                              label: SizedBox(
                            width: screenWidth * 0.18,
                            child: Text(
                              '날짜',
                              style: TextStyle(
                                  color: themeData.colorScheme.primary),
                            ),
                          )),
                          DataColumn(
                              label: SizedBox(
                            width: screenWidth * 0.05,
                            child: Text(
                              '확인',
                              style: TextStyle(
                                  color: themeData.colorScheme.primary),
                            ),
                          )),
                          DataColumn(
                              label: SizedBox(
                            width: screenWidth * 0.05,
                            child: Text(
                              '삭제',
                              style: TextStyle(
                                  color: themeData.colorScheme.primary),
                            ),
                          )),
                        ],
                        rows: carInfos.map((carInfo) {
                          return DataRow(cells: [
                            DataCell(Text(
                              carInfo.id.toString(),
                              style: const TextStyle(fontSize: 18),
                            )),
                            DataCell(Text(
                              carInfo.carNumber,
                              style: const TextStyle(fontSize: 18),
                            )),
                            DataCell(Text(
                              carInfo.date.toString().substring(0, 19),
                              style: const TextStyle(fontSize: 18),
                            )),
                            DataCell(
                              carInfo.isChecked == 1
                                  ? const Text(
                                      '   확인됨',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        onConfirm(carInfo.id);
                                      },
                                      child: const Text('확인'),
                                    ),
                            ),
                            DataCell(
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[400],
                                ),
                                onPressed: () {
                                  onDelete(carInfo.id);
                                },
                                child: const Text('삭제'),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1.0, thickness: 1.0),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: const Text('필터'),
                          trailing: IconButton(
                            icon: const Icon(Icons.filter_list_rounded),
                            onPressed: () {},
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: carNumberController,
                            decoration: const InputDecoration(
                              labelText: '차량 번호',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                carNumberFilter = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text(
                            '날짜',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            startDate == null
                                ? "선택해주세요"
                                : "${startDate!.year}년 ${startDate!.month}월 ${startDate!.day}일",
                          ),
                          onTap: () async {
                            final DateTime? selectedStart =
                                await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (selectedStart != null) {
                              setState(() {
                                startDate = selectedStart;
                              });
                            }
                          },
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  resetFilter();
                                },
                                child: const Text('필터 초기화'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  onSearch();
                                },
                                child: const Text('검색'),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setInitData();
                                },
                                child: const Text('모두 조회'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setTodayData();
                                },
                                child: const Text('오늘 데이터 조회'),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: Text(
                            '미확인 차량: $unconfirmedCount 대',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: Text(
                            '오늘 등록한 차량: $todayCount 대',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
