import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:its_chatbot/pages/chat_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // To let systemChrome get to work

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) {
        final FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Chat APP',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              primary: Colors.white,
              secondary: const Color.fromARGB(255, 231, 230, 230),
              tertiary: const Color.fromARGB(255, 147, 230, 150)),
          useMaterial3: true,
        ),
        home: const ChatPage(receiverName: '(✪ω✪)'),
      ),
    );
  }
}
