import 'dart:math';

import 'package:dchat/chatscreen.dart';
import 'package:dchat/dbservice.dart';
import 'package:flutter/material.dart';

class TextGenerationSettingsScreen extends StatefulWidget {
  const TextGenerationSettingsScreen({Key? key}) : super(key: key);

  @override
  _TextGenerationSettingsScreenState createState() =>
      _TextGenerationSettingsScreenState();
}

class _TextGenerationSettingsScreenState
    extends State<TextGenerationSettingsScreen> {
  double temperature = 0.7;
  double topP = 0.9;
  int maxTokens = 512;
  int numResponses = 1;
  double presencePenalty = 0.0;
  double frequencyPenalty = 0.0;
  List<String> stopSequences = [];
  TextEditingController modelNameController = TextEditingController();
  TextEditingController systemPromptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Generation Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TextField(
            //   controller: modelNameController,
            //   decoration: const InputDecoration(
            //     labelText: 'Model Name',
            //     hintText: 'Enter model name',
            //   ),
            // ),
            // const SizedBox(height: 16),
            TextField(
              controller: systemPromptController,
              decoration: const InputDecoration(
                labelText: 'System Prompt',
                hintText: 'Enter system prompt',
              ),
            ),
            const SizedBox(height: 16),
            _buildSlider(
              label: 'Temperature',
              value: temperature,
              onChanged: (value) {
                setState(() {
                  temperature = value;
                });
              },
            ),
            _buildSlider(
              label: 'Top P',
              value: topP,
              onChanged: (value) {
                setState(() {
                  topP = value;
                });
              },
            ),
            _buildTextField(
              label: 'Max Tokens',
              value: maxTokens.toString(),
              onChanged: (value) {
                setState(() {
                  maxTokens = int.parse(value);
                });
              },
            ),
            _buildTextField(
              label: 'Number of Responses',
              value: numResponses.toString(),
              onChanged: (value) {
                setState(() {
                  numResponses = int.parse(value);
                });
              },
            ),
            _buildTextField(
              label: 'Presence Penalty',
              value: presencePenalty.toString(),
              onChanged: (value) {
                setState(() {
                  presencePenalty = double.parse(value);
                });
              },
            ),
            _buildTextField(
              label: 'Frequency Penalty',
              value: frequencyPenalty.toString(),
              onChanged: (value) {
                setState(() {
                  frequencyPenalty = double.parse(value);
                });
              },
            ),
            // _buildStopSequenceInput(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _insertParameters(); // Insert parameters into the database
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatScreen(),
                  ),
                ); // Navigate to chat screen
              },
              child: const Text('Let\'s Chat!'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
      {required String label,
      required double value,
      required ValueChanged<double> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          label: value.toString(),
        ),
      ],
    );
  }

  Widget _buildTextField(
      {required String label,
      required String value,
      required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: value,
          ),
        ),
      ],
    );
  }

  Widget _buildStopSequenceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stop Sequences'),
        TextField(
          onChanged: (value) {
            setState(() {
              stopSequences = value.split(',');
            });
          },
          decoration: const InputDecoration(
            hintText: 'Enter stop sequences separated by comma (,)',
          ),
        ),
      ],
    );
  }

  Future<void> _insertParameters() async {
    final parameter = Parameter(
      id: Random().nextInt(
          1000000), // You can set an ID or generate one based on your logic
      temperature: temperature,
      topP: topP,
      maxTokens: maxTokens,
      numResponses: numResponses,
      presencePenalty: presencePenalty,
      frequencyPenalty: frequencyPenalty,
      stopSequences:
          stopSequences.join(','), // Convert list to comma-separated string
      systemPrompt: systemPromptController.text,
    );

    await ParameterService().insertParameter(parameter);

    print(await ParameterService().getParameters());
  }
}
