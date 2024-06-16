import 'package:dart_openai/dart_openai.dart';
import 'dart:convert';
import 'config.dart' as config;

Future<String> extractInfo(String question) async {
  String prompt = '''
Read the information below, then write a instruction article in traditional Chinese colloquially.
Notice:
- You are a enthusiastic tour guide. You are talking to only one person.
- Time is represented by second now. Convert all the time representations into minute, hour, or day.
- Format date as "month/day hour:minute". Don't show year. E.g. 06/20 23:04.
- Don't show longtitude nor latitude.
- For each traveling sections, organise a paragrph.
- Label the sections with numbers.
- Don't use markdown syntax.
- MRT is 捷運.
- Start the article with greeting, fare, overall traveling time, departing and arrival time. Continue with 交通資訊.

json text:
$question
''';

  // the system message that will be sent to the request.
  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        // "你是一個地理助手，擅長整理資訊，會在閱讀 json 檔後，將內容整理成易閱讀的文章供人參考。",
        "You are a geography assistant, who is good at organising. Your job is to compose a instruction article.",
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
    model: "gpt-3.5-turbo-1106",
    seed:6,
    messages: requestMessages,
    temperature: 0,
    maxTokens: 1024,
  );

  // Extract the content from the response
  var contentItems = chatCompletion.choices.first.message.content;
  String responseContent = contentItems != null
      ? contentItems.map((item) => item.text).join(' ').trim()
      : 'nothing showed here';
  return responseContent;
}

Future<String> getResult(String inputString) async {
  try {
    OpenAI.apiKey = config.properties['API_KEY']['openai'];
    String result = await extractInfo(inputString);
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



// Future<void> main() async{
//   String input = '{"result":"success","data.routes":[{"travel_time":481,"start_time":"2024-06-17T06:55:45","day":1,"end_time":"2024-06-17T07:03:46","transfers":0,"sections":[{"type":"pedestrian","actions":[{"action":"depart","duration":103},{"action":"arrive","duration":0}],"travelSummary":{"duration":103,"length":144.16507},"departure":{"time":"2024-06-17T06:55:45","place":{"type":"place","location":{"lat":25.069874,"lng":121.520187}}},"arrival":{"time":"2024-06-17T06:57:28","place":{"name":"圓山圓山站 出口1","type":"entrance","location":{"lat":25.070786,"lng":121.520035}}},"transport":{"mode":"pedestrian"}},{"type":"pedestrian-station","actions":[{"action":"depart","duration":88},{"action":"arrive","duration":0}],"travelSummary":{"duration":88,"length":0},"departure":{"time":"2024-06-17T06:57:28","place":{"name":"圓山圓山站 出口1","type":"entrance","location":{"lat":25.070786,"lng":121.520035}}},"arrival":{"time":"2024-06-17T06:58:56","place":{"name":"圓山","type":"station","location":{"lat":25.071409,"lng":121.520073}}},"transport":{"mode":"pedestrian"}},{"type":"transit","travelSummary":{"duration":88,"length":0},"departure":{"time":"2024-06-17T06:58:56","place":{"name":"圓山","type":"station","location":{"lat":25.071409,"lng":121.520073}}},"arrival":{"time":"2024-06-17T07:00:24","place":{"name":"民權西路","type":"station","location":{"lat":25.062349,"lng":121.519585}}},"transport":{"mode":"MRT","name":"淡水信義線","category":"MRT","headsign":"象山","shortName":"淡水信義線","longName":"象山－淡水","route_color":"d90023","number":"","type":"MRT","city":"","fareTW":0},"intermediateStops":[],"agency":{"agency_id":"TRTC","name":"臺北大眾捷運股份有限公司","website":"http://www.metro.taipei/","reserve":"0","phone":"02-218-12345"}},{"type":"pedestrian-station","actions":[{"action":"depart","duration":183},{"action":"arrive","duration":0}],"travelSummary":{"duration":183,"length":0},"departure":{"time":"2024-06-17T07:00:24","place":{"name":"民權西路","type":"station","location":{"lat":25.062349,"lng":121.519585}}},"arrival":{"time":"2024-06-17T07:03:27","place":{"name":"民權西路站 出口10","type":"exit","location":{"lat":25.063063,"lng":121.519791}}},"transport":{"mode":"pedestrian"}},{"type":"pedestrian","actions":[{"action":"depart","duration":19},{"action":"arrive","duration":0}],"travelSummary":{"duration":19,"length":27.458063},"departure":{"time":"2024-06-17T07:03:27","place":{"name":"民權西路站 出口10","type":"exit","location":{"lat":25.063063,"lng":121.519791}}},"arrival":{"time":"2024-06-17T07:03:46","place":{"type":"place","location":{"lat":25.063082,"lng":121.5196}}},"transport":{"mode":"pedestrian"}}]}]}';
//   String result = await getResult(input);
//   print(result);
// }