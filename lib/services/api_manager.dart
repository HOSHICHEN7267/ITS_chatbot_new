import 'dart:convert';
import 'package:logger/logger.dart';
import 'openai_receive_unit.dart' as openai_receive_unit;
import 'map_unit.dart' as map_unit;
import 'tdx_unit.dart.';
import 'openai_send_unit.dart' as openai_send_unit;
// import 'network_unit.dart' as network_unit;

final logger = Logger();
final connectErrorMessage = jsonEncode(
    {'result': false, 'data': '抱歉，網路好像有點狀況QQ\n可以麻煩你檢查一下網路嗎？好了的話直接回來和我聊天吧'});

class ApiManager {
  TdxUnit tdxUnit = TdxUnit();

  Future<String> getResult(String inputString) async {
    // if (!(await network_unit.isConnect())) {
    //   return connectErrorMessage;
    // }

    // String error_message = "抱歉，我有點看不懂QQ\n要再麻煩你告訴我一次你的起點、目的地，以及希望省錢還是省時間喔！";

    if (inputString.length > 200) {
      return "抱歉，你的訊息有點太長了，我小小的腦袋裝不下QQ\n可以麻煩你用簡短的文字告訴我，你的起點、目的地，以及希望省錢還是省時間嗎？";
    }

    String AItoMAP = await openai_receive_unit.getResult(inputString);
    // logger.i('AItoMAP: $AItoMAP');
    if (!jsonDecode(AItoMAP)['result']) {
      if (jsonDecode(AItoMAP)['message'] == 'origin or destination is not correct'){
        return jsonEncode({
          'result': false,
          'data': '抱歉，我沒有聽懂你的起點及目的地，分別在哪裡QQ\n可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'
        });
      }
      else {
        return jsonEncode({
          'result': false,
          'data': '抱歉，連接 open ai 時出現問題，錯誤訊息：${jsonDecode(AItoMAP)['message']}'
        });
      }
    }

    String MAPtoTDX = await map_unit.getResult(AItoMAP);
    // logger.i('MAPtoTDX: $MAPtoTDX');
    if (!jsonDecode(MAPtoTDX)['result']) {
      return jsonEncode({
        'result': false,
        'data': '抱歉，你的起點及目的地，似乎有無法在地圖上搜尋到的地方QQ\n可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'
      });
    }

    String TDXtoAI = await tdxUnit.getResult(MAPtoTDX);
    // logger.i('TDXtoAI: $TDXtoAI');
    // print('TDXtoAI: Received');
    if (!jsonDecode(TDXtoAI)['result']) {
      if (jsonDecode(TDXtoAI)['message'] == 'Route not found') {
        return jsonEncode({
          'result': false,
          'data':
              '抱歉，我只會規劃台灣境內的交通路線，如果你要出國的話，我就無法給你幫助了QQ\n如果你還想去其他台灣地點的話，可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'
        });
      }
      else {
        return jsonEncode({
          'result': false,
          'data': '抱歉，連接 TDX 時出現問題，錯誤訊息：${jsonDecode(TDXtoAI)['message']}'
        });
      }
    }

    TDXtoAI = '${jsonDecode(AItoMAP)['data']}$TDXtoAI';

    String AItoUSER = await openai_send_unit.getResult(TDXtoAI);
    // print('AItoUSER: $AItoUSER');
    if (!jsonDecode(AItoUSER)['result']) {
      return jsonEncode({
        'result': false,
        'data': '抱歉，小幫手在產生交通路線時，出了一點問題QQ\n可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'
      });
    }

    return AItoUSER;
  }
}

// for debug
Future<void> main() async {
  ApiManager apiManager = ApiManager();

  String inputMessage = "從市政府到政治大學，甚麼方式最快？";
  String outputMessage = await apiManager.getResult(inputMessage);
  Map<String, dynamic> response = jsonDecode(outputMessage);

  // 正確情況
  if (response['result']) {
    outputMessage = response['data'];
  }

  // 錯誤情況
  else {
    outputMessage = response['data'];
  }

  logger.i(outputMessage);
  // print(outputMessage);
}
