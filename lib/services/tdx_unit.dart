import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// import 'mapUnit.dart' as mapUnit;
import 'config.dart' as config;

const String authUrl =
    'https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token';

final String apiId = config.properties['API_KEY']['tdx']['ID'];
final String apiSecret = config.properties['API_KEY']['tdx']['Secret'];

class TdxUnit {
  Map accessTokenInfo = {'access_token': '', 'expire_time': DateTime.now()};

  Map userInput = {
    'origin': [],
    'destination': [],
    'gc': 0,
    'transit': [3, 4, 5, 6, 7, 8, 9],
    'depart': DateTime.now(),
    'arrival': DateTime.now()
  };

  // e.g. 2024-06-16T21:33:00
  String formatTime(DateTime time) {
    return DateFormat('yyyy-MM-ddTHH%3Amm%3Ass').format(time);
  }

  void updateUserInput(Map input) {
    userInput['origin'] = input['origin'];
    userInput['destination'] = input['destination'];
    userInput['gc'] = input['gc'];
    userInput['transit'] = input['transit'];
    userInput['depart'] = input['depart'];
    userInput['arrival'] = input['arrival'];
  }

  String getUrl() {
    String transitStr = userInput['transit'][0].toString();
    for (var i = 1; i < userInput['transit'].length; ++i) {
      transitStr += '%2C${userInput['transit'][i]}';
    }

    return 'https://tdx.transportdata.tw/api/maas/routing?origin=${userInput['origin'][1]}%2C${userInput['origin'][0]}&destination=${userInput['destination'][1]}%2C${userInput['destination'][0]}&gc=${userInput['gc']}&top=1&transit=$transitStr&transfer_time=0%2C30&depart=${formatTime(userInput['depart'])}&arrival=${formatTime(userInput['arrival'])}&first_mile_mode=0&first_mile_time=30&last_mile_mode=0&last_mile_time=30';
  }

  Map<String, String> getAuthHeader() {
    return {
      'content-type': 'application/x-www-form-urlencoded',
    };
  }

  Map<String, String> getAuthBody() {
    return {
      'grant_type': 'client_credentials',
      'client_id': apiId,
      'client_secret': apiSecret
    };
  }

  Map<String, String> getDataHeader(String accessToken) {
    return {'authorization': 'Bearer $accessToken', 'Accept-Encoding': 'gzip'};
  }

  Future<void> updateAccessToken() async {
    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: getAuthHeader(),
      body: getAuthBody(),
    );
    Map<String, dynamic> responseDecoded = jsonDecode(response.body);
    accessTokenInfo['access_token'] = responseDecoded['access_token'];
    accessTokenInfo['expire_time'] =
        DateTime.now().add(Duration(seconds: responseDecoded['expires_in']));
  }

  Future<String> getAccessToken() async {
    if (accessTokenInfo['access_token'] == '' ||
        accessTokenInfo['expire_time'].compareTo(DateTime.now()) < 0) {
      await updateAccessToken();
    }
    return accessTokenInfo['access_token'];
  }

  Future<String> getResult(String inputString) async {
    Map<String, dynamic> input = jsonDecode(inputString);

    if (!input['result']) {
      return jsonEncode(input);
    }
    input['data']['transit'] = [3, 4, 5, 6, 7, 8, 9];
    input['data']['depart'] = DateTime.now().add(const Duration(minutes: 5));
    input['data']['arrival'] = DateTime.now().add(const Duration(days: 1));

    updateUserInput(input['data']);

    String accessToken = await getAccessToken();

    http.Response response = await http.get(Uri.parse(getUrl()),
        headers: getDataHeader(accessToken));
    Map<String, dynamic> responseDecoded = jsonDecode(response.body);
    if (responseDecoded['result'] == 'fail') {
      return jsonEncode({'result': false, 'message': responseDecoded['error']});
    } else if (responseDecoded['data']['routes'].isEmpty) {
      return jsonEncode({'result': false, 'message': 'Route not found'});
    }
    return jsonEncode({'result': true, 'data': responseDecoded['data']});
  }
}

// For debugging
Future<void> main() async {
  TdxUnit tdxUnit = TdxUnit();

  // String input = await mapUnit.getResult(
  //   jsonEncode([{
  //     'origin': '板橋車站',
  //     'destination': '台北市政府',
  //     'preference': '省時間'
  //   }])
  // );

  String input =
      '''{"result":true,"data":{"origin":[121.52017356684297,25.06976766747735],"destination":[121.51976421101928,25.06305755058022],"gc":1}}''';

  String result = await tdxUnit.getResult(input);

  // print(result);
  stdout.write('Length of result: ${result.length}');
}
