import 'package:flutter/material.dart';
import 'package:mobile_frontend/screens/aihome.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:developer' as developer;
import 'dart:ui'; // For blur effect
import 'package:lottie/lottie.dart'; // For animation
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class Hiddenarise extends StatefulWidget {
  final String userId;

  const Hiddenarise({required this.userId, super.key});

  @override
  State<Hiddenarise> createState() => _AriseAiState();
}

class _AriseAiState extends State<Hiddenarise> {
  late stt.SpeechToText _speech;
  String _text = "Listening...";
  final String _hotword = "arise";
  bool _hotwordDetected = false;
  String _fullTranscript = "";
  bool _isListening = false;
  Map<String, dynamic>? _userInfo; // To store user info
bool _isLoading = true; // Track Firestore loading
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _fetchUserInfo(); // Fetch user info first
    _startListening(); // Then start listening
  }

  Future<void> _fetchUserInfo() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('user_details')
          .doc(widget.userId)
          .collection('details')
          .doc('user_info')
          .get();

      if (doc.exists) {
        setState(() {
          _userInfo = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userInfo = {'error': 'No user info found'};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userInfo = {'error': 'Failed to load: $e'};
        _isLoading = false;
      });
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        developer.log("Speech Status: $status");
        if (status == "notListening" && _isListening && mounted && !_hotwordDetected) {
          _restartListening();
        }
      },
      onError: (error) {
        developer.log("Speech Error: $error");
        if (_isListening && mounted && !_hotwordDetected) {
          _restartListening();
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (result) {
          String spokenText = result.recognizedWords.toLowerCase();
          _fullTranscript += " $spokenText";
          developer.log("Recognized words: $spokenText");
          developer.log("Full transcript: $_fullTranscript");

          if (_fullTranscript.contains(_hotword) && mounted) {
            developer.log("🔥 Got it! Hotword detected: $_hotword");
            _hotwordDetected = true;
            _speech.stop();
            _isListening = false;

            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                String username = _userInfo?['username'] ?? "User";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Aihome(
                      name: username, // Pass username
                      id: widget.userId, // Pass userId
                    ),
                  ),
                );
              }
            });
          }

          setState(() {
            _text = _fullTranscript.isNotEmpty ? _fullTranscript : "Listening...";
          });
        },
        listenFor: const Duration(minutes: 2),
        localeId: "en_US",
      );

      Future.delayed(const Duration(minutes: 2), () {
        if (!_hotwordDetected && mounted && _isListening) {
          developer.log("⏰ Time limit reached without hotword detection");
          _speech.stop();
          _isListening = false;
          Navigator.pop(context);
        }
      });
    } else {
      developer.log("Speech recognition is NOT available.");
      if (mounted) Navigator.pop(context);
    }
  }

  void _restartListening() {
    if (_hotwordDetected || !_isListening) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_speech.isListening && _isListening) {
        developer.log("🔄 Restarting listening...");
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _isListening = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withAlpha(100),
              ),
            ),
          ),

          // Title
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                "Arise",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "MinervaModern",
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Centered Content (Lottie Animation + Text)
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show Lottie animation while listening
                if (_isListening)
                  Lottie.network(
                    'https://lottie.host/cee8c79b-ac20-4555-a168-9e80ac12112b/86nGHymrhf.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                // Speech text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    _text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}