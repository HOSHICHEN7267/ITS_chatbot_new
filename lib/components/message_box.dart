import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageBox extends StatelessWidget {
  final bool isSelf;
  final String message;
  final String time;

  const MessageBox(
      {super.key,
      required this.isSelf,
      required this.message,
      required this.time});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (isSelf) {
      return Padding(
          padding: EdgeInsets.all(screenWidth * 0.036),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(time,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: screenWidth * 0.031,
                      fontWeight: FontWeight.w200)),
              SizedBox(
                width: screenWidth * 0.012,
              ),
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.036),
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.655,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                    ),
                    child: MarkdownBody(
                      data: message,
                      styleSheet: MarkdownStyleSheet(
                          textScaler: const TextScaler.linear(1.25)),
                    ),
                    // child: Text(message,
                    //     style: TextStyle(
                    //         color: Colors.black,
                    //         fontSize: screenWidth * 0.045)),
                  ),
                ],
              ),
            ],
          ));
    } else {
      return Padding(
          padding: EdgeInsets.all(screenWidth * 0.036),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.account_circle_rounded,
                  color: Colors.black,
                  size: screenWidth * 0.145,
                ),
                SizedBox(
                  width: screenWidth * 0.012,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.036),
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.655,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15.0),
                            ),
                          ),
                          child: MarkdownBody(
                            data: message,
                            styleSheet: MarkdownStyleSheet(
                                textScaler: const TextScaler.linear(1.25)),
                          ),
                          // child: Text(message,
                          //     style: TextStyle(
                          //         color: Colors.black,
                          //         fontSize: screenWidth * 0.045)),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: screenWidth * 0.008,
                    ),
                    Text(time,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: screenWidth * 0.031,
                            fontWeight: FontWeight.w200)),
                  ],
                ),
              ]));
    }
  }
}
