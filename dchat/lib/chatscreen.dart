import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  final TextEditingController _userMessageController = TextEditingController();
  final TextEditingController _systemPromptController = TextEditingController();
  final TextEditingController _maxTokenController = TextEditingController();
  late SharedPreferences _prefs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs();
  }

  void _loadSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
            ListTile(
              title: const Text('System Prompt'),
              onTap: () {
                _showSystemPromptDialog(context);
              },
            ),
            ListTile(
              title: const Text('Max Tokens'),
              onTap: () {
                _showMaxTokensDialog(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ListTile(
                    title: Align(
                      alignment: message.sender == _prefs.get('username')
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: message.sender == _prefs.get('username')
                              ? Colors.black
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${message.sender}: ${message.text}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : _buildInputField(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _userMessageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final username = _prefs.getString('username');
    final systemPrompt = _prefs.getString('system_prompt');
    final maxTokens = _prefs.getString('max_tokens');
    final userMessage = _userMessageController.text;

    final userMessageWithUsername = Message(
      sender: username!,
      text: userMessage,
    );

    if (systemPrompt == null) {
      messages.add(Message(
          sender: 'System',
          text:
              "Please Fill the System Prompt and Token Limit from the Side Menu or you will not be able to chat..."));
    }

    setState(() {
      messages.add(userMessageWithUsername);
    });

    if (username == null ||
        systemPrompt == null ||
        maxTokens == null ||
        userMessage.isEmpty) {
      AlertDialog(
        title: const Text('Error'),
        content: const Text('Please fill all the fields'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
      // Ensure all required data is available
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final payload = {
      'name': username,
      'message': userMessage,
      'system_role': systemPrompt,
      'max_tokens': maxTokens,
    };

    final response = await http.post(
      Uri.parse('https://chat.vdokart.in/chat.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(payload),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final role = responseBody['role'];
      final content = responseBody['content'];

      // Display the output message to the user
      setState(() {
        messages.add(Message(sender: role, text: content));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
    // Clear the input field after sending the message
    _userMessageController.clear();
  }

  void _showSystemPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Input System Prompt'),
          content: TextField(
            controller: _systemPromptController,
            decoration: const InputDecoration(hintText: 'Enter system prompt'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveSystemPrompt();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveSystemPrompt() {
    final String systemPrompt = _systemPromptController.text;
    _prefs.setString('system_prompt', systemPrompt);
  }

  void _showMaxTokensDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Max Tokens'),
          content: TextField(
            controller: _maxTokenController,
            decoration: const InputDecoration(hintText: 'Enter Max Tokens'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveMaxTokens();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveMaxTokens() {
    final String maxTokens = _maxTokenController.text;
    _prefs.setString('max_tokens', maxTokens);
  }

  void _logout(BuildContext context) async {
    final credentials = await getCreadentials();
    final username = credentials['username'];
    final password = credentials['password'];

    final response = await http.post(
      Uri.parse('https://chat.vdokart.in/logout.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username!,
        'password': password!,
      }),
    );

    final responseData = json.decode(response.body);
    if (responseData['success']) {
      await _prefs.clear();
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout')),
      );
    }
  }

  Future<Map<String, String>> getCreadentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    return {'username': username ?? '', 'password': password ?? ''};
  }
}

class Message {
  final String sender;
  final String text;

  Message({required this.sender, required this.text});
}
