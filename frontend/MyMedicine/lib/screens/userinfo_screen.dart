import 'package:flutter/material.dart';
import 'package:medicineapp/screens/presc_list_screen.dart';
// import 'package:medicineapp/screens/signup_screen.dart';
import 'package:medicineapp/services/api_services.dart';
import 'package:medicineapp/models/user_model.dart';
import 'package:medicineapp/widgets/toast.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class UserInfoScreen extends StatefulWidget {
  final int uid;
  final Function func;

  UserInfoScreen({
    Key? key,
    required this.uid,
    required this.func,
  }) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  late Future<UserModel> _userInfoFuture;
  final ApiService _apiService = ApiService();
  List<String> selectedAllergies = [];
  List<String> allAllergies = [
    "페니실린계 항생제",
    "세팔로스포린계 항생제",
    "퀴놀론계 항생제",
    "소염진통제",
    "집먼지진드기",
    "계란",
    "우유",
    "복숭아",
    "견과류",
    "꽃가루",
  ];

  @override
  void initState() {
    super.initState();
    _refreshUserInfo();
  }

  Future<void> _refreshUserInfo() async {
    _userInfoFuture = _apiService.getUserInfo(widget.uid);
    setState(() {});
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
                "마이페이지",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white, size: 32),
                onPressed: _refreshUserInfo,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
        elevation: 5,
        shadowColor: Colors.grey[300],
      ),
      body: FutureBuilder<UserModel>(
        future: _userInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '   ${user.name}',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            _showPersonalInfoDialog(
                              context,
                              user.uID,
                              user.allergic,
                              user.name,
                              user.birthDate,
                              user.gender,
                              user.height,
                              user.weight,
                            );
                            saveInput();
                          },
                          child: Icon(Icons.edit,
                              color: Color.fromARGB(255, 129, 0, 141),
                              size: 25),
                        ),
                      ]),
                  const Divider(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('   생년월일\n\n   성별\n\n   키/체중'),
                        Text(
                          '   ${user.birthDate}\n\n   ${user.gender}\n\n   ${user.height}cm/${user.weight}kg',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ]),
                  const Divider(),
                  Row(children: [
                    Text(
                      '  알러지 정보',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        _showAllergiesDialog(
                          context,
                          user.uID,
                          user.allergic,
                          user.name,
                          user.birthDate,
                          user.gender,
                          user.height,
                          user.weight,
                        );
                        saveInput();
                      },
                      child: Icon(Icons.edit,
                          color: Color.fromARGB(255, 129, 0, 141), size: 25),
                    ),
                  ]),
                  SizedBox(height: 10),
                  Row(children: [
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: user.allergic.map((allergic) {
                        return Text(
                          '   ${allergic}',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
                  const Divider(),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         _showAllergiesDialog(context);
                  //         saveInput();
                  //       },
                  //       child: Text('알러지 재선택'),
                  //     ),
                  //     SizedBox(width: 10),
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         _showPersonalInfoDialog(context);
                  //       },
                  //       child: Text('회원정보 재입력'),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 10),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     edit(
                  //         context,
                  //         user.uID,
                  //         selectedAllergies,
                  //         user.name,
                  //         user.birthDate,
                  //         user.gender,
                  //         user.height,
                  //         user.weight);
                  //   },
                  //   child: Text('정보수정'),
                  // ),
                  // ],
                  // ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  //정보수정
  void edit(
    BuildContext context,
    int uid,
    List<String> userAllergic,
    String uname,
    String ubirthDate,
    String ugender,
    double uheight,
    double uweight,
  ) async {
    String name = nameController.text.isEmpty ? uname : nameController.text;
    String birthDate = birthDateController.text.isEmpty
        ? ubirthDate
        : birthDateController.text;
    String gender =
        genderController.text.isEmpty ? ugender : genderController.text;
    double height = heightController.text.isEmpty
        ? uheight
        : double.parse(heightController.text);
    double weight = weightController.text.isEmpty
        ? uweight
        : double.parse(weightController.text);
    int status;
    if (selectedAllergies.isEmpty) {
      status = await _apiService.edituser(
          uid, userAllergic, name, birthDate, gender, height, weight);
    } else {
      status = await _apiService.edituser(
          uid, selectedAllergies, name, birthDate, gender, height, weight);
    }
    if (status == 200) {
      showToast("회원정보가 수정되었습니다.");
    } else {
      showToast("정보 수정에 실패하였습니다.");
    }
    if (mounted) {
      // setState(() {});
      _refreshUserInfo();
    }
  }

  void _showAllergiesDialog(
    BuildContext context,
    int uid,
    List<String> userAllergic,
    String name,
    String birthDate,
    String gender,
    double height,
    double weight,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AllergySelectionDialog(
          allAllergies: allAllergies,
          selectedAllergies: selectedAllergies,
          onSelectionChanged: (selection) {
            if (mounted) {
              setState(() {
                selectedAllergies = selection;
              });
            }
          },
          editCallback: () {
            edit(
              context,
              uid,
              userAllergic,
              name,
              birthDate,
              gender,
              height,
              weight,
            );
          },
        );
      },
    );
  }

  void _showPersonalInfoDialog(
    BuildContext context,
    int uid,
    List<String> userAllergic,
    String name,
    String birthDate,
    String gender,
    double height,
    double weight,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원정보 입력'),
          content: SingleChildScrollView(
            // Wrap with SingleChildScrollView
            child: Container(
              height: 350,
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '이름',
                      hintText: '홍길동',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '생년월일',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(birthDateController.text),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: genderController.text.isEmpty
                        ? null
                        : genderController.text,
                    items: ['남', '여'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (mounted) {
                        setState(() {
                          genderController.text = value ?? '';
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: '성별',
                    ),
                  ),
                  TextField(
                    controller: heightController,
                    decoration: InputDecoration(
                      labelText: '키(cm)',
                      hintText: '180',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  TextField(
                    controller: weightController,
                    decoration: InputDecoration(
                      labelText: '체중(kg)',
                      hintText: '90',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                edit(
                  context,
                  uid,
                  userAllergic,
                  name,
                  birthDate,
                  gender,
                  height,
                  weight,
                );
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        String month =
            picked.month < 10 ? '0${picked.month}' : '${picked.month}';
        String day = picked.day < 10 ? '0${picked.day}' : '${picked.day}';
        birthDateController.text = "${picked.year}-$month-$day";
      });
    }
  }

  TextEditingController otherAllergyController = TextEditingController();

  void saveInput() {
    String? otherAllergy = otherAllergyController.text;
    if (otherAllergy != null && otherAllergy.isNotEmpty) {
      selectedAllergies.add(otherAllergy);
    }
  }
}

class AllergySelectionDialog extends StatefulWidget {
  final List<String> allAllergies;
  final List<String> selectedAllergies;
  final ValueChanged<List<String>> onSelectionChanged;
  final Function editCallback;

  AllergySelectionDialog({
    required this.allAllergies,
    required this.selectedAllergies,
    required this.onSelectionChanged,
    required this.editCallback,
  });

  @override
  _AllergySelectionDialogState createState() => _AllergySelectionDialogState();
}

class _AllergySelectionDialogState extends State<AllergySelectionDialog> {
  List<String> _tempSelectedAllergies = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedAllergies = List.from(widget.selectedAllergies);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('알러지를 선택하세요'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allAllergies.length,
          itemBuilder: (context, index) {
            final allergy = widget.allAllergies[index];
            return CheckboxListTile(
              title: Text(allergy),
              value: _tempSelectedAllergies.contains(allergy),
              onChanged: (bool? value) {
                setState(() {
                  if (value != null) {
                    if (value) {
                      _tempSelectedAllergies.add(allergy);
                    } else {
                      _tempSelectedAllergies.remove(allergy);
                    }
                  }
                });
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSelectionChanged(_tempSelectedAllergies);
            widget.editCallback();
            Navigator.of(context).pop();
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}
