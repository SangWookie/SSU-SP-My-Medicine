// class UserModel {
//   final int uID;
//   final List<String> allergic;

//   UserModel({
//     required this.uID,
//     required this.allergic,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     // Parse the allergic data
//     List<String> allergicData;
//     allergicData =
//         List<String>.from(json['allergic'].map((item) => item['info']));

//     return UserModel(
//       uID: json['uID'] ?? "",
//       allergic: allergicData,
//     );
//   }
// }

class AllergicInfo {
  final int aID;
  final String name;
  final String birthDate;
  final String gender;
  final double height;
  final double weight;
  final String info;

  AllergicInfo({
    required this.aID,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.height,
    required this.weight,
    required this.info,
  });

  factory AllergicInfo.fromJson(Map<String, dynamic> json) {
    return AllergicInfo(
      aID: json['aID'] ?? 0,
      name: json['nickname'] ?? "",
      birthDate: json['birthDate'] ?? "0001-01-01",
      gender: json['gender'] ?? "-",
      height: json['height'] ?? 0.0,
      weight: json['weight'] ?? 0.0,
      info: json['info'] ?? "",
    );
  }
}

class UserModel {
  final int uID;
  final String name;
  final String birthDate;
  final String gender;
  final double height;
  final double weight;
  final List<String> allergic;

  UserModel({
    required this.uID,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.height,
    required this.weight,
    required this.allergic,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse the allergic data
    List<String> allergicData;
    allergicData =
        List<String>.from(json['allergic'].map((item) => item['info']));

    return UserModel(
      uID: json['uID'] ?? 0,
      name: json['nickname'] ?? "",
      birthDate: json['birthDate'] ?? "0001-01-01",
      gender: json['gender'] ?? "-",
      height: json['height'] ?? 0.0,
      weight: json['weight'] ?? 0.0,
      allergic: allergicData,
    );
  }
}
