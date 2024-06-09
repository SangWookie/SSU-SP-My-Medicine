import 'dart:convert' show base64Decode, jsonDecode, jsonEncode, utf8;
import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:medicineapp/models/prescription_list_model.dart';
import 'package:medicineapp/models/prescription_model.dart';
import 'package:medicineapp/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:cp949_codec/cp949_codec.dart';

class ApiService {
  static const String baseUrl = '43.200.168.39:8080';
  late http.Client httpClient;
  late String accessHeaderValue;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // 싱글톤 패턴 적용을 위한 인스턴스
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    httpClient = http.Client();
  }

// 액세스 토큰 초기화
  Future<void> _initializeAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessHeaderValue = prefs.getString('access') ?? '';
    if (accessHeaderValue.isEmpty) {
      throw Exception('Access token not found');
    }
  }

  // 서버 상태 확인
  Future<int> pingServer() async {
    await _ensureAccessTokenInitialized();
    final url = Uri.http(baseUrl, '/status');
    final response = await http.get(
      url,
      headers: {'access': accessHeaderValue},
    );
    log("/status: <${response.statusCode}>, <${response.body}>");
    if (response.statusCode != 204) {
      log('Server Response : ${response.statusCode}');
    } else if (response.statusCode == 401) {
      reissueToken;
      pingServer;
    }
    return response.statusCode;
  }

