import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
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
                final name = _nameController.text.trim();
                final username = _usernameController.text.trim();
                final password = _passwordController.text.trim();
                if (name.isNotEmpty &&
                    username.isNotEmpty &&
                    password.isNotEmpty) {
                  print(
                      "Name: $name, Username: $username, Password: $password");
                  await registerUser(context, name, username, password);
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> registerUser(
    BuildContext context, String name, String username, String password) async {
  try {
    final Map<String, String> requestBody = {
      'name': name,
      'username': username,
      'password': password,
    };

    // Convert request body to JSON string
    String requestBodyJson = json.encode(requestBody);

    // Set content type header to application/json
    final response = await http.post(
      Uri.parse('https://chat.vdokart.in/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: requestBodyJson,
    );

    print(response.body);

    final responseData = json.decode(response.body);
    if (responseData['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );
      // Navigate back to login page
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Registration failed: ${responseData['message']}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error registering user')),
    );
  }
}
