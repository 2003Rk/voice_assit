import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/featuredBox.dart';
import 'package:voice_assistant/openAIservice.dart';
import 'package:voice_assistant/pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedImageUrl;
  String? generatedContent;
  String? errorMessage;
  bool isContentVisible = false; // Boolean variable to control visibility

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    try {
      await flutterTts.setSharedInstance(true);
      print("Text to Speech initialized");
    } catch (e) {
      print("Error initializing Text to Speech: $e");
    }
  }

  Future<void> initSpeechToText() async {
    try {
      await speechToText.initialize();
      print("Speech to Text initialized");
    } catch (e) {
      print("Error initializing Speech to Text: $e");
    }
  }

  Future<void> startListening() async {
    try {
      await speechToText.listen(onResult: onSpeechResult);
      print("Started listening");
    } catch (e) {
      print("Error starting listening: $e");
    }
  }

  Future<void> stopListening() async {
    try {
      await speechToText.stop();
      print("Stopped listening");
    } catch (e) {
      print("Error stopping listening: $e");
    }
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
    print("Speech result: $lastWords");
  }

  Future<void> systemSpeak(String content) async {
    try {
      await flutterTts.speak(content);
      print("Speaking: $content");
    } catch (e) {
      print("Error speaking: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  Future<void> handleVoiceCommand() async {
    try {
      final speech = await openAIService.isArtPromptAPI(lastWords);
      if (speech.contains("http")) {
        setState(() {
          generatedImageUrl = speech;
          generatedContent = null;
          isContentVisible = false;
        });
      } else {
        setState(() {
          generatedContent = speech;
          generatedImageUrl = null;
          isContentVisible = true;
        });
        await systemSpeak(speech);
      }
    } catch (e) {
      setState(() {
        errorMessage =
            "You exceeded your current quota, please check your plan and billing details.";
        isContentVisible = true;
      });
      print("Error: $e");
      await systemSpeak(errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jarvis"),
        leading: Icon(Icons.menu),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ZoomIn(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage("assets/images/virtualAssistant.png"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              decoration: BoxDecoration(
                border: Border.all(color: Pallete.borderColor),
                borderRadius:
                    BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  generatedContent ??
                      "Good morning, What task can I do for you",
                  style: TextStyle(
                    color: Pallete.mainFontColor,
                    fontFamily: 'Cera pro',
                    fontSize: generatedContent == null ? 25 : 18,
                  ),
                ),
              ),
            ),
          ),
          if (generatedImageUrl != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!)),
            ),
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 10, left: 22),
              alignment: Alignment.centerLeft,
              child: const Text(
                "Here are few features",
                style: TextStyle(
                  fontFamily: 'Cera pro',
                  color: Pallete.mainFontColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child: Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  Featuredbox(
                    color: Pallete.firstSuggestionBoxColor,
                    headertext: 'ChatGpt',
                    descriptionText:
                        'A smarter way to stay organized and informed with ChatGpt',
                  ),
                  Featuredbox(
                    color: Pallete.secondSuggestionBoxColor,
                    headertext: 'Dall-E',
                    descriptionText:
                        'Get inspired and stay creative with your personal assistant powered by Dall-E',
                  ),
                  Featuredbox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headertext: 'Smart voice Assistant',
                    descriptionText:
                        'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGpt',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            startListening();
          } else if (speechToText.isListening) {
            stopListening();
            handleVoiceCommand();
          } else {
            print("No permission or not ready");
          }
        },
        child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
