import 'package:flutter/material.dart';
import 'package:parking_management/car_discount.dart';
import 'package:parking_management/popup/assets.dart';
import 'package:provider/provider.dart';
import 'package:parking_management/provider/number_provider.dart';

class FourDigitNumberPad extends StatelessWidget {
  const FourDigitNumberPad({super.key});

  Future<void> onSubmit(BuildContext context) async {
    final carNumberProvider =
        Provider.of<NumberPadModel>(context, listen: false);
    try {
      String carNumber = carNumberProvider.input;
      if (carNumberProvider.input.length == 4) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CarDiscountPage(carNumber: carNumber)));
        carNumberProvider.clearNumber();
      } else {
        Assets().showPopupAutoPop(context, '차량 번호는 4자리로 입력해주세요.');
      }
    } catch (e) {
      Assets().showPopupAutoPop(context, '차량 조회에 실패했습니다.');
    }
  }

  // Future<void> onSubmit(BuildContext context) async {
  //   final carNumberProvider =
  //       Provider.of<NumberPadModel>(context, listen: false);
  //   try {
  //     if (carNumberProvider.input.length == 4) {
  //       CarInfo newInfo = CarInfo(
  //           id: null,
  //           carNumber: carNumberProvider.input,
  //           date: DateTime.now(),
  //           isChecked: 0);
  //       await ParkingInfoDb().insert(newInfo);
  //       Assets()
  //           .showPopup(context, '차량 번호 [${carNumberProvider.input}] 등록되었습니다.');
  //       carNumberProvider.clearNumber();
  //     } else {
  //       Assets().showPopup(context, '차량 번호는 4자리로 입력해주세요.');
  //     }
  //   } catch (e) {
  //     Assets().showPopup(context, '차량 등록에 실패했습니다.');
  //   }
  // }

  Widget _buildNumberButton(
      int number, NumberPadModel carNumberProvider, BuildContext context) {
    if (number >= 1 && number <= 9) {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => carNumberProvider.addNumber(number),
          child: Text(
            number.toString(),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (number == 10) {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => carNumberProvider.deleteNumber(),
          child: const Icon(
            Icons.arrow_back,
            size: 50,
          ),
        ),
      );
    } else if (number == 11) {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => carNumberProvider.addNumber(0),
          child: const Text(
            '0',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () async {
            await onSubmit(context);
          },
          child: const Text(
            '등록',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Widget _buildPinDisplayCard(BuildContext context, String digit) {
    double boxSize = MediaQuery.of(context).size.width * 0.1;
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue, width: 2), // 테두리 색상: 파란색
        borderRadius: BorderRadius.circular(8), // 모서리를 더 둥글게 변경 (선택 사항)
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
              fontSize: 80, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carNumberProvider = Provider.of<NumberPadModel>(context);
    var size = MediaQuery.of(context).size;
    final double screenHeight = (size.height - kToolbarHeight - 24) / 2;
    final double screenWidth = size.width;
    final paddedInput = carNumberProvider.input.padRight(4, ' ');
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: (size.height - kToolbarHeight - 24),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left input area
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '차량 번호를 입력해주세요.',
                    style: TextStyle(
                      fontSize: 35, // 글꼴 크기 변경
                      fontWeight: FontWeight.bold, // 글꼴 두께 변경
                      color: Colors.black, // 글꼴 색상 변경
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: paddedInput
                        .split('')
                        .map((digit) => _buildPinDisplayCard(context, digit))
                        .toList(),
                  ),
                ],
              ),
            ),
            // Right number pad area
            Expanded(
              child: Padding(
                // 추가: Padding 위젯
                padding:
                    EdgeInsets.only(top: (screenHeight) / 2.5), // 수정: 상단 패딩 추가
                child: GridView.count(
                  childAspectRatio: screenWidth / screenHeight / 2,
                  crossAxisCount: 3,
                  children: List.generate(12, (index) {
                    int number = index + 1;
                    return _buildNumberButton(
                        number, carNumberProvider, context);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
