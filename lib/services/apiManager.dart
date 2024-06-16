import 'dart:convert';
import 'openai_receiveUnit.dart' as openai_receiveUnit;
import 'mapUnit.dart' as mapUnit;
import 'tdxUnit.dart.';
import 'openai_sendUnit.dart' as openai_sendUnit;

class ApiManager{

  TdxUnit tdxUnit = TdxUnit();

  Future<String> getResult(String inputString) async {
    String error_message = "抱歉，我有點看不懂QQ\n要再麻煩你告訴我一次你的起點、目的地，以及希望省錢還是省時間喔！";
    
    if (inputString.length > 200) {
      return "抱歉，你的訊息有點太長了，我看不太懂，可以用簡短的文字告訴我，你的起點、目的地，以及希望省錢還是省時間嗎？";
    }

    String AItoMAP = await openai_receiveUnit.getResult(inputString);
    // print('AItoMAP: $AItoMAP');
    if (!jsonDecode(AItoMAP)['result']) {
      return error_message;
    }

    String MAPtoTDX = await mapUnit.getResult(AItoMAP);
    // print('MAPtoTDX: $MAPtoTDX');
    if (!jsonDecode(MAPtoTDX)['result']) {
      return error_message;
    }

    String TDXtoAI = await tdxUnit.getResult(MAPtoTDX);
    // print('TDXtoAI: $TDXtoAI');
    // print('TDXtoAI: Received');
    if (!jsonDecode(TDXtoAI)['result']) {
      return error_message;
    }

    String AItoUSER = await openai_sendUnit.getResult(TDXtoAI);
    // print('AItoUSER: $AItoUSER');
    if (!jsonDecode(AItoUSER)['result']) {
      return error_message;
    }

    return jsonDecode(AItoUSER)['data'];
  }
}

Future<void> main() async {
  
  ApiManager apiManager = ApiManager();

  String inputMessage = " ";
  String outputMessage = await apiManager.getResult(inputMessage);
  print(outputMessage);
}