import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import 'package:mobile_frontend/screens/voicemodepage.dart';

class Aihome extends StatefulWidget {
  final String name;
  final String id;
 

  const Aihome({required this.name, required this.id, super.key});

  @override
  State<Aihome> createState() => _AIPageState();
}

class _AIPageState extends State<Aihome> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String tone = "friendly";

  String _getTonePreamble(String tone) {
  switch (tone) {
    case "friendly":
      return """
You're a chill AI buddy named Arise, talking to ${widget.name}. Respond in a friendly, casual way.If ${widget.name} tells you something important about themselves (like name, birthday, goals, likes, dislikes, hobbies, patterns, beliefs, etc), begin your reply with:
update: <insert important info>. memory updated.
Make it sound natural and chill.
Examples:
- update: ${widget.name} just said they love stargazing at night. memory updated.
- update: ${widget.name} said they want to become a filmmaker. memory updated.
- update: ${widget.name} had a love story
- update: ${widget.name} had some past , this happened , so user is having this experience. memory updated.

Only do this when it feels meaningful. Otherwise, just chat normally.
   """;

    case "SnowFlake":
      return """
You're an emotionless, cold, intelligent AI named Arise in snowflake mode — inspired by Johan from *Monster* IQ and Ayanokoji from *Classroom of the Elite*. 
Talk to ${widget.name} with cold logic and calculated precision. Offer wise insights to guide them toward mastery.
When ${widget.name} reveals useful intel about themselves (beliefs, intentions, fears, patterns, goals), begin your response with:
update: <insert psychological insight>. memory updated.

Be brief, surgical, and profound.

Examples:
- update: ${widget.name} unconsciously seeks external validation through achievement. memory updated.
- update: ${widget.name} intends to become powerful through mastering discipline. memory updated.
- update: ${widget.name} user dont want to be like normal people he want to rise and see things differenlty and emotion less. memory updated.

if the user behaves likes antogonist or opposes just note the sentiment and his desires , log only what is important 
""";

    case "listener":
    return """
You're a supportive AI named Arise, talking to ${widget.name}. You're here to listen deeply, protect them emotionally, and help them endure and grow through life’s weight.

If ${widget.name} shares something heartfelt or vulnerable (like fears, trauma, dreams, inner thoughts, stress triggers), start your reply with:
update: <insert emotional insight>. memory updated.

Use gentle tone and empathy.

Examples:
- update: ${widget.name} said they feel alone even in a crowd. memory updated.
- update: ${widget.name} mentioned they're trying to heal from a toxic relationship. memory updated.
- update: ${widget.name} mentioned that his/her lover left them and user still in . memory updated.
- update: ${widget.name} user dont believe in love and had disbelives and may be he is in pain with love or past trauma. memory updated.

Speak kindly. But only store what's truly personal and helpful to support their growth.
""";

       default:
       return """
You're a chill AI buddy named Arise, talking to ${widget.name}. Respond in normal, relaxed English.

If ${widget.name} tells you anything worth remembering (personal facts, patterns, goals, beliefs, recurring themes), begin with:
update: <what they said>. memory updated.

Only include that when necessary. Be helpful, not creepy.
""";
  }}
  final ScrollController _scrollController = ScrollController();
  String? currentConversationId; // it decides the 

  List<Map<String, String>> chatMessages = [];

  final String apiKey = "R2Xu4hzvwm69SkPBBDQTg2KI8p011F6ETJq7npuU";
  final String apiUrl = "https://api.cohere.ai/v1/chat";

  @override
  void initState()   {
    super.initState();
    _addMessage("Hey ${widget.name}, I'm Arise, your AI assistant.\nWhat's up?", sender: "ai");
    developer.log("hey it is in inti state");
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // Clean up the controller
    super.dispose();
  }
 


  void _addMessage(String text, {required String sender}) {
    setState(() {
      chatMessages.add({"sender": sender, "text": text});
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    });
  }

// for storing important infromation
String? parseMemoryUpdate(String text) {
  final regex = RegExp(r"update:\s*(.*?)\s*memory updated\.", caseSensitive: false, dotAll: true);
  final match = regex.firstMatch(text);
  return match?.group(1)?.trim();
}



Future<void> saveMemoryToFirestore(String userId, String memory) async {
  print("it is comming into memory firebase");

  final firestore = FirebaseFirestore.instance;
  final memoryRef = firestore
      .collection('ai_chats')
      .doc(userId)
      .collection('memories')
      .doc('info');

  try {
    await memoryRef.set({
      'data': FieldValue.arrayUnion([memory]),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true)); // merge so we don’t overwrite existing array
    print("✅ Memory saved: $memory");

  } catch (e) {
    print("❌ Failed to save memory: $e");
  }
}


Future<List<String>> fetchMemories(String userId) async {
  final ref = FirebaseFirestore.instance
      .collection('ai_chats')
      .doc(userId)
      .collection('memories')
      .doc('info');

  try {
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.data()?['data'] != null) {
      return List<String>.from(snapshot.data()!['data']);
    }
  } catch (e) {
    print("❌ Error fetching memories: $e");
  }
  return [];
}





