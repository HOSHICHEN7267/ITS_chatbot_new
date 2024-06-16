import 'dart:convert';
// import 'dart:io';
import 'package:http/http.dart' as http;

import 'config.dart' as config;

Future<Map<String, double>> getGeocode(String location, String apiKey) async {
  const String baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  final Uri uri = Uri.parse('$baseUrl?address=$location&key=$apiKey');

  final http.Response response = await http.get(uri);

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    if (data['status'] == 'OK') {
      var location = data['results'][0]['geometry']['location'];
      return {
        'lat': location['lat'],
        'lng': location['lng'],
      };
    } else {
      throw Exception('Failed to get geocode: ${data['status']}');
    }
  } else {
    throw Exception('Failed to fetch data from API: ${response.statusCode}');
  }
}

int processText(String text) {
  if (text == '省錢') {
    return 0;
  } else if (text == '省時間' || text == '無') {
    return 1;
  } else {
    throw Exception('Invalid input: $text');
  }
}

Future<String> getResult(String inputString) async {
  String apiKey = config.properties['API_KEY']['geocode'];

  String resultString;

  try {
    // Parse the input JSON string
    Map<String, dynamic> parsedInput = jsonDecode(jsonDecode(inputString)['data']);
    String originName = parsedInput['origin'] + "(台灣)";
    String destinationName = parsedInput['destination'] + "(台灣)";
    String preference = parsedInput['preference'];

    // Get geocode for origin and destination
    Map<String, double> origin = await getGeocode(originName, apiKey);
    Map<String, double> destination = await getGeocode(destinationName, apiKey);

    // Process the preference text
    int gc = processText(preference);

    // Create the JSON object
    Map<String, dynamic> output = {
      'result': true, 
      'data': {
        'origin': [origin['lng'], origin['lat']],
        'destination': [destination['lng'], destination['lat']],
        'gc': gc,
      }
    };

    // Convert the JSON object to a string
    resultString = jsonEncode(output);
    return resultString;

  } catch (e) {
    resultString = jsonEncode({
      'result': false, 
      'message': '$e'}
    );
    return resultString;
  }
}

// Future<void> main() async {
//   String input = '''
//   [
//   {
//     "origin": "板橋車站",
//     "destination": "台北市政府",
//     "preference": "省時間"
//   }
//   ]
//   ''';
//   String resultString = await getResult(input);
//   print(resultString);
// }