import 'package:flutter/material.dart';
import 'package:medicineapp/services/api_services.dart';
import 'package:medicineapp/widgets/text_field_set.dart';

class AllergySelectionDialog extends StatefulWidget {
  final List<String> allAllergies;
  final List<String> selectedAllergies;
  final ValueChanged<List<String>> onSelectionChanged;

  AllergySelectionDialog({
    required this.allAllergies,
    required this.selectedAllergies,
    required this.onSelectionChanged,
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
            Navigator.of(context).pop();
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
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

  bool showOtherTextField = true;
  TextEditingController otherAllergyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFieldSet(
                    usernameController: usernameController,
                    passwordController: passwordController,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showPersonalInfoDialog(context);
                    },
                    child: Text('회원정보 입력'),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      _showAllergiesDialog(context);
                    },
                    child: Text('알러지 선택'),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 255, 255, 255)),
                        child: Text('뒤로가기'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          saveInput();
                          signUp(context);
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 255, 234, 234)),
                        child: Text('가입하기'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPersonalInfoDialog(BuildContext context) {
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
                      setState(() {
                        genderController.text = value ?? '';
                      });
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
    if (picked != null) {
      setState(() {
        String month =
            picked.month < 10 ? '0${picked.month}' : '${picked.month}';
        String day = picked.day < 10 ? '0${picked.day}' : '${picked.day}';
        birthDateController.text = "${picked.year}-$month-$day";
      });
    }
  }

  void _showAllergiesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AllergySelectionDialog(
          allAllergies: allAllergies,
          selectedAllergies: selectedAllergies,
          onSelectionChanged: (selection) {
            setState(() {
              selectedAllergies = selection;
            });
          },
        );
      },
    );
  }

  void saveInput() {
    String? otherAllergy = otherAllergyController.text;
    if (otherAllergy != null && otherAllergy.isNotEmpty) {
      selectedAllergies.add(otherAllergy);
    }
  }

  void signUp(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;
    String name = nameController.text;
    String birthDate = birthDateController.text;
    String gender = genderController.text;
    double height = heightController.text.isEmpty
        ? 0.0
        : double.parse(heightController.text);
    double weight = weightController.text.isEmpty
        ? 0.0
        : double.parse(weightController.text);

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("아이디와 비밀번호를 입력해 주세요.")),
      );
      return;
    }
    int signUpResult = await _apiService.signUp(
      username,
      password,
      selectedAllergies,
      name,
      birthDate,
      gender,
      height,
      weight,
    );

    if (signUpResult == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입에 성공했습니다.")),
      );

      Navigator.pop(context);
    } else if (signUpResult == -409) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미 사용중인 아이디입니다.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입에 실패했습니다.\n다시 시도해주세요.")),
      );
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    birthDateController.dispose();
    genderController.dispose();
    heightController.dispose();
    weightController.dispose();
    otherAllergyController.dispose();
    super.dispose();
  }
}
