import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:medicineapp/models/prescription_model.dart';
import 'package:medicineapp/services/api_services.dart';
// import 'package:medicineapp/widgets/bottom_modal_sheet.dart';

class PrescDetailScreen extends StatelessWidget {
  // final int uid, prescId;
  final PrescModel prescModel;
  final ApiService _apiService = ApiService();
  PrescDetailScreen({
    super.key,
    // required this.uid,
    // required this.prescId,
    required this.prescModel,
  });

  final List<String> randomTexts = [
    '항히스타민제',
    '세균감염증치료제',
    '위점막보호제',
    '알러지 치료제',
    '소염진통제',
    '알러지 치료제',
    '위산억제제',
    '세균감염증 치료제',
    '위점막보호제',
    '비스테로이드성소염제'
  ];

  String _getPrescPicLink(int prescId) {
    String url = "http://43.200.168.39:8080/getPrescPic?pID=$prescId";
    log("getPrescPicLink: $url");

    return url;
  }

/////////////////////////////////////////////////////
  // 삭제 함수 정의
  Future<void> _deletePrescription(
      BuildContext context, int prescriptionId) async {
    try {
      await _apiService.deletePrescription(prescriptionId);
      // 성공적으로 삭제되면 알림을 띄웁니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('처방전이 성공적으로 삭제되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      // 삭제 후 화면을 갱신할 수 있는 로직을 추가할 수 있습니다.
    } catch (e) {
      // 실패 시 에러 메시지를 띄웁니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('처방전 삭제 중 오류가 발생했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

///////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(
            bottom: 1,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10, height: 1), // for centering text
              const Text('처방전 상세정보'),
              Row(
                children: [
                  //Icon(Icons.edit, color: Colors.grey[700], size: 30),
                  //const SizedBox(width: 3, height: 1),
                  //Icon(Icons.delete_rounded, color: Colors.grey[700], size: 30),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("처방전 삭제"),
                            content: Text("이 처방전을 삭제하시겠습니까?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("취소"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deletePrescription(
                                      context, prescModel.prescIdValue);
                                  Navigator.of(context).pop();
                                },
                                child: Text("삭제"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(Icons.delete_rounded,
                        color: Colors.grey[700], size: 30),
                  ),
                ],
              )
            ],
          ),
        ),
        // backgroundColor: Colors.grey[100],
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.grey[300],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.only(
          top: 25,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            color: Colors.grey[700], size: 22),
                        const SizedBox(width: 5, height: 1),
                        Text(prescModel.regDate,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     Icon(Icons.place_outlined,
                    //         color: Colors.grey[700], size: 25),
                    //     const SizedBox(width: 3, height: 1),
                    //     const Text("하나로병원",
                    //         style: TextStyle(
                    //             fontSize: 14, fontWeight: FontWeight.w500)),
                    //   ],
                    // )
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                const Divider(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                // Text('처방전번호: ${prescModel.prescId.toString()}',
                //     style: const TextStyle(
                //         fontSize: 16, fontWeight: FontWeight.w500)),
                Text('처방기간: ${prescModel.prescPeriodDays.toString()}일',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                const Divider(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Container(
                  padding:
                      const EdgeInsets.only(bottom: 5, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005),
                      for (var i = 0; i < prescModel.medicineListLength; i++)
                        Row(
                          children: [
                            Text(
                              prescModel.medicineList[i],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                                // "  |  ${randomTexts[math.Random().nextInt(randomTexts.length)]}"),
                                "  |  ${randomTexts[i]}"),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      color: prescModel.isExpired
                          ? Colors.grey[300]
                          : Colors.white,
                      backgroundBlendMode: BlendMode.darken,
                    ),
                    child: Image.network(
                      _getPrescPicLink(prescModel.prescIdValue),
                      height: MediaQuery.of(context).size.height * 0.35,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                  width: 1,
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        // minimumSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        backgroundColor: const Color(0xfffda2a0)),
                    onPressed: () {
                      log("Button pop");
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            margin: const EdgeInsets.only(
                              left: 25,
                              right: 25,
                              bottom: 40,
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.03,
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.07),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Color(0xffe66452), size: 26),
                                      Text(
                                        " 주의 ",
                                        style: TextStyle(
                                          fontSize: 26,
                                          color: Color(0xffe66452),
                                        ),
                                      ),
                                      Icon(Icons.warning_amber_rounded,
                                          color: Color(0xffe66452), size: 26),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(prescModel.generatedInstruction),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      '주의사항 보기',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ), // Change this to your desired button text
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
