import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:medicineapp/models/prescription_list_model.dart';
import 'package:medicineapp/models/prescription_model.dart';
import 'package:medicineapp/models/user_model.dart';
import 'package:medicineapp/screens/presc_detail_screen.dart';
import 'package:medicineapp/screens/presc_list_screen.dart';
import 'package:medicineapp/services/api_services.dart';
import 'package:medicineapp/screens/home_screen.dart';

// ignore: must_be_immutable
class PrescWidget extends StatelessWidget {
  final int index, uid, prescId;
  final VoidCallback onDeleted; // onDeleted 매개변수 추가
  final Function func;

  PrescWidget({
    super.key,
    required this.index,
    required this.prescId,
    required this.uid,
    required this.onDeleted, // onDeleted 매개변수 추가
    required this.func,
  });

  final ApiService apiService = ApiService();
  late Future<PrescModel> prescInfo = apiService.getPrescInfo(prescId);

  @override
  Widget build(BuildContext context) {
    if (prescId == -1) {
      log("prescription_widget: data is null");
      return const Placeholder();
    } else {
      log("prescription_widget: ${prescId.toString()}");
    }

    return FutureBuilder(
      future: Future.wait([
        prescInfo,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          log("widget error: ${snapshot.error}");
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final prescModel = snapshot.data?[0] as PrescModel;
          prescModel.printPrescInfoOneline();
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: _BuildPrescWidget(
                prescId: prescId,
                context: context,
                prescModel: prescModel,
                onDeleted: onDeleted,
                uid: uid,
                func: func,
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: _BuildPrescWidget(
                prescId: prescId,
                context: context,
                prescModel: prescModel,
                onDeleted: onDeleted,
                uid: uid,
                func: func,
              ),
            );
          }
        }
      },
    );
  }
}

class _BuildPrescWidget extends StatelessWidget {
  final int prescId;
  final BuildContext context;
  final PrescModel prescModel;
  final VoidCallback onDeleted;
  final int uid;
  final Function func;

  const _BuildPrescWidget({
    // super.key,
    required this.context,
    required this.prescModel,
    required this.prescId,
    required this.onDeleted,
    required this.uid,
    required this.func,
  });

  // void _refreshData() {
  //   // 이전 페이지로 돌아간 후 새로고침
  //   Navigator.of(context).pushReplacement(MaterialPageRoute(
  //     builder: (BuildContext context) => PrescListScreen(uid: uid, func: func),
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    log("is_expired: ${prescModel.isExpired}");
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrescDetailScreen(
              uid: uid,
              prescModel: prescModel,
              onDeleted: () {
                Navigator.of(context).pop(context);
                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //   builder: (BuildContext context) =>
                //       PrescListScreen(uid: uid, func: func),
                // ));
                // _refreshData();
                onDeleted();
              },
              func: func,
            ),
          ),
        );
      },
      child: Hero(
        tag: prescId,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: (BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
              ),
            ],
            color: prescModel.isExpired ? Colors.grey[350] : Colors.white,
          )),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('처방일자: ${prescModel.regDate.toString()}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('복용기간: ${prescModel.prescPeriodDays.toString()}일',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < prescModel.medicineListLength; i++)
                        Text(
                          prescModel.medicineList[i],
                        ),
                    ],
                  ),
                  FutureBuilder(
                    // future: ApiService().getPrescPic(prescId),
                    future: _getEditedImage(prescId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        Uint8List? imageData = snapshot.data as Uint8List?;
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
                          );
                        } else {
                          log('snapshot []');
                          return Text('No Image Available');
                        }
                      } else {
                        return Text('No Image Available');
                      }
                    },
                  ),
                  // Container(
                  //     width: 100,
                  //     clipBehavior: Clip.hardEdge,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Container(
                  //       foregroundDecoration: BoxDecoration(
                  //         color: prescModel.isExpired
                  //             ? Colors.grey[400]
                  //             : Colors.white,
                  //         backgroundBlendMode: BlendMode.darken,
                  //       ),
                  //       child: Image(
                  //         image: NetworkImage(
                  //           prescImage,
                  //         ),
                  //       ),
                  //     )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> _getEditedImage(int prescId) async {
    // Define the delay duration (e.g., 1 second)
    const delayDuration = Duration(milliseconds: 300);

    // Wait for the delay duration before fetching the image
    await Future.delayed(delayDuration);

    // Fetch the image from the server
    return await ApiService().getPrescPic(prescId);
  }
}
