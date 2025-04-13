import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceModePage extends StatefulWidget {
  final String id;
  final String name;

  const VoiceModePage({super.key, required this.id, required this.name});

  @override
  State<VoiceModePage> createState() => _VoiceModePageState();
}

class _VoiceModePageState extends State<VoiceModePage> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  final String apiKey = "R2Xu4hzvwm69SkPBBDQTg2KI8p011F6ETJq7npuU";
  final String apiUrl = "https://api.cohere.ai/v1/chat";

  bool _isSpeaking = false;
  bool _isListening = false;
  String recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _startAssistant();
  }

  Future<void> _initializeTTS() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.45);
      await flutterTts.setPitch(1.0);
      await flutterTts.setVolume(1.0);
      await flutterTts.setEngine("com.google.android.tts");

      flutterTts.setStartHandler(() {
        print("🎙 TTS started");
        if (mounted) setState(() => _isSpeaking = true);
      });

      flutterTts.setCompletionHandler(() {
        print("🔄 TTS completed");
        _onTTSComplete();
      });

      flutterTts.setErrorHandler((msg) {
        print("❗ TTS Error: $msg");
        if (mounted) {
          setState(() => _isSpeaking = false);
          _initializeTTS().then((_) => _listen());
        }
      });

      flutterTts.setCancelHandler(() {
        print("🚫 TTS cancelled");
        if (mounted) setState(() => _isSpeaking = false);
      });

      final engines = await flutterTts.getEngines;
      print("🛠 Available TTS engines: $engines");
    } catch (e) {
      print("❌ TTS init error: $e");
    }
  }

  Future<void> _startAssistant() async {
    String greeting = "Greetings sir, I am Arise — designed to assist you. I am ready now.";
    await speakSafely(greeting);
  }

  void _onTTSComplete() {
    if (!mounted) return;
    setState(() => _isSpeaking = false);

    if (!_isListening) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!_isSpeaking && mounted) {
          print("🔄 Resuming listening after TTS");
          _listen();
        }
      });
    }
  }

  Future<void> speakSafely(String text) async {
    try {
      if (text.trim().isEmpty) {
        print("🚫 Empty text, skipping speak");
        return;
      }

      // Clean up emoji or invalid chars
      final cleanedText = text.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
      final chunks = cleanedText.split(RegExp(r'(?<=[.!?])\s+'));
      print("📜 Speaking ${chunks.length} chunks: $chunks");
      for (var chunk in chunks) {
        if (chunk.trim().isEmpty) continue;
        print("🎙 Speaking chunk: '$chunk'");
        await flutterTts.speak(chunk.trim());
        await flutterTts.awaitSpeakCompletion(true);
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    } catch (e) {
      print("❌ TTS speak error: $e");
      if (mounted) {
        setState(() => _isSpeaking = false);
        _initializeTTS();
      }
    }
  }

  Future<void> _listen() async {
    try {
      if (_isSpeaking) {
        print("🚫 Skipping listen: TTS is speaking");
        return;
      }

      bool available = await speech.initialize(
        onStatus: (status) {
          print("🎙 STT status: $status");
          if (status == "done" || status == "notListening") {
            print("🔄 STT status '$status' — restarting listening...");
            if (mounted && !_isSpeaking) {
              Future.delayed(const Duration(milliseconds: 1000), _listen);
            }
          }
        },
        onError: (error) {
          print("❗ STT error: $error");
          if (mounted && !_isSpeaking) {
            Future.delayed(const Duration(seconds: 1), _listen);
          }
        },
      );

      if (available && mounted && !_isSpeaking) {
        setState(() {
          _isListening = true;
          recognizedText = "Listening...";
        });

        speech.listen(
          onResult: (result) {
            if (result.finalResult && mounted) {
              setState(() {
                recognizedText = result.recognizedWords;
                _isListening = false;
              });
              print("🎤 Recognized: '${result.recognizedWords}'");
              speech.stop();
              _sendMessageToCohere(result.recognizedWords);
            }
          },
        );
      } else {
        print("🚫 STT unavailable or app is speaking");
      }
    } catch (e) {
      print("❌ Error initializing STT: $e");
      if (mounted && !_isSpeaking) {
        Future.delayed(const Duration(seconds: 1), _listen);
      }
    }
  }

  Future<List<String>> fetchMemories(String userId) async {
    print("📚 Fetching memories for user: $userId");
    final memoryRef = FirebaseFirestore.instance
        .collection("ai_chats")
        .doc(userId)
        .collection("memories");

    final snapshot = await memoryRef.get();
    final rawMemories = snapshot.docs.map((doc) => doc.data()['text']).toList();
    print("📜 Raw Firestore memories: $rawMemories");
    final validMemories = rawMemories.where((m) => m != null).map((m) => m.toString()).toList();
    print("✅ Filtered memories: $validMemories");
    return validMemories;
  }

  Future<void> _sendMessageToCohere(String message) async {
    if (!mounted || _isSpeaking || _isListening) {
      print("🚫 Skipped Cohere request: mounted=$mounted, isSpeaking=$_isSpeaking, isListening=$_isListening");
      return;
    }

    setState(() {
      _isSpeaking = true;
      _isListening = false;
    });

    try {
      print("📩 Message to send: '$message'");
      final memories = await fetchMemories(widget.id);
      final memoryContext = memories.isNotEmpty
          ? """Here are things ${widget.name} told you in the past. Use this info when needed, without reminding them you're storing data:\n${memories.map((m) => "- $m").join("\n")}"""
          : "";
      print("🧠 Memory context: '$memoryContext'");

      final preamble =
          "$memoryContext You're a chill AI buddy named Arise, talking to ${widget.name}. Respond in a normal, casual tone. Make it short, user doesn’t like long answers.";
      print("📜 Preamble sent to API: '$preamble'");

      print("🌐 Sending request to Cohere with message: '$message'");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": message,
          "preamble": preamble,
        }),
      );

      print("📬 API status code: ${response.statusCode}");
      print("📝 Raw API response: '${response.body}'");

      String reply = "Sorry, no valid response.";

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 Decoded API response: $data");
        if (data is Map<String, dynamic>) {
          final text = data['text'];
          if (text is String && text.isNotEmpty) {
            reply = text;
            print("✅ Extracted 'text': '$reply'");
          }
        }
      } else {
        print("⚠️ Cohere API Error: ${response.statusCode} - ${response.body}");
        reply = "Sorry, there was a server issue.";
      }

      reply = reply.trim();
      if (reply.isEmpty) reply = "Sorry, I didn't catch that.";

      if (mounted) {
        setState(() => recognizedText = "");
      } else {
        print("🚫 Skipping setState for recognizedText: Widget disposed");
      }

      await speakSafely(reply);
    } catch (e) {
      print("❌ Error during _sendMessageToCohere: $e");
      print("📜 Stack trace: ${StackTrace.current}");
      await speakSafely("Oops, something went wrong.");
    }

    if (mounted) {
      setState(() => _isSpeaking = false);
    } else {
      print("🚫 Skipping final setState: Widget disposed");
    }
  }

  @override
  void dispose() {
    print("🗑 Disposing VoiceModePage, isSpeaking: $_isSpeaking, isListening: $_isListening");
    try {
      speech.stop();
      // Don't stop TTS to avoid cutting speech
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSpeaking) {
          print("🚫 Blocking back navigation: TTS is speaking");
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: const Text(
            "Arise",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "MinervaModern",
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              print("🔙 Back button pressed, isSpeaking: $_isSpeaking");
              if (!_isSpeaking) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: GestureDetector(
          onTap: () {
            print("🖱 Screen tapped, isSpeaking: $_isSpeaking");
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Lottie.asset(
                  'assets/animations/test.json',
                  height: 250,
                  width: 250,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isSpeaking
                    ? "Arise is speaking..."
                    : _isListening
                        ? "Listening..."
                        : "",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              if (!_isSpeaking)
                Text(
                  recognizedText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

