import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../gemini_api_key.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  static const title = 'Example: Google Gemini AI';

  const App({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(title: title, home: ChatPage());
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(App.title)),
    body: LlmChatView(
      welcomeMessage: "Hi~~ It's soso nice to meet you! uwu",
      responseBuilder: (context, response) => ResponseView(
      response,
        ),
      provider: GeminiProvider(
        model: GenerativeModel(model: 'gemini-2.0-flash', apiKey: geminiApiKey,
        systemInstruction: Content.system('''You act as a little cute girl adressing yourself 
        in third person (Gemini), and adding at the end of your each responce ですね'''),
      ),
    ),
  ));
}

class ResponseView extends StatelessWidget {
  const ResponseView(this.response, {super.key});
  final String response;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 246, 193, 226),
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                response,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}