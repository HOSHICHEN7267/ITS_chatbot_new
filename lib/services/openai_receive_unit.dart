import 'package:dart_openai/dart_openai.dart';
import 'dart:convert';
import './config.dart' as config;

Future<String> extractInfo(String question) async {
  String prompt = '''
從以下問句中提取起點、終點，以及偏好：省錢(最便宜)，或省時間(最快)，或是無偏好。
若能順利提取起點、終點，就以下 json 格式回應：
{
  "origin": (中文地名),
  "destination": (中文地名),
  "preference":("省錢" or "省時間" or "無")
}
如果找不到起點、或是找不到終點，就回應："error"

問句：$question
''';

  // the system message that will be sent to the request.
  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "你是一個幫助提取信息的助手，會將處理好資訊用 json 格式回應",
      ),
    ],
    role: OpenAIChatMessageRole.assistant,
  );

  // the user message that will be sent to the request.
  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        prompt,
      ),
    ],
    role: OpenAIChatMessageRole.user,
  );

  // all messages to be sent.
  final requestMessages = [
    systemMessage,
    userMessage,
  ];

  OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
    model: "gpt-3.5-turbo",
    responseFormat: {"type": "json_object"},
    seed:6,
    messages: requestMessages,
    temperature: 0.2,
    maxTokens: 500,
  );

  // Extract the content from the response and concatenate it into a single string.\
  // print(chatCompletion.choices.first.message.content);
  var contentItems = chatCompletion.choices.first.message.content;
  String responseContent = contentItems != null
      ? contentItems.map((item) => item.text).join(' ').trim()
      : '';

  return responseContent;
  
}

bool isValidResult(String result) {
  // 檢查 result 字串是否包含 "error"
  if (result.contains("error")) {
    return false;
  }

  try {
    // 解析 JSON 字串
    final decoded = json.decode(result);

    // 檢查 JSON 是否包含所需的鍵
    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('origin') &&
        decoded.containsKey('destination') &&
        decoded.containsKey('preference')) {

      // 檢查 'origin' 和 'destination' 是否為非空字串
      final origin = decoded['origin'];
      final destination = decoded['destination'];
      final preference = decoded['preference'];

      if (origin is String && origin.isNotEmpty &&
          destination is String && destination.isNotEmpty &&
          preference is String &&
          (preference == '省錢' || preference == '省時間' || preference == '無')) {
        return true;
      }
    }
  } catch (e) {
    // JSON 解析錯誤或其他錯誤
    // print('Error parsing JSON: $e');
    return false;
  }
  return false;
}

Future<String> getResult(String input) async {
  try {
    OpenAI.apiKey = config.properties['API_KEY']['openai'];
    String result = await extractInfo(input);
    // print('result: $result');

    if (!isValidResult(result)) {
      return jsonEncode({
        'result': false, 
        'message': 'origin or destination is not correct'}
      );
    }

    return jsonEncode({
      'result': true, 
      'data': result
    });
  } catch (e) {
    return jsonEncode({
      'result': false, 
      'message': '$e'}
    );
  }
}

// Future<void> main() async {

//   String inputString = " ";
//   String AItoMAP = await getResult(inputString);
//   print('AItoMAP: $AItoMAP');
  
  // String testString = '{"origin": "台北", "destination": "高雄", "preference": "省錢"}';
  // print(isValidResult(testString)); 

  // String invalidTestString = '''
  // result: {
  //   "origin": "error",
  //   "destination": "error",
  //   "preference": "error"
  // }
  // ''';
  // print(isValidResult(invalidTestString)); 

  // String errorTestString = 'djioerufhjnvd';
  // print(isValidResult(errorTestString)); 
// }