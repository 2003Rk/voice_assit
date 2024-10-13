import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_assistant/secerts.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": 'application/json',
          "Authorization": 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-16k",
          "messages": [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anything similar? $prompt Simply answer with yes or no.',
            }
          ],
        }),
      );
      print(res.body);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content
            .trim()
            .toLowerCase(); // Normalize the content for comparison
        switch (content) {
          case 'yes':
          case 'yes.':
            return await dallEAPI(
                prompt); // Call DALL-E API if the answer is 'yes'
          default:
            return await chatGPTAPI(prompt); // Call ChatGPT API otherwise
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          "Content-Type": 'application/json',
          "Authorization": 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['data'][0]['url'];
        content = content.trim();
        messages.add({
          'role': 'assistant',
          'content': content,
        });
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": 'application/json',
          "Authorization": 'Bearer $openAIAPIKEY',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-16k",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        imageUrl = imageUrl.trim();
        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