// 로그인
  Future<int> login(
    String loginId,
    String password,
  ) async {
    final url = Uri.http(baseUrl, '/login');
    final Map<String, dynamic> loginData = {
      "username": loginId,
      "password": password
    };
    final response = await http.post(
      url,
      body: jsonEncode(loginData),
      headers: {'Content-Type': 'application/json'},
    );
    log("${loginData}");
    log("/login: REQ: $url");
    log("/login: <${response.statusCode}>, <${response.headers}>");
    if (response.statusCode == 200) {
      accessHeaderValue = response.headers['access']!;
      String uID = response.headers['uid']!;
      log("/login api: accesstoken: ${accessHeaderValue}");
      log("/login api: uID:${uID}");
      log('${response.headers['set-cookie']}');
      await _saveTokens(response.headers['set-cookie']!);
      await _saveAccessToken(accessHeaderValue); // Access 토큰 저장
      return int.parse(uID);
    } else if (response.statusCode == 401 || response.statusCode == 409) {
      log('/login api: Server Response : ${response.statusCode}');
      return -response.statusCode;
    } else {
      log('/login api: Server Response : ${response.statusCode}');
      return -1;
    }
  }

  // 회원가입
  Future<int> signUp(
    String username,
    String password,
    List<String> allergies,
    String name,
    String birthDate,
    String gender,
    double height,
    double weight,
  ) async {
    final url = Uri.http(baseUrl, '/signup');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'password': password,
        'allergicList': allergies,
        'nickname': name,
        'birthDate': birthDate,
        'gender': gender,
        'height': height,
        'weight': weight
      }),
    );
    log('/signup status: ${response.statusCode} ${response.body}');
    log('/signup request body:${username}, ${password}, ${allergies}, ${name},${birthDate},${gender},${height},${weight}');
    if (response.statusCode == 200) {
      return 200;
    } else if (response.statusCode == 409) {
      return -409;
    } else {
      return -1;
    }
  }

  // 구글 로그인
  // Future<int> googleLogin() async {
  //   try {
  //     final url = Uri.http(baseUrl, 'oauth2/authorization/google');
  //     // final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     // if (googleUser == null) {
  //     //   throw Exception('Google sign in was aborted.');
  //     // }

  //     // final GoogleSignInAuthentication googleAuth =
  //     //     await googleUser.authentication;

  //     // final response = await http.post(
  //     //   Uri.parse('$baseUrl/oauth2/authorization/google'),
  //     //   body: jsonEncode(<String, String>{
  //     //     'idToken': googleAuth.idToken!,
  //     //     'accessToken': googleAuth.accessToken!,
  //     //   }),
  //     // );
  //     final response = await http.get(
  //       url,
  //     );

  //     log('social login status: ${response.statusCode}');
  //     if (response.statusCode == 200) {
  //       accessHeaderValue = response.headers['access']!;
  //       String uID = response.headers['uid']!;
  //       log("/login api: accesstoken:${accessHeaderValue}");
  //       log("/login api: uID:${uID}");
  //       await _saveTokens(response.headers['set-cookie']!);
  //       // await _saveAccessToken(accessHeaderValue); // Access 토큰 저장
  //       return int.parse(uID);
  //     } else {
  //       throw Exception('Failed to login with Google');
  //     }
  //   } catch (e) {
  //     log('${e}');
  //     throw Exception('Failed to login with Google: $e');
  //   }
  // }

  // 토큰 갱신
  Future<int> reissueToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh');
    final url = Uri.http(baseUrl, '/reissue');

    if (refreshToken == null) {
      throw Exception('Refresh token not found');
    }

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.cookieHeader: refreshToken,
      },
    );
    log('/reissue status: ${response.statusCode}');
    if (response.statusCode == 200 && response.headers['access'] != null) {
      log('/reissue status: ${response.headers['access']}');
      accessHeaderValue = response.headers['access']!;
      await _saveAccessToken(accessHeaderValue);
      await _saveTokens(response.headers['set-cookie']!);
      return 1;
    } else {
      reissueToken();
      return 1;
    }
  }

  // 토큰 저장
  Future<void> _saveTokens(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh', refreshToken);
  }

  // 액세스 토큰 저장
  Future<void> _saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', accessToken);
  }

  // 사용자 정보 가져오기
  Future<UserModel> getUserInfo(int uid) async {
    await _ensureAccessTokenInitialized();
    final url = Uri.http(baseUrl, '/getUserInfo', {'uID': '$uid'});
    final response = await http.get(
      url,
      headers: {'access': accessHeaderValue},
    );
    log("/getUserInfo api: <${response.statusCode}>,  <${utf8.decode(response.bodyBytes)}>");
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          jsonDecode(utf8.decode(response.bodyBytes));
      final UserModel userData = UserModel.fromJson(responseData);
      log('/getUserInfo data: ${userData.allergic}');
      return userData;
    } else if (response.statusCode == 401) {
      int retoken = reissueToken() as int;
      if (retoken == 1) {
        Future.delayed(const Duration(milliseconds: 990));
        await getUserInfo(uid);
      }
    }
    throw Exception('Failed to load user information');
  }

  //알러지 정보 수정
  Future<int> edituser(
    int username,
    List<String> allergies,
    String name,
    String birthDate,
    String gender,
    double height,
    double weight,
  ) async {
    final url = Uri.http(baseUrl, '/editUser');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'access': accessHeaderValue,
      },
      body: jsonEncode(<String, dynamic>{
        'uid': username,
        'allergicList': allergies,
        'nickname': name,
        'birthDate': birthDate,
        'gender': gender,
        'height': height,
        'weight': weight,
      }),
    );
    log('/edituser request: ${allergies}, ${birthDate}');
    log('/edituser response: ${response.statusCode}, ${response.body}');
    // getUserInfo(username);
    return response.statusCode;
  }

  // 처방 목록 가져오기
  Future<PrescListModel> getPrescList(int uid) async {
    await _ensureAccessTokenInitialized();
    final url = Uri.http(baseUrl, '/getPrescList', {'uID': '$uid'});
    final response = await http.get(
      url,
      headers: {'access': accessHeaderValue},
    );
    log('${accessHeaderValue}');
    log("/getPrescList api: <${response.statusCode}>, <${response.body}>");
    if (response.statusCode == 200) {
      final resData = jsonDecode(response.body);
      final prescData = PrescListModel.fromJson(resData);
      return prescData;
    } else if (response.statusCode == 404) {
      return await getPrescList(uid);
    } else if (response.statusCode == 401) {
      int retoken = reissueToken() as int;
      if (retoken == 1) {
        Future.delayed(const Duration(milliseconds: 990));
        return await getPrescList(uid);
      }
    }
    log("getPrescList api Error: ${response.statusCode}");
    throw Error();
  }

  // 처방 정보 가져오기
  Future<PrescModel> getPrescInfo(int prescId) async {
    await _ensureAccessTokenInitialized();
    final url = Uri.http(baseUrl, '/getPrescInfo', {'pID': '$prescId'});
    final response = await http.get(
      url,
      headers: {'access': accessHeaderValue},
    );
    log("/getPrescInfo api: <${response.statusCode}>, <${/*cp949*/ utf8.decode(response.bodyBytes)}>");

    if (response.statusCode == 200) {
      final resData = jsonDecode(/*cp949*/ utf8.decode(response.bodyBytes));
      final prescData = PrescModel.fromJson(resData);
      return prescData;
    } else if (response.statusCode == 401) {
      int retoken = reissueToken() as int;
      if (retoken == 1) {
        Future.delayed(const Duration(milliseconds: 990));
        await getPrescInfo(prescId);
      }
    } else if (response.statusCode == 404) {
      await getPrescInfo(prescId);
    }
    log("getPrescInfo api Error: ${response.statusCode}");
    return PrescModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  // 처방 사진 가져오기
  Future<Uint8List> getPrescPic(int prescId) async {
    // Future.delayed(const Duration(milliseconds: 990));
    await _initializeAccessToken();
    final url = Uri.http(baseUrl, '/getPrescPic', {'pID': '$prescId'});
    final response = await http.get(
      url,
      headers: {'access': accessHeaderValue},
    );
    log('/getimage api reponse: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        log('decode try');
        // Uint8List resData = base64Decode(response.body);
        Uint8List resData = response.bodyBytes;
        log('/getimage api body: success');
        return resData;
      } catch (e) {
        log('Error decoding image: $e');
        return Uint8List(0);
      }
    } else if (response.statusCode == 401) {
      int retoken = reissueToken() as int;
      if (retoken == 1) {
        Future.delayed(const Duration(milliseconds: 990));
      }
      return Uint8List(0);
    } else {
      log("Failed to fetch image, status code: ${response.statusCode}");
      return Uint8List(0);
    }
  }

  // 이미지 업로드
  Future<int> uploadImage(int uid, String regDate, int duration,
      List<String> medList, Uint8List image) async {
    await _initializeAccessToken();
    final url = Uri.http(baseUrl, '/newPresc');
    var request = http.MultipartRequest(
      'POST',
      url,
    );

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
    request.headers['access'] = accessHeaderValue;
    log('/uploadImage api: ${request.fields}');
    log('/uploadImage api: ${request.headers}');
    var response = await request.send();
    log("/uploadImage api statusCode: ${response.statusCode}");
    log('/uploadImage api body: ${response.stream}');
    if (response.statusCode == 200) {
      try {
        final respStr = await response.stream.bytesToString();
        log('${respStr.trim()}');
        final pID = int.parse(respStr.trim());
        return pID;
      } catch (e) {
        log("/upload reponse parsing error: $e");
        return -1;
      }
    } else if (response.statusCode == 401) {
      int retoken = reissueToken() as int;
      if (retoken == 1) {
        Future.delayed(const Duration(milliseconds: 990));
      }
      return -1;
    } else {
      return -1;
    }
  }

  // 처방 삭제
  Future<void> deletePrescription(int prescriptionId) async {
    try {
      await _initializeAccessToken();
      final url = Uri.http(baseUrl, '/delPresc', {'pID': '$prescriptionId'});
      final response = await http.delete(
        url,
        headers: {'access': accessHeaderValue},
      );
      if (response.statusCode == 200) {
        log("처방전이 성공적으로 삭제되었습니다.");
        return;
      } else if (response.statusCode == 401) {
        int retoken = reissueToken() as int;
        if (retoken == 1) {
          Future.delayed(const Duration(milliseconds: 990));
        }
        await deletePrescription(prescriptionId);
      } else {
        log("처방전 삭제에 실패했습니다. 상태 코드: ${response.statusCode}");
        throw Exception('처방전 삭제에 실패했습니다.');
      }
    } catch (e) {
      log("처방전 삭제 중 오류 발생: $e");
      throw e;
    }
  }

// 액세스 토큰 초기화 확인
  Future<void> _ensureAccessTokenInitialized() async {
    if (!isAccessTokenInitialized()) {
      await _initializeAccessToken();
    }
  }

// 액세스 토큰 초기화 여부 확인
  bool isAccessTokenInitialized() {
    return accessHeaderValue.isNotEmpty;
  }
}
