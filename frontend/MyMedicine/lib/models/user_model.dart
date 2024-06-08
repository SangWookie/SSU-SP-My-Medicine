// class UserModel {
//   final int uid;
//   final String name, allergies;
//   final List<int> prescIdList;

//   UserModel(
//     this.name, {
//     required this.uid,
//     required this.prescIdList,
//     required this.allergies,
//   });

//   UserModel.fromJson(Map<String, dynamic> json)
//       : uid = json['uid'],
//         name = json['name'],
//         prescIdList = json['prescIdList'],
//         allergies = json['allergic'];
// }
class UserModel {
  final int uID;
  final String name;
  final List<AllergicInfo> allergic;

  UserModel({
    required this.uID,
    required this.name,
    required this.allergic,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse the allergic data
    List<dynamic> allergicData = json['allergic'] ?? [];
    List<AllergicInfo> allergicList = allergicData
        .map((e) => AllergicInfo.fromJson(e))
        .toList(); // Map each item to AllergicInfo object

    return UserModel(
      uID: json['uID'] ?? 0,
      name: json['name'] ?? "",
      allergic: allergicList,
    );
  }
}

class AllergicInfo {
  final int aID;
  final String info;

  AllergicInfo({
    required this.aID,
    required this.info,
  });

  factory AllergicInfo.fromJson(Map<String, dynamic> json) {
    return AllergicInfo(
      aID: json['aID'] ?? 0,
      info: json['info'] ?? "",
    );
  }
}
