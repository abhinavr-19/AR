import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text-to-Image Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TextToImageScreen(),
    );
  }
}

class TextToImageScreen extends StatefulWidget {
  @override
  _TextToImageScreenState createState() => _TextToImageScreenState();
}

class _TextToImageScreenState extends State<TextToImageScreen> {
  final TextEditingController _promptController = TextEditingController();
  double _guidanceScale = 7.5;
  String _imageUrl = '';
  bool _isLoading = false;

  Future<void> _generateImage() async {
    setState(() {
      _isLoading = true;
    });

    final String prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prompt cannot be empty!')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String apiUrl = 'http://<your-ip>:5000/generate'; // Replace with your backend IP
    final Map<String, dynamic> requestBody = {
      'prompt': prompt,
      'guidance_scale': _guidanceScale,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _imageUrl = responseData['image'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text-to-Image Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: 'Enter Image Prompt',
                hintText: 'e.g., A beautiful place in Kerala',
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),
            Text('Guidance Scale: ${_guidanceScale.toStringAsFixed(1)}'),
            Slider(
              value: _guidanceScale,
              min: 5.0,
              max: 15.0,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  _guidanceScale = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateImage,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Generate Image'),
            ),
            SizedBox(height: 20),
            if (_imageUrl.isNotEmpty)
              Image.memory(
                base64Decode(_imageUrl),
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}
