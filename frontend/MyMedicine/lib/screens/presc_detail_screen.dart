import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:medicineapp/main.dart';
import 'package:medicineapp/models/prescription_model.dart';
import 'package:medicineapp/screens/home_screen.dart';
import 'package:medicineapp/screens/presc_list_screen.dart';
import 'package:medicineapp/services/api_services.dart';
import 'package:medicineapp/widgets/toast.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class PrescDetailScreen extends StatefulWidget {
  final PrescModel prescModel;
  final int uid;
  final Function func;
  final VoidCallback onDeleted;

  const PrescDetailScreen({
    Key? key,
    required this.prescModel,
    required this.uid,
    required this.func,
    required this.onDeleted,
  }) : super(key: key);

  @override
  _PrescDetailScreenState createState() => _PrescDetailScreenState();
}

class _PrescDetailScreenState extends State<PrescDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _hasShownWarning = false;
  bool _isDeleting = false;
  ScaffoldMessengerState? _scaffoldMessengerState;
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownWarning) {
        _showWarningDialog(context);
        _hasShownWarning = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessengerState = ScaffoldMessenger.of(context);
  }

  Future<Uint8List> prescImage(int prescId) {
    return _apiService.getPrescPic(prescId);
  }

  void _showWarningDialog(BuildContext context) {
    if (context == null || _isDeleting) return;

    String warningMessage = '';
    if (widget.prescModel.duplicateMed != null &&
        widget.prescModel.duplicateMed!.isNotEmpty) {
      log("warning duplicated: ${widget.prescModel.duplicateMed}");
      log("warning prescId: ${widget.prescModel.prescId}");
      warningMessage += '/중복 복용 경고/\n';
      warningMessage += '${widget.prescModel.duplicateMed!.join(', ')}\n';
      warningMessage += '이 성분명의 약품을 중복 복용할 위험이 있습니다\n';
    }
    if (widget.prescModel.allergicMed != null &&
        widget.prescModel.allergicMed!.isNotEmpty) {
      warningMessage +=
          '/알러지 경고/\n ${widget.prescModel.allergicMed!.join(', ')} \n 이 성분명의 약품은 알러지 반응 위험이 있는 약품입니다';
    }
    if (warningMessage.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            margin: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.03,
                horizontal: MediaQuery.of(context).size.width * 0.07),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
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
                        " 경고 ",
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
                    children: [Text(warningMessage)],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _deletePrescription(
      BuildContext context, int prescriptionId) async {
    setState(() {
      _isDeleting = true;
    });
    try {
      await _apiService.deletePrescription(prescriptionId);
      // _scaffoldMessengerState?.showSnackBar(
      //   const SnackBar(
      //     content: Text('처방전이 성공적으로 삭제되었습니다.'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
      showToast("처방전이 성공적으로 삭제되었습니다.");
      widget.onDeleted();
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => HomeScreen(
      //       uid: widget.uid,
      //       func: widget.func,
      //     ),
      //   ),
      // );

      _homeNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            uid: widget.uid,
            func: widget.func,
          ),
        ),
      );
    } catch (e) {
      // _scaffoldMessengerState?.showSnackBar(
      //   const SnackBar(
      //     content: Text('처방전 삭제 중 오류가 발생했습니다.'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
      showToast("처방전 삭제 중 오류가 발생했습니다.");
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  void dispose() {
    _scaffoldMessengerState = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _homeNavigatorKey,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(bottom: 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10, height: 1),
              const Text('처방전 상세정보'),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("처방전 삭제"),
                            content: const Text("이 처방전을 삭제하시겠습니까?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("취소"),
                              ),
                              //처방건 삭제
                              TextButton(
                                onPressed: () {
                                  _deletePrescription(
                                      context, widget.prescModel.prescIdValue);
                                  Navigator.of(context).pop(context);
                                },
                                child: const Text("삭제"),
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
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.grey[300],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
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
                        Text(widget.prescModel.regDate,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                const Divider(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Text('처방기간: ${widget.prescModel.prescPeriodDays.toString()}일',
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
                      for (var i = 0;
                          i < widget.prescModel.medicineListLength;
                          i++)
                        Row(
                          children: [
                            Text(
                              widget.prescModel.medicineList[i],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text("  |  ${widget.prescModel.medcompList[i]}"),
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
                  child: FutureBuilder<Uint8List>(
                    future: ApiService()
                        .getPrescPic(widget.prescModel.prescIdValue),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('이미지를 불러오는데 오류가 발생했습니다.'));
                      } else if (snapshot.hasData) {
                        Uint8List? imageData = snapshot.data as Uint8List;
                        if (imageData != null && imageData.isNotEmpty) {
                          return Container(
                            width: 100,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.memory(
                              imageData,
                              fit: BoxFit.cover,
                            ),
                            // foregroundDecoration: BoxDecoration(
                            //   color: widget.prescModel.isExpired
                            //       ? Colors.grey[300]
                            //       : Colors.white,
                            //   backgroundBlendMode: BlendMode.darken,
                            // ),
                            // child: Image.memory(
                            //   snapshot.data!,
                            //   height: MediaQuery.of(context).size.height * 0.35,
                            //   fit: BoxFit.cover,
                            // ),
                          );
                        } else {
                          log('snapshot []');
                          return Text('No Image Available');
                        }
                      } else {
                        return Center(child: Text('이미지를 불러올 수 없습니다.'));
                      }
                    },
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
                                          color:
                                              Color.fromARGB(255, 222, 211, 0),
                                          size: 26),
                                      Text(
                                        " 주의 ",
                                        style: TextStyle(
                                          fontSize: 26,
                                          color:
                                              Color.fromARGB(255, 222, 211, 0),
                                        ),
                                      ),
                                      Icon(Icons.warning_amber_rounded,
                                          color:
                                              Color.fromARGB(255, 222, 211, 0),
                                          size: 26),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(widget
                                          .prescModel.generatedInstruction),
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
                    ),
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
