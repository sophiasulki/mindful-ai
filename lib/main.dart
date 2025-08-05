import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindful AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Mindful AI'),
      routes: {
        '/ai_chat': (context) => const AIChatScreen(),
        '/activities': (context) => const ActivitiesScreen(),
        '/meditation': (context) => const MeditationScreen(),
        '/focus_mode': (context) => const FocusModeScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Mindful AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your Mindful Companion',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.chat_bubble_outline),
              title: Text('AI Chat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ai_chat');
              },
            ),
            ListTile(
              leading: Icon(Icons.event_note),
              title: Text('Activities'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/activities');
              },
            ),
            ListTile(
              leading: Icon(Icons.self_improvement),
              title: Text('Meditation'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/meditation');
              },
            ),
            ListTile(
              leading: Icon(Icons.center_focus_strong),
              title: Text('Focus Mode'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/focus_mode');
              },
            ),
            ListTile(
              leading: Icon(Icons.show_chart),
              title: Text('Progress'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/progress');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.deepPurple.shade100, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Welcome to your Mindful Companion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hi! I'm your Mindful AI. How can I support your mental well-being today?",
      isUser: false,
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Gemini API key
  static const String _apiKey = 'AIzaSyBhXvDmckHn3fg8wjcw2cPjSnWOxrImI-k';

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();
    final aiResponse = await _getGeminiResponse(text);
    await _typeAIResponse(aiResponse);
    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  Future<void> _typeAIResponse(String fullText) async {
    String displayed = '';
    for (int i = 0; i < fullText.length; i++) {
      displayed += fullText[i];
      setState(() {
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.removeLast();
        }
        _messages.add(_ChatMessage(text: displayed, isUser: false));
      });
      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 18));
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<String> _getGeminiResponse(String userInput) async {
    // Uses Gemini Pro API (text-only)
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent');
    final headers = {'Content-Type': 'application/json', 'X-Goog-Api-Key': _apiKey};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "You are a supportive mental health assistant. Respond with empathy, encouragement, and practical mental health tips. User: $userInput"}
          ]
        }
      ]
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return "Sorry, the AI service returned an empty response. Please try again.";
        }
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null && text is String && text.trim().isNotEmpty) {
          return text.trim();
        } else {
          return "Sorry, I couldn't understand. Could you rephrase or try again?";
        }
      } else if (response.body.isEmpty) {
        return "Sorry, the AI service returned an empty response. Please try again.";
      } else {
        return "Sorry, there was a problem connecting to the AI service.";
      }
    } catch (e) {
      return "Sorry, there was a network error. Please try again.";
    }
  }

  // _getAIResponse removed; now using _getGeminiResponse

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.deepPurple.shade100, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(),
                ),
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...'
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        enabled: !_isLoading,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activities')),
      body: const Center(child: Text('Activities feature coming soon!')),
    );
  }
}

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meditation')),
      body: const Center(child: Text('Meditation feature coming soon!')),
    );
  }
}

class FocusModeScreen extends StatelessWidget {
  const FocusModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Mode')),
      body: const Center(child: Text('Focus Mode feature coming soon!')),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: const Center(child: Text('Progress feature coming soon!')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings feature coming soon!')),
    );
  }
}
