import 'dart:developer';

class PrescModel {
  // DateTime date;
  final String regDate;
  final int prescPeriodDays;
  final List<String> medicineList;
  final List<String> medcompList;
  final List<String>? duplicateMed;
  final List<String>? allergicMed;
  final int prescId;
  final String generatedInstruction;

  PrescModel({
    required this.regDate,
    required this.prescPeriodDays,
    required this.medicineList,
    required this.medcompList,
    required this.duplicateMed,
    required this.allergicMed,
    required this.prescId,
    required this.generatedInstruction,
  });

  String get regDateString {
    // final year = regDate.substring(0, 4);
    // final month = regDate.substring(4, 6);
    // final day = regDate.substring(6, 8);
    // return "$year-$month-$day";
    return regDate;
  }

  // bool get isExpired {
  //   final now = DateTime.now();

  //   final year = this.regDate.substring(0, this.regDate.indexOf('-'));
  //   final month = this.regDate.substring(
  //       this.regDate.indexOf('-') + 1, this.regDate.lastIndexOf('-'));
  //   final day = this.regDate.substring(this.regDate.lastIndexOf('-') + 1);

  //   final regDate = DateTime(int.parse(year), int.parse(month), int.parse(day));

  //   final diff = now.difference(regDate).inDays;
  //   return diff > prescPeriodDays;
  // }
  bool get isExpired {
    final now = DateTime.now();
    final regDateParsed = DateTime.parse(regDate);
    final diff = now.difference(regDateParsed).inDays;
    return diff > prescPeriodDays;
  }

  int get medicineListLength => medicineList.length;
  int get prescIdValue => prescId;

  PrescModel.fromJson(Map<String, dynamic> json)
      : regDate = json['regDate'],
        prescPeriodDays = json['duration'],
        // medicineList = json['medicine'].toString().split(',').reversed.toList(),
        medicineList =
            List<String>.from(json['medicine'].map((item) => item['medName'])),
        medcompList =
            List<String>.from(json['medicine'].map((item) => item['medComp'])),
        duplicateMed = json['duplicateMed'] != null
            ? List<String>.from(
                json['duplicateMed'].map((item) => item.toString()))
            : null,
        allergicMed = json['allergicMed'] != null
            ? List<String>.from(
                json['allergicMed'].map((item) => item.toString()))
            : null,

        // medicineList =
        //     List<String>.from(json['medicine'].map((item) => item['medName'])),
        generatedInstruction = json['generatedInstruction'],
        prescId = json['pID'];

  void printPrescInfoOneline() {
    log("prescId: $prescId, date: $regDate, prescPeriodDays: $prescPeriodDays, medicineList: $medicineList");
  }
}
