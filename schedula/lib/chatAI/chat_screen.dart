// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

// void main() async {
//   await dotenv.load(); // Load environment variables
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Chat App',
//       theme: ThemeData(
//         primarySwatch: Colors.pink,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: ChatScreen(),
//     );
//   }
// }

// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> _messages = [
//     {'sender': 'User', 'text': 'Hello!'},
//     {'sender': 'Bot', 'text': 'Hi, how can I help you?'},
//   ];

//   Future<String> getGeminiResponse(String userMessage) async {
//     // Correctly load the API key from the .env file
//     // Assuming your .env file has a key named 'GEMINI_API_KEY'
//     // The hardcoded API key has been removed here to ensure it's loaded from .env
//     final String geminiAPI =
//         dotenv.env['GEMINI_API_KEY'] ??
//         'AIzaSyD18uTjUHvJ-5_sn38ssEdevu9zqTH1Zao';

//     if (geminiAPI.isEmpty) {
//       return 'Error: API key is missing..';
//     }

//     final String url =
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiAPI';

//     final headers = {'Content-Type': 'application/json'};

//     final body = json.encode({
//       "contents": [
//         {
//           "parts": [
//             {"text": userMessage},
//           ],
//         },
//       ],
//     });

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         // Safely access the nested 'text' content from the Gemini API response
//         if (data['candidates'] != null &&
//             data['candidates'].isNotEmpty &&
//             data['candidates'][0]['content'] != null &&
//             data['candidates'][0]['content']['parts'] != null &&
//             data['candidates'][0]['content']['parts'].isNotEmpty &&
//             data['candidates'][0]['content']['parts'][0]['text'] != null) {
//           return data['candidates'][0]['content']['parts'][0]['text'];
//         } else {
//           // Provide more detail if the expected structure is not found
//           return 'No valid response content or candidates found in API response. Response body: ${response.body}';
//         }
//       } else {
//         // Include the response body for better debugging of API errors
//         return 'Error: Unable to fetch response. Status code: ${response.statusCode}. Response body: ${response.body}';
//       }
//     } catch (e) {
//       return 'Error: $e';
//     }
//   }

//   void _sendMessage() async {
//     if (_controller.text.isNotEmpty) {
//       // Add user message to the list
//       setState(() {
//         _messages.add({'sender': 'User', 'text': _controller.text});
//       });

//       // Show a loading indicator or similar while waiting for bot response (optional but good UX)
//       // For simplicity, we'll just add the bot response when it arrives.

//       // Get the bot's response from the Gemini API
//       final botResponse = await getGeminiResponse(_controller.text);

//       // Add bot message to the list
//       setState(() {
//         _messages.add({'sender': 'Bot', 'text': botResponse});
//       });

//       _controller.clear(); // Clear the text field after sending
//     }
//   }

//   Widget _buildMessageBubble(String sender, String message) {
//     bool isUser = sender == 'User';
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       child: Align(
//         alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//           decoration: BoxDecoration(
//             color:
//                 isUser
//                     ? Colors.pink[100] // Light pink for user
//                     : Colors.pink[300], // Darker pink for bot
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 spreadRadius: 1,
//                 blurRadius: 5,
//               ),
//             ],
//           ),
//           child: Text(
//             message,
//             style: TextStyle(
//               color: isUser ? Colors.black : Colors.white,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.pink,
//         title: Text(
//           'Chat with Gemini',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ), // Added white color for better contrast
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 return _buildMessageBubble(
//                   message['sender']!,
//                   message['text']!,
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       hintStyle: TextStyle(color: Colors.pink[200]),
//                       filled: true,
//                       fillColor: Colors.pink[50],
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide.none,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 10,
//                       ), // Adjust padding
//                     ),
//                     onSubmitted: (text) {
//                       _sendMessage(); // Send message when "Enter" is pressed
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   width: 8,
//                 ), // Add some space between text field and button
//                 FloatingActionButton(
//                   onPressed: _sendMessage,
//                   child: Icon(Icons.send, color: Colors.white),
//                   backgroundColor: Colors.pink,
//                   elevation: 2, // Add a slight shadow
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Load environment variables
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'User', 'text': 'Hello!'},
    {'sender': 'Bot', 'text': 'Hi, how can I help you?'},
  ];
  bool _isTyping = false;

  late AnimationController _dotController;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat();
    _dotAnimation = Tween<double>(begin: 0, end: 1).animate(_dotController);
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  Future<String> getGeminiResponse(String userMessage) async {
    final String geminiAPI =
        dotenv.env['GEMINI_API_KEY'] ??
        'AIzaSyD18uTjUHvJ-5_sn38ssEdevu9zqTH1Zao';

    if (geminiAPI.isEmpty) {
      return 'Error: API key is missing.';
    }

    final String url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiAPI';

    final headers = {'Content-Type': 'application/json'};

    final body = json.encode({
      "contents": [
        {
          "parts": [
            {"text": userMessage},
          ],
        },
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty &&
            data['candidates'][0]['content']['parts'][0]['text'] != null) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return 'No valid response content found. Full response: ${response.body}';
        }
      } else {
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userText = _controller.text;

      setState(() {
        _messages.add({'sender': 'User', 'text': userText});
        _controller.clear();
        _isTyping = true;
      });

      final botResponse = await getGeminiResponse(userText);

      setState(() {
        _messages.add({'sender': 'Bot', 'text': botResponse});
        _isTyping = false;
      });
    }
  }

  Widget _buildMessageBubble(String sender, String message) {
    bool isUser = sender == 'User';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: isUser ? Colors.pink[100] : Colors.pink[300],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: MarkdownBody(
            data: message,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: isUser ? Colors.black : Colors.white,
                fontSize: 16,
              ),
              strong: TextStyle(
                color: isUser ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              code: TextStyle(
                color: isUser ? Colors.deepOrange : Colors.yellowAccent,
                fontFamily: 'monospace',
                backgroundColor: Colors.black.withOpacity(0.2),
              ),
              blockquote: TextStyle(
                color: Colors.grey[800],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.pink[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _dotAnimation,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Opacity(
                      opacity:
                          (_dotAnimation.value * 3).floor() == index
                              ? 1.0
                              : 0.2,
                      child: Text(
                        '.',
                        style: TextStyle(fontSize: 26, color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Chat with Gemini',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                return _buildMessageBubble(
                  message['sender']!,
                  message['text']!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.pink[200]),
                      filled: true,
                      fillColor: Colors.pink[50],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send, color: Colors.white),
                  backgroundColor: Colors.pink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
