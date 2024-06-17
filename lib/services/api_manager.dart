import 'dart:convert';
import 'package:logger/logger.dart';
import 'openai_receive_unit.dart' as openai_receive_unit;
import 'map_unit.dart' as map_unit;
import 'tdx_unit.dart.';
import 'openai_send_unit.dart' as openai_send_unit;
import 'network_unit.dart' as network_unit;

final logger = Logger();
final connectErrorMessage = jsonEncode({
  'result': false,
  'data': '''抱歉，網路好像有點狀況QQ

可以麻煩你檢查一下網路嗎？好了的話直接回來和我聊天吧'''
});

class ApiManager {
  TdxUnit tdxUnit = TdxUnit();

  Future<String> getResult(String inputString) async {
    if (!(await network_unit.isConnect())) {
      return connectErrorMessage;
    }

    // String error_message = "抱歉，我有點看不懂QQ\n要再麻煩你告訴我一次你的起點、目的地，以及希望省錢還是省時間喔！";

    if (inputString.length > 200) {
      return jsonEncode({
        'result': false,
        'data': '''抱歉，你的訊息有點太長了，我小小的腦袋裝不下QQ

可以麻煩你用簡短的文字告訴我，你的起點、目的地，以及希望省錢還是省時間嗎？'''
      });
    }


    String AItoMAP = await openai_receive_unit.getResult(inputString);
    // logger.i('AItoMAP: $AItoMAP');
    if (!jsonDecode(AItoMAP)['result']) {
      if (jsonDecode(AItoMAP)['message'] ==
          'origin or destination is not correct') {
        return jsonEncode({
          'result': false,
          'data': '''抱歉，我沒有聽懂你的起點及目的地，分別在哪裡QQ

可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'''
        });
      } else {
        return jsonEncode({
          'result': false,
          'data':
              '''抱歉，連接 open ai 時出現問題。錯誤訊息：${jsonDecode(AItoMAP)['message']}'''
        });
      }
    }

    String MAPtoTDX = await map_unit.getResult(AItoMAP);
    // logger.i('MAPtoTDX: $MAPtoTDX');
    if (!jsonDecode(MAPtoTDX)['result']) {
      return jsonEncode({
        'result': false,
        'data': '''抱歉，你的起點及目的地，似乎有無法在地圖上搜尋到的地方QQ

可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'''
      });
    }

    String TDXtoAI = await tdxUnit.getResult(MAPtoTDX);
    // logger.i('TDXtoAI: $TDXtoAI');
    // print('TDXtoAI: Received');
    if (!jsonDecode(TDXtoAI)['result']) {
      if (jsonDecode(TDXtoAI)['message'] == 'Route not found') {
        return jsonEncode({
          'result': false,
          'data': '''抱歉，看起來這超出了我的能力範圍，無法給你幫助QQ

你可以試試這些方法，幫助我更好地找到正確的路線：

1. 對地點更詳細的描述：比起**市政府**，**臺南市政府**會是更好的選擇！
2. 避免輸入國外地點：我只能協助規劃臺灣境內的路線
3. 起終點附近的大眾運輸：有些地方大眾運輸到不了，我就沒辦法規劃了

確認過上面幾點後，可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'''
        });
      } else {
        return jsonEncode({
          'result': false,
          'data': '''抱歉，連接 TDX 時出現問題。錯誤訊息：${jsonDecode(TDXtoAI)['message']}'''
        });
      }
    }

    TDXtoAI = '${jsonDecode(AItoMAP)['data']}$TDXtoAI';

    String AItoUSER = await openai_send_unit.getResult(TDXtoAI);
    // print('AItoUSER: $AItoUSER');
    if (!jsonDecode(AItoUSER)['result']) {
      return jsonEncode({
        'result': false,
        'data': '''抱歉，小幫手在產生交通路線時，出了一點問題QQ

可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'''
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
