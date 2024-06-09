import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicineapp/screens/presc_list_screen.dart';
import 'package:medicineapp/services/api_services.dart';
import 'package:medicineapp/widgets/toast.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:medicineapp/screens/home_screen.dart';

class PrescUploadScreen extends StatefulWidget {
  final int uid;
  Function func;

  PrescUploadScreen({
    Key? key,
    required this.uid,
    required this.func,
  });

  final ApiService apiService = ApiService();

  @override
  State<PrescUploadScreen> createState() => _PrescUploadScreenState();
}

class _PrescUploadScreenState extends State<PrescUploadScreen> {
  final List<TextEditingController> _controllers = [];
  final _prescDaysController = TextEditingController();
  final _regYearController = TextEditingController();
  final _regMonthController = TextEditingController();
  final _regDateController = TextEditingController();

  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _controllers.add(TextEditingController());
    }
  }

  void _addTile() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeTile(int index) {
    setState(() {
      _controllers.removeAt(index - 1);
    });
  }

  String _fetchMedicineList() {
    String medicineList = "";
    for (int i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text.isEmpty) {
        continue;
      } else {
        if (i > 0) {
          medicineList += ", ";
        }
        medicineList += _controllers[i].text;
      }
    }
    log("/presc_upload_screen: medicineList: $medicineList");
    return medicineList;
  }

  void _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      setState(() {
        _image = pickedFile;
      });
    } catch (e) {
      log("Image picking failed: $e");
      // 이미지를 다시 업로드하기 위해 재귀 호출
      _pickImage(); // 재귀 호출
    }
  }

  void validateAndSubmit(BuildContext context) async {
    String medicineList = _fetchMedicineList();

    bool isInteger(String value) {
      if (value == null) {
        return false;
      }
      final number = int.tryParse(value);
      return number != null;
    }

    if (_prescDaysController.text.isEmpty ||
        !isInteger(_prescDaysController.text)) {
      showToast("복용일수를 올바르게 입력해주세요");
      return;
    }
    if (_regYearController.text.isEmpty ||
        _regMonthController.text.isEmpty ||
        _regDateController.text.isEmpty ||
        !isInteger(_regYearController.text) ||
        !isInteger(_regMonthController.text) ||
        !isInteger(_regDateController.text)) {
      showToast("처방일자를 올바르게 입력해주세요");
      return;
    }
    if (medicineList.isEmpty) {
      showToast("약을 입력해주세요");
      return;
    }

    if (_image == null) {
      showToast("처방전 사진을 추가해주세요");
      return;
    }

    String prescriptionDate =
        "${_regYearController.text}-${_regMonthController.text.padLeft(2, '0')}-${_regDateController.text.padLeft(2, '0')}";

    int duration = int.parse(_prescDaysController.text);

    final uploadResult = await _uploadPresc(
      widget.uid,
      prescriptionDate,
      duration,
      medicineList,
      _image!,
    );

    if (uploadResult != -1) {
      showToast("처방전이 등록되었습니다.");
      //홈화면으로 나가기

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final homeScreen = context.findAncestorWidgetOfExactType<HomeScreen>();
        if (homeScreen != null) {
          homeScreen.setIndex(0, context);
        }
      });
      _clearInputs();
    } else {
      showToast("처방전 등록에 실패했습니다.");
    }
  }

  void _clearInputs() {
    _prescDaysController.clear();
    _regYearController.clear();
    _regMonthController.clear();
    _regDateController.clear();
    _controllers.forEach((controller) => controller.clear());
    setState(() {
      _image = null;
    });
  }

  Future<Uint8List> _resizeAndCompressImage(Uint8List imageBytes) async {
    // 이미지 디코딩
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // 이미지 크기 조정 (예: 최대 너비 800픽셀, 높이는 비율 유지)
    int maxWidth = 500;
    int newWidth = maxWidth;
    int newHeight = (maxWidth / image.width * image.height).round();
    img.Image resizedImage =
        img.copyResize(image, width: newWidth, height: newHeight);

    // 이미지 압축 (품질: 0-100, 100이 가장 높은 품질)
    int compressionQuality = 50;
    List<int> compressedBytes =
        img.encodeJpg(resizedImage, quality: compressionQuality);

    return Uint8List.fromList(compressedBytes);
  }

  Future<int> _uploadPresc(int uid, String prescriptionDate, int duration,
      String medList, XFile img) async {
    final imgBytes = await img.readAsBytes();

    final resizedImgBytes = await _resizeAndCompressImage(imgBytes);

    // API 호출을 위한 매개변수 설정
    final String formattedDate = prescriptionDate;
    final medListArray = medList.split(',').map((e) => e.trim()).toList();

    final pID = await widget.apiService.uploadImage(
      uid,
      formattedDate,
      duration,
      medListArray,
      imgBytes,
    );

    log("/presc_upload_screen: _uploadPresc(): pID: $pID");
    return pID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(
            left: 12,
            right: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "처방전 업로드",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
        elevation: 5,
        shadowColor: Colors.grey[300],
      ),
      body: Container(
        color: const Color(0xfff2f2ff),
        padding: const EdgeInsets.only(
          top: 25,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey[900],
                            size: 20,
                          ),
                          const SizedBox(width: 8, height: 1),
                          const Text(
                            "처방일자: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _regYearController,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'YYYY',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                                contentPadding:
                                    const EdgeInsets.only(bottom: 4),
                              ),
                            ),
                          ),
                          const Text(
                            "-",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            width: 25,
                            height: 30,
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _regMonthController,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'MM',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                                contentPadding:
                                    const EdgeInsets.only(bottom: 4),
                              ),
                            ),
                          ),
                          const Text(
                            "-",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            width: 25,
                            height: 30,
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _regDateController,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'DD',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                                contentPadding:
                                    const EdgeInsets.only(bottom: 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_alarm_outlined,
                          color: Colors.grey[900],
                          size: 20,
                        ),
                        const SizedBox(width: 8, height: 1),
                        const Text(
                          "복용일수: ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          width: 25,
                          height: 30,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _prescDaysController,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.bottom,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '7',
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              contentPadding: const EdgeInsets.only(bottom: 4),
                            ),
                          ),
                        ),
                        const Text(
                          "일",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                  width: 1,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    bottom: MediaQuery.of(context).size.height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _controllers.length,
                          itemBuilder: (context, index) {
                            return MedInfoTile(
                              idx: index + 1,
                              controller: _controllers[index],
                              onRemove: _removeTile,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: _addTile,
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline,
                                    color: Colors.grey[600], size: 30),
                                const SizedBox(width: 4),
                                Text(
                                  "약 추가",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                  width: 1,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.22,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_image != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_image!.path),
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    color: Colors.grey[600], size: 30),
                                const SizedBox(height: 4),
                                Text(
                                  "처방전 사진 추가",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
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
                      backgroundColor: Colors.deepPurple[300],
                    ),
                    onPressed: () {
                      validateAndSubmit(context);
                    },
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 45),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _prescDaysController.dispose();
    _regYearController.dispose();
    _regMonthController.dispose();
    _regDateController.dispose();
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}

class MedInfoTile extends StatelessWidget {
  final int idx;
  final TextEditingController controller;
  Function onRemove;

  MedInfoTile({
    Key? key,
    required this.idx,
    required this.controller,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
      ),
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 5,
      horizontalTitleGap: 0,
      minLeadingWidth: 0,
      leading: Container(
        width: 10,
        height: 40,
        margin: const EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Center(
          child: Text(
            "$idx",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 220,
            height: 30,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.bottom,
              maxLines: 1,
              decoration: InputDecoration(
                isDense: true,
                hintText: '아스피린',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
                contentPadding: const EdgeInsets.only(bottom: 4),
              ),
            ),
          ),
          const SizedBox(
            width: 3,
          ),
          IconButton(
            onPressed: () => {
              onRemove(idx),
            },
            icon: Icon(
              Icons.delete_outline,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