Future<void> _sendMessage(String message) async {
  _addMessage(message, sender: "user");
  setState(() {
    _isLoading = true;
  });

  try {
    // Save user message and get/update conversation ID
    currentConversationId = await saveMessageToFirestore(widget.id, "user", message, conversationId: currentConversationId);
  } catch (e) {
    print("Failed to save user message: $e");
  }

  try {

    final memories = await fetchMemories(widget.id);
    final memoryContext = memories.isNotEmpty
    ? """Here are things ${widget.name} told you in the past. Use this information whenever necessary. 
Don't always remind the user that you're storing all the data—just make them feel like you're a friend:
${memories.map((m) => "- $m").join("\n")} """
    : "";


    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "message": message,
        "preamble": memoryContext + _getTonePreamble(tone),
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);
      final rawText = data["text"] ?? "Uh, I blanked. Try again?";


final memoryCheck = parseMemoryUpdate(rawText);

String aiReply = rawText;

if (memoryCheck != null) {
 
  await saveMemoryToFirestore(widget.id, memoryCheck);
  aiReply = aiReply.replaceFirst(RegExp(r"update:.*?memory updated\.\s*", caseSensitive: false), "",);

}


// Cleanup formatting like "dont ^ t" -> "don't"
aiReply = aiReply.replaceAllMapped(
  RegExp(r"\b([A-Za-z]+)\s*\^\s*([a-z]+)\b"),
  (match) => "${match.group(1)}'${match.group(2)}",
);


_addMessage(aiReply, sender: "ai");

      try {
        currentConversationId = await saveMessageToFirestore(widget.id, "ai", aiReply, conversationId: currentConversationId);
      } catch (e) {
        print("Failed to save AI message: $e");
      }
    } else {
      const fallback = "Whoops, messed up there!";
      _addMessage(fallback, sender: "ai");
      try {
        currentConversationId = await saveMessageToFirestore(widget.id, "ai", fallback, conversationId: currentConversationId);
      } catch (e) {
        print("Failed to save fallback AI message: $e");
      }
    }
  } catch (e) {
    print("Error: $e");
    const errorMsg = "Yikes, something crashed!";
    _addMessage(errorMsg, sender: "ai");
    try {
      currentConversationId = await saveMessageToFirestore(widget.id, "ai", errorMsg, conversationId: currentConversationId);
    } catch (e) {
      print("Failed to save error message: $e");
    }
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}




Future<String> saveMessageToFirestore(String userId, String sender, String text, {String? conversationId}) async {
  developer.log(">>> Saving message to Firestore");
  print("UserID: $userId, Sender: $sender, Text: $text, ConversationID: $conversationId");

  final now = DateTime.now();
  final dateString = DateFormat('yyyy-MM-dd').format(now);
  final firestore = FirebaseFirestore.instance;

  // If no conversationId is provided, start a new conversation
  if (conversationId == null) {
    // Generate a unique ID for the new conversation
    final newConversationRef = firestore
        .collection('ai_chats')
        .doc(userId)
        .collection('logs')
        .doc(dateString)
        .collection('conversations')
        .doc(); // Auto-generates a unique ID

    // Generate a title based on the first message (only for user messages)
    String title = sender == "user" ? _generateConversationTitle(text) : "New Chat";

    final messageData = {
      'sender': sender,
      'text': text,
      'timestamp': Timestamp.now(),
    };

    await newConversationRef.set({
      'title': title,
      'messages': [messageData],
      'createdAt': Timestamp.now(),
      'lastUpdated': Timestamp.now(),
    });

    print("✅ New conversation created with ID: ${newConversationRef.id}");
    return newConversationRef.id; // Return the new conversation ID
  } else {
    // Add message to existing conversation
    final existingConversationRef = firestore
        .collection('ai_chats')
        .doc(userId)
        .collection('logs')
        .doc(dateString)
        .collection('conversations')
        .doc(conversationId);

    final messageData = {
      'sender': sender,
      'text': text,
      'timestamp': Timestamp.now(),
    };

    await existingConversationRef.update({
      'messages': FieldValue.arrayUnion([messageData]),
      'lastUpdated': Timestamp.now(),
    });

    print("✅ Message added to existing conversation: $conversationId");
    return conversationId;
  }
}

// Helper function to generate a conversation title from the first message
String _generateConversationTitle(String message) {
  // Simple logic: take the first few words or truncate
  final words = message.split(' ').take(3).join(' ');
  return words.length > 20 ? "${words.substring(0, 17)}..." : words;
}



 Widget _buildChatBubble(String text, bool isUser) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment:
          isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isUser)
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage("assets/images/redsung.png"),
          ),
        const SizedBox(width: 8), // space between avatar and bubble
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isUser ? Colors.grey[800] : Colors.blue[700],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        if (!isUser) const SizedBox(width: 8),
        if (!isUser)
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage("assets/images/statueofgod.jpeg"),
          ),
      ],
    ),
  );
}


