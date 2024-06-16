import 'dart:convert';
import 'openai_receiveUnit.dart' as openai_receiveUnit;
import 'mapUnit.dart' as mapUnit;
import 'tdxUnit.dart.';
import 'openai_sendUnit.dart' as openai_sendUnit;

class ApiManager{

  TdxUnit tdxUnit = TdxUnit();

  Future<String> getResult(String inputString) async {
    // String error_message = "抱歉，我有點看不懂QQ\n要再麻煩你告訴我一次你的起點、目的地，以及希望省錢還是省時間喔！";
    
    if (inputString.length > 200) {
      return "抱歉，你的訊息有點太長了，我小小的腦袋裝不下QQ\n可以麻煩你用簡短的文字告訴我，你的起點、目的地，以及希望省錢還是省時間嗎？";
    }

    String AItoMAP = await openai_receiveUnit.getResult(inputString);
    // print('AItoMAP: $AItoMAP');
    if (!jsonDecode(AItoMAP)['result']) {
      return jsonEncode({
        'result': false, 
        'data': '抱歉，我沒有聽懂你的起點及目的地，分別在哪裡QQ\n可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'}
      );
    }

    String MAPtoTDX = await mapUnit.getResult(AItoMAP);
    // print('MAPtoTDX: $MAPtoTDX');
    if (!jsonDecode(MAPtoTDX)['result']) {
      return jsonEncode({
        'result': false, 
        'data': '抱歉，你的起點及目的地，似乎有無法在地圖上搜尋到的地方QQ\n可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'}
      );
    }

    String TDXtoAI = await tdxUnit.getResult(MAPtoTDX);
    // print('TDXtoAI: $TDXtoAI');
    // print('TDXtoAI: Received');
    if (!jsonDecode(TDXtoAI)['result']) {
      return jsonEncode({
        'result': false, 
        'data': '抱歉，我只會規劃台灣境內的交通路線，如果你要出國的話，我就無法給你幫助了QQ\n如果你還想去其他台灣地點的話，可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'}
      );
    }

    String AItoUSER = await openai_sendUnit.getResult(TDXtoAI);
    // print('AItoUSER: $AItoUSER');
    if (!jsonDecode(AItoUSER)['result']) {
      return jsonEncode({
        'result': false, 
        'data': '抱歉，小幫手在產生交通路線時，出了一點問題QQ\n可以再告訴我一次：你的起點、目的地，以及希望省錢還是省時間嗎？'}
      );
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

  print(outputMessage);
}