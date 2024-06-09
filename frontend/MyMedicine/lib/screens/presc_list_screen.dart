import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:medicineapp/models/prescription_list_model.dart';
import 'package:medicineapp/models/user_model.dart';
import 'package:medicineapp/screens/home_screen.dart';
import 'package:medicineapp/screens/login_screen.dart';
import 'package:medicineapp/ui_consts.dart';
import 'package:medicineapp/services/api_services.dart';
import 'package:medicineapp/widgets/prescription_widget.dart';
import 'package:restart_app/restart_app.dart';

class PrescListScreen extends StatefulWidget {
  final int uid;
  final Function func;

  PrescListScreen({
    super.key,
    required this.uid,
    required this.func,
  });

  @override
  State<PrescListScreen> createState() => _PrescListScreenState();
}

class _PrescListScreenState extends State<PrescListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    futureData = Future.wait([
      apiService.pingServer(),
      apiService.getPrescList(widget.uid),
    ]);
    setState(() {}); // 화면 갱신
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      fetchData();
    });
    return Scaffold(
      backgroundColor: const Color(0xfff2f2fe),
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(
            left: 12,
            right: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/logos/MM_logo_white.png',
                width: 110,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        fetchData();
                      });
                    },
                    icon: const Icon(Icons.refresh,
                        color: Colors.white, size: 32),
                  ),
                  // const Icon(Icons.notifications,
                  //     color: Colors.white, size: 32),
                  IconButton(
                    onPressed: () {
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => LoginScreen(
                      //       func: widget.func,
                      //     ),
                      //   ),
                      // );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("로그아웃"),
                            content: const Text("로그아웃 하시겠습니까?"),
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
                                  widget.func(context);
                                  Navigator.of(context).pop(context);
                                },
                                child: const Text("확인"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon:
                        const Icon(Icons.logout, color: Colors.white, size: 31),
                  ),
                ],
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
        elevation: 5,
        shadowColor: Colors.grey[300],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('처방전 정보가 없습니다.'),
                  );
                } else {
                  if (snapshot.data != null) {
                    if (snapshot.data![0] != 204) {
                      return const Center(
                        child: Text('Server status error'),
                      );
                    } else {
                      log("presc_list_screen: ${snapshot.data![1].toString()}");
                      log("presc_list_screen: ${snapshot.data![1].prescIdList.toString()}");
                      if (snapshot.data![1] == null ||
                          snapshot.data![1]!.prescIdList == null) {
                        return const Center(
                          child: Text('처방전 정보가 없습니다.'),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data![1].prescIdList.length,
                          itemBuilder: (context, index) {
                            int prescIndex = index;
                            log("presclist widget: ${snapshot.data![1].prescIdList[prescIndex]}");
                            return PrescWidget(
                              index: index,
                              uid: widget.uid,
                              prescId:
                                  snapshot.data![1].prescIdList[prescIndex],
                              onDeleted: fetchData,
                              func: widget.func,
                            );
                          },
                        );
                      }
                    }
                  } else {
                    return const Center(
                      child: Text('No data'),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