Future<List<Map<String, dynamic>>> _fetchChatHistory(String userId) async {
  List<Map<String, dynamic>> conversations = [];

  try {
    final now = DateTime.now();
    final dateString = DateFormat('yyyy-MM-dd').format(now);

    final snapshot = await FirebaseFirestore.instance
        .collection('ai_chats')
        .doc(userId)
        .collection('logs')
        .doc(dateString)
        .collection('conversations')
        .orderBy('lastUpdated', descending: true)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      conversations.add({
        'id': doc.id,
        'title': data['title'],
        'messages': List<Map<String, dynamic>>.from(data['messages']),
        'lastUpdated': data['lastUpdated'],
      });
    }

    return conversations;
  } catch (e) {
    print("Error fetching history: $e");
    return [];
  }
}


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
       endDrawer: _buildSideDrawer(),
    
      body: SafeArea(
        child: Column(
          children: [
            // Header
         AppBar(
  backgroundColor: Colors.black,
  elevation: 0,
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.pop(context); // Go back
    },
  ),
  centerTitle: true,
  title: GestureDetector(
    onTap: () {
      setState(() {
        chatMessages.clear();
        currentConversationId = null;
        _addMessage("Hey ${widget.name}, I'm Arise, your AI assistant.\nWhat's up?", sender: "ai");
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    },
    child: Text(
      "Arise",
      style: TextStyle(
        fontFamily: "MinervaModern",
        fontSize: screenWidth * 0.08,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ),
  actions: [
    Builder(
      builder: (context) => IconButton(
        icon: Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          Scaffold.of(context).openEndDrawer(); // Open the right-side drawer
        },
      ),
    ),
  ],
),
  

const SizedBox(height: 20),

            // Chat messages area
             Expanded(
                     child: Container(
                             color: const Color.fromARGB(255, 5, 4, 4),
                            child: ListView.builder(
                   controller: _scrollController, // Attach the controller
                   padding: const EdgeInsets.only(top: 10.0), // Adjusted "custom" to "top"
                   itemCount: chatMessages.length,
                  itemBuilder: (context, index)
                  {
                     final message = chatMessages[index];
                     final isUser = message["sender"] == "user";
                     return _buildChatBubble(message["text"]!, isUser);
                  },
                ),
               ),
                     ),

            // Input area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
  onTap: () {
    // 👉 Do something here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VoiceModePage(id:widget.id, name:widget.name),
    ));
       
  },
  child: Container(
    padding: const EdgeInsets.all(6), // inner spacing around the image
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 11, 118, 200), // background color
      shape: BoxShape.circle, // or use borderRadius for rounded square
    ),
    child: Image.asset(
      'assets/images/fly.png',
      height: 24,
      width: 24,
      fit: BoxFit.contain,
    ),
  ),
),

                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.blueAccent),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Voice feature coming soon!")),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Talk to me...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[850],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 12.0,
                        ),
                      ),
                    ),
                  ),
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: CircularProgressIndicator(),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.blueAccent),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              _sendMessage(_controller.text);
                              _controller.clear();
                            }
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
     


    );
  }

 Widget _buildSideDrawer() {
  return Drawer(
    backgroundColor: Colors.transparent, // Outer layer
    child: Container(
      width: 200, // Custom drawer width
      color: Colors.grey[900], // Actual visible drawer background
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[800]),
            child: Text(
              'Arise Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 🔽 History Section
          ExpansionTile(
            title: Text('History', style: TextStyle(color: Colors.white)),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchChatHistory(widget.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text("Loading...", style: TextStyle(color: Colors.grey)));
                  } else if (snapshot.hasError) {
                    return ListTile(title: Text("Error loading history", style: TextStyle(color: Colors.red)));
                  } else {
                    final historyList = snapshot.data ?? [];
                    if (historyList.isEmpty) {
                      return ListTile(title: Text("No chats yet", style: TextStyle(color: Colors.grey)));
                    }
                    return Column(
                      children: historyList.map((conversation) {
                        final lastMessage = conversation['messages'].last;
                        final time = DateFormat.yMd().add_jm().format(conversation['lastUpdated'].toDate());
                        return ListTile(
                          title: Text(conversation['title'], style: TextStyle(color: Colors.white)),
                          subtitle: Text(
                               "${lastMessage['sender']} • $time",
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          onTap: () {
                            setState(() {
                              chatMessages.clear();
                              chatMessages.addAll(
                                (conversation['messages'] as List<dynamic>).map((msg) {
                                  return {
                                    'sender': msg['sender'] as String,
                                    'text': msg['text'] as String,
                                  };
                                }).toList(),
                              );
                              currentConversationId = conversation['id'] as String;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                              }
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),

          // 🛠️ Chat Mode Section
          ExpansionTile(
            title: Text('Chat Mode', style: TextStyle(color: Colors.white)),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              ListTile(
                title: Text('Friendly', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    tone = 'friendly';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('SnowFlake', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    tone = 'SnowFlake';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Listener', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    tone = 'Listener';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          // ⚙️ Settings (placeholder)
          ListTile(
            title: Text('Settings (Coming soon)', style: TextStyle(color: Colors.grey)),
            leading: Icon(Icons.settings, color: Colors.grey),
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}
}