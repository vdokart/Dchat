import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// const String loginPageTitle = 'dChat // Login page';

// Login page';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text.trim();
                final password = _passwordController.text.trim();
                if (username.isNotEmpty && password.isNotEmpty) {
                  await loginUser(context, username, password);
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registration');
              },
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> loginUser(
    BuildContext context, String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('https://chat.vdokart.in/login.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    final responseData = json.decode(response.body);
    print(response.body);
    if (responseData['success']) {
      // Save user data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('password', password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
      // Navigate to text generation settings screen
      Navigator.pushReplacementNamed(context, '/text_generation_settings');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${responseData['message']}')),
      );
    }
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error logging in')),
    );
  }
}
