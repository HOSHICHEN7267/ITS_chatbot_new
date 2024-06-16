import 'package:intl/intl.dart';
import 'package:its_chatbot/components/message_box.dart';
import 'package:its_chatbot/model/message.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;

  const ChatPage({super.key, required this.receiverName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController inputController = TextEditingController();

  // State management
  List<Message> messageList = [];
  bool isGeneratingResponse = false;

  String initMessage = '''哈囉你好哇！🤗

我是最懂你的(✪ω✪)智能路線規劃小幫手

想去台灣的哪裡呀？

簡單的告訴我出發地點及目的地，我就能幫你找到適合的交通傳承方式喔！😎

如果有比較想省錢、或是省時間，也可以一起跟我說唷 (⁠｡⁠•̀⁠ᴗ⁠-⁠)⁠✧
''';

  @override
  void initState() {
    super.initState();
    String formattedDate = DateFormat('HH:mm').format(DateTime.now());
    messageList.add(
        Message(isSelf: false, message: initMessage, timestamp: formattedDate));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            widget.receiverName,
            style: TextStyle(fontSize: screenWidth * 0.047),
          ),
          centerTitle: true,
          shape: const Border(bottom: BorderSide(color: Colors.grey, width: 3)),
        ),
        body: Stack(
          children: <Widget>[
            _buildMessageList(screenHeight),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.07,
                  color: Theme.of(context).colorScheme.primary,
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: screenHeight * 0.055,
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color.fromARGB(255, 219, 219, 219),
                            width: 3.5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: screenWidth * 0.024,
                        ),
                        Expanded(
                            child: TextField(
                          minLines: 1,
                          maxLines: 6,
                          controller: inputController,
                          keyboardType: TextInputType.multiline,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: screenWidth * 0.049, height: 1),
                          cursorColor: Colors.black,
                          cursorWidth: 2.5,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(0.0),
                              hintText: "Input message here",
                              hintStyle: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 173, 173, 173),
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.normal),
                              border: InputBorder.none),
                        )),
                        IconButton(
                          icon: const Icon(Icons.send),
                          iconSize: screenWidth * 0.056,
                          color: const Color.fromARGB(255, 138, 138, 138),
                          onPressed: isGeneratingResponse
                              ? null
                              : () {
                                  String text = inputController.text;

                                  if (text.isNotEmpty) {
                                    String formattedDate = DateFormat('HH:mm')
                                        .format(DateTime.now());

                                    setState(() {
                                      isGeneratingResponse = true;
                                      messageList.add(Message(
                                          isSelf: true,
                                          message: text,
                                          timestamp: formattedDate));
                                      inputController.clear();
                                    });

                                    _askQuestion(text);
                                  }
                                },
                        )
                      ],
                    ),
                  )),
            ),
          ],
        ));
  }

  void _askQuestion(String question) async {
    String result = "This is the result";

    await Future.delayed(const Duration(seconds: 5), () {
      if (result.isNotEmpty) {
        String formattedDate = DateFormat('HH:mm').format(DateTime.now());
        setState(() {
          messageList.add(Message(
              isSelf: false, message: result, timestamp: formattedDate));
          isGeneratingResponse = false;
        });
      }
    });
  }

  Widget _buildMessageList(double screenHeight) {
    return ListView(
      padding: EdgeInsets.only(
          top: screenHeight * 0.016, bottom: screenHeight * 0.085),
      physics: const BouncingScrollPhysics(),
      children: messageList
          .map((message) => MessageBox(
              isSelf: message.isSelf,
              message: message.message,
              time: message.timestamp))
          .toList(),
    );
  }
}
