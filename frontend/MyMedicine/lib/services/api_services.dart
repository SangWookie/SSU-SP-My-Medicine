import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:medicineapp/models/prescription_list_model.dart';
import 'package:medicineapp/models/prescription_model.dart';
import 'package:medicineapp/models/user_model.dart';
import 'package:medicineapp/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ApiService {
  static const String baseUrl = 'http://43.200.168.39:8080';
// GoogleSignIn 인스턴스 생성
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

//핑
  Future<int> pingServer() async {
    final url = Uri.http(baseUrl, '/status');
    final response = await http.get(url);
    log("/status: <${response.statusCode}>, <${response.body}>");
    if (response.statusCode != 204) {
      log('Server Response : ${response.statusCode}');
    }
    return response.statusCode;
  }

//로그인
  // Future<int> login(String loginId, String password) async {
  //   final url = Uri.http(baseUrl, '/login');
  //   final Map<String, dynamic> loginData = {
  //     "username": loginId,
  //     "password": password
  //   };
  //   final response = await http.post(
  //     url,
  //     body: jsonEncode(loginData),
  //     headers: {'Content-Type': 'application/json'},
  //   );
  //   log("/login: REQ: $url");
  //   log("/login: <${response.statusCode}>, <${response.body}>");
  //   if (response.statusCode == 200) {
  //     return int.parse(response.body);
  //   } else if (response.statusCode == 401 || response.statusCode == 409) {
  //     log('Server Response : ${response.statusCode}');
  //     return -response.statusCode;
  //   } else {
  //     log('Server Response : ${response.statusCode}');
  //     return -1;
  //   }
  // }
  Future<int> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await _saveTokens(data['access'], data['refresh']);
      return data['uid'];
    } else if (response.statusCode == 401) {
      return -401;
    } else if (response.statusCode == 409) {
      return -409;
    } else {
      return -1;
    }
  }

  // 회원가입
  // Future<int> signUp(String username, String password, List allergyInfo) async {
  //   final url = Uri.http(baseUrl, '/signup');
  //   final Map<String, dynamic> userData = {
  //     "username": username,
  //     "password": password,
  //     "allergicList": allergyInfo,
  //   };

  //   final response = await http.post(
  //     url,
  //     body: jsonEncode(userData),
  //     headers: {'Content-Type': 'application/json'},
  //   );

  //   log("/signup: REQ: $userData");
  //   log("/signup: <${response.statusCode}>, <${response.body}>");

  //   if (response.statusCode == 200) {
  //     return 200;
  //   } else if (response.statusCode == 409) {
  //     return -409;
  //   } else {
  //     return -1;
  //   }
  // }

  Future<int> signUp(
      String username, String password, List<String> allergies) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'password': password,
        'allergies': allergies,
      }),
    );

    if (response.statusCode == 200) {
      return 200;
    } else if (response.statusCode == 409) {
      return -409;
    } else {
      return -1;
    }
  }

////////////////////////////////////////////////////////////////////////////////
  Future<void> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was aborted.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await http.post(
        Uri.parse('$baseUrl/oauth2/authorization/google'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'idToken': googleAuth.idToken!,
          'accessToken': googleAuth.accessToken!,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await _saveTokens(data['access'], data['refresh']);
      } else {
        throw Exception('Failed to login with Google');
      }
    } catch (e) {
      throw Exception('Failed to login with Google: $e');
    }
  }

  Future<void> reissueToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      throw Exception('Refresh token not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/reissue'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'refresh': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await _saveTokens(data['access'], data['refresh']);
    } else {
      throw Exception('Failed to reissue token');
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', accessToken);
    prefs.setString('refresh_token', refreshToken);
  }

  Future<http.Response> authenticatedRequest(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    headers ??= {};
    headers['Authorization'] = 'Bearer $accessToken';

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      await reissueToken();
      return authenticatedRequest(endpoint, headers: headers, body: body);
    }

    return response;
  }
////////////////////////////////////////////////////////////////////////////////

//유저정보 조회
  Future<UserModel> getUserInfo(int uid) async {
    final url = Uri.http(baseUrl, '/getUserInfo', {'uID': '$uid'});
    final response = await http.get(url);
    log("/getUserInfo: <${response.statusCode}>, <${response.body}>");
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          jsonDecode(utf8.decode(response.bodyBytes));
      final UserModel userData = UserModel.fromJson(responseData);
      return userData;
    }
    throw Exception('Failed to load user information');
  }

//처방전 리스트 조회
  Future<PrescListModel> getPrescList(int uid) async {
    final url = Uri.http(baseUrl, '/getPrescList', {'uID': '$uid'});
    final response = await http.get(url);
    log("/getPrescList: <${response.statusCode}>, <${response.body}>");
    if (response.statusCode == 200) {
      final resData = jsonDecode(response.body);

      final prescData = PrescListModel.fromJson(resData);
      return prescData;
    }
    log("getPrescList Error: ${response.statusCode}");
    throw Error();
  }

//처방전 세부 조회
  Future<PrescModel> getPrescInfo(int prescId) async {
    final url = Uri.http(baseUrl, '/getPrescInfo', {'pID': '$prescId'});
    final response = await http.get(url);
    log("/getPrescInfo: <${response.statusCode}>, <${utf8.decode(response.bodyBytes)}>");
    if (response.statusCode == 200) {
      final resData = jsonDecode(utf8.decode(response.bodyBytes));

      final prescData = PrescModel.fromJson(resData);

      return prescData;
    }
    log("getPrescInfo Error: ${response.statusCode}");
    throw Error();
  }

//처방전 이미지 get
  Future<Uint8List> getPrescPic(int prescId) async {
    final url = Uri.http(baseUrl, '/getPrescPic', {'pID': '$prescId'});
    final response = await http.get(url);
    // log("/getPrescPic: <${response.statusCode}>, <${response.body}>");
    log("/getPrescPic: <${response.statusCode}>, ${response.body.length}");
    if (response.statusCode == 200) {
      Uint8List resData = base64Decode(response.body);
      // final resData = response.body;
      return resData;
    }
    log("getPrescPic Error: ${response.statusCode}");
    //이미지 없을 경우
    return Uint8List(0);
    throw Error();
  }

// 이미지 업로드
  Future<int> uploadImage(int uid, String regDate, int duration,
      List<String> medList, Uint8List image) async {
    final url = Uri.parse('http://43.200.168.39:8080/newPresc');

    var request = http.MultipartRequest('POST', url);

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      image,
      filename: 'upload.jpg',
      contentType: MediaType('image', 'jpg'),
    ));
    request.fields['uID'] = uid.toString();
    request.fields['regDate'] = regDate;
    request.fields['duration'] = duration.toString();
    request.fields['medList'] = medList.join(',');
    var response = await request.send();
    log(" Error: ${response.statusCode}");
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final pID = int.parse(respStr.trim());
      return pID;
    } else {
      return -1;
    }
  }

  // 처방건 삭제
  Future<void> deletePrescription(int prescriptionId) async {
    try {
      final url = Uri.http(baseUrl, '/delPresc', {'pID': '$prescriptionId'});
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        log("처방전이 성공적으로 삭제되었습니다.");
        return;
      } else {
        log("처방전 삭제에 실패했습니다. 상태 코드: ${response.statusCode}");
        throw Exception('처방전 삭제에 실패했습니다.');
      }
    } catch (e) {
      log("처방전 삭제 중 오류 발생: $e");
      throw e;
    }
  }
}
