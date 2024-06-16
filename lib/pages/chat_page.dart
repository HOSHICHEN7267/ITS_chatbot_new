import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:its_chatbot/components/message_box.dart';
import 'package:its_chatbot/model/message.dart';
import 'package:its_chatbot/services/apiManager.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;

  const ChatPage({super.key, required this.receiverName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ApiManager _apiManager = ApiManager();

  // For textfield focus (auto scroll when keyboard shows up)
  FocusNode textFieldFocusNode = FocusNode();

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

    // Add a listener to focus node
    textFieldFocusNode.addListener(() {
      if (textFieldFocusNode.hasFocus) {
        // Scroll down the listview automatically
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // When entering the chat room, scroll down the listview too
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());

    // Add initial message (welcome message)
    String formattedDate = DateFormat('HH:mm').format(DateTime.now());
    messageList.add(
        Message(isSelf: false, message: initMessage, timestamp: formattedDate));
  }

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
  }

  // Send message and pass to api manager
  void sendMessage() {
    String text = _inputController.text;

    if (text.isNotEmpty) {
      String formattedDate = DateFormat('HH:mm').format(DateTime.now());

      setState(() {
        isGeneratingResponse = true;
        messageList.add(
            Message(isSelf: true, message: text, timestamp: formattedDate));
        _inputController.clear();
      });

      // Scroll down the listview after sending new message
      Future.delayed(const Duration(milliseconds: 500), () => scrollDown());

      askQuestion(text);
    }
  }

  // Pass question to api manager and wait for response
  void askQuestion(String question) async {
    String result = await _apiManager.getResult(question);

    if (result.isNotEmpty) {
      String formattedDate = DateFormat('HH:mm').format(DateTime.now());
      Map<String, dynamic> response = jsonDecode(result);
      String outputMessage = response['data'];

      if (response['result']) {
        outputMessage = "$outputMessage 😎";
      } else {
        outputMessage = "$outputMessage 🥺";
      }

      setState(() {
        messageList.add(Message(
            isSelf: false, message: outputMessage, timestamp: formattedDate));
        isGeneratingResponse = false;
      });
    }

    // Scroll down the listview after sending new message
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildMessageList(screenHeight),
          _buildInputBox(screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildMessageList(double screenHeight) {
    return Expanded(
      child: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.only(top: screenHeight * 0.016),
        physics: const ClampingScrollPhysics(),
        children: messageList
            .map((message) => MessageBox(
                isSelf: message.isSelf,
                message: message.message,
                time: message.timestamp))
            .toList(),
      ),
    );
  }

  Widget _buildInputBox(double screenWidth, double screenHeight) {
    return Container(
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
                  color: const Color.fromARGB(255, 219, 219, 219), width: 3.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: screenWidth * 0.024,
              ),
              Expanded(
                  child: TextField(
                focusNode: textFieldFocusNode,
                minLines: 1,
                maxLines: 6,
                controller: _inputController,
                keyboardType: TextInputType.multiline,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: screenWidth * 0.049, height: 1),
                cursorColor: Colors.black,
                cursorWidth: 2.5,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: isGeneratingResponse
                        ? "Generating response..."
                        : "Input message here",
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 173, 173, 173),
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.normal),
                    border: InputBorder.none),
              )),
              IconButton(
                icon: const Icon(Icons.send),
                iconSize: screenWidth * 0.056,
                color: const Color.fromARGB(255, 138, 138, 138),
                onPressed: isGeneratingResponse ? null : () => sendMessage(),
              )
            ],
          ),
        ));
  }
}
