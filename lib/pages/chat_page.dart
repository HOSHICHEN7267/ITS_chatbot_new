import 'package:its_chatbot/components/message_box.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;

  const ChatPage({super.key, required this.receiverName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController inputController = TextEditingController();

  bool isInputSelf = true; // to delete

  @override
  void initState() {
    super.initState();
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
                          onPressed: () {
                            setState(() {
                              inputController.clear();
                            });
                          },
                        )
                      ],
                    ),
                  )),
            ),
          ],
        ));
  }

  Widget _buildMessageList(double screenHeight) {
    return ListView(
      padding: EdgeInsets.only(
          top: screenHeight * 0.016, bottom: screenHeight * 0.085),
      physics: const BouncingScrollPhysics(),
      children: const [
        MessageBox(isSelf: true, message: "Hello, konnichiwa", time: "15:28"),
        MessageBox(isSelf: false, message: "Hi, nihao", time: "15:29"),
        MessageBox(
            isSelf: true, message: "What's up man I'm Antony", time: "15:30"),
        MessageBox(isSelf: true, message: "Yo, bro M3", time: "15:31"),
        MessageBox(isSelf: false, message: "Damn, you good man", time: "15:32")
      ],
    );
  }

  // Widget _buildMessageItem(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data() as Map<String, dynamic>;

  //   bool self = (data['senderId'] == _auth.currentUser!.uid) ? true : false;

  //   final dateTime = data['timestamp'].toDate();
  //   final timeFormatter = DateFormat('HH:mm');
  //   final formattedTime = timeFormatter.format(dateTime);

  //   return MessageBox(
  //       isSelf: self, message: data['message'], time: formattedTime);
  // }
}
