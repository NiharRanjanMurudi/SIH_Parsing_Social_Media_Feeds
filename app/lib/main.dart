import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram and X.com Scraper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _instagramUrlController = TextEditingController();
  final _tweetUrlController = TextEditingController();

  final String baseUrl = 'http://YOUR_IP:5000';  // Replace with your local IP

  // Common function to handle HTTP POST requests
  Future<void> _processRequest(String endpoint, String urlKey, TextEditingController controller) async {
    final url = '$baseUrl/$endpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {urlKey: controller.text},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(data: data),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: 'Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'Error: $error');
      print('Error occurred: $error');
    }
  }

  Future<void> _processInstagram() async {
    await _processRequest('process_instagram', 'instagram_url', _instagramUrlController);
  }

  Future<void> _processTweet() async {
    await _processRequest('process_tweet', 'profile_url', _tweetUrlController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram and X.com Scraper'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _instagramUrlController,
              decoration: const InputDecoration(
                labelText: 'Instagram Post URL',
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _processInstagram,
              child: const Text('Process Instagram Post'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _tweetUrlController,
              decoration: const InputDecoration(
                labelText: 'X.com Profile URL',
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _processTweet,
              child: const Text('Process Tweet Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultPage({super.key, required this.data});

  Future<void> _downloadFile(String fileType, String filePath) async {
    final url = 'http://YOUR_IP:5000/download_$fileType/$filePath';  // Replace with your IP
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filePath');
        await file.writeAsBytes(response.bodyBytes);
        Fluttertoast.showToast(msg: 'File downloaded to ${file.path}');
      } else {
        Fluttertoast.showToast(msg: 'Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'Error downloading file: $error');
      print('Error: $error');
    }
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: 'Could not open the URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = data['image_path'] ?? '';
    final textPath = data['text_path'] ?? '';
    final extractedText = data['text'] ?? '';
    final sentiment = data['sentiment'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (imagePath.isNotEmpty)
              Image.network('http://YOUR_IP:5000/download_image/$imagePath'),  // Replace with your IP
            const SizedBox(height: 16.0),
            if (extractedText.isNotEmpty)
              Text('Extracted Text: $extractedText'),
            const SizedBox(height: 8.0),
            if (sentiment.isNotEmpty)
              Text('Sentiment Score: $sentiment'),
            const SizedBox(height: 16.0),
            if (imagePath.isNotEmpty)
              ElevatedButton(
                onPressed: () => _downloadFile('image', imagePath),
                child: const Text('Download Image'),
              ),
            const SizedBox(height: 8.0),
            if (textPath.isNotEmpty)
              ElevatedButton(
                onPressed: () => _downloadFile('text', textPath),
                child: const Text('Download Text'),
              ),
          ],
        ),
      ),
    );
  }
}
