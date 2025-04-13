import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionManage extends StatefulWidget {
 final String userId;

  const EmotionManage({super.key, required this.userId});

  @override
  State<EmotionManage> createState() => _EmotionManageState();
}
class _EmotionManageState extends State<EmotionManage> {
  final ScrollController _scrollController = ScrollController();
  final List<String> emotions = [
    "Fear",
    "Sadness",
    "Anger",
    "Guilt",
    "Jealousy",
    "OverThinking",
  ];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, GlobalKey> _sectionKeys = {};
  List<String> selectedMoods = []; // To track moods clicked by the user

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.positions.isNotEmpty) {
        _scrollController.jumpTo(0);
      }
    });
    for (var emotion in emotions) {
      _sectionKeys[emotion] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String emotion) {
    final key = _sectionKeys[emotion];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    // Add the clicked mood to the list and save to Firestore
    if(!selectedMoods.contains(emotion.toLowerCase())) {
      setState(() {
        selectedMoods.add(emotion.toLowerCase());
      });
    }
    // Save to Firestore every time, regardless of duplicates
    _saveMoodToFirestore(emotion.toLowerCase());
  }
  

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Function to save mood to Firestore
  Future<void> _saveMoodToFirestore(String mood) async {
  try {
    // Get today's date in YYYY-MM-DD format
    String today = DateTime.now().toIso8601String().split('T')[0];

    // Reference to Firestore
  

    // Path: mood_diary > UserID > mood > YYYY-MM-DD > entries
    CollectionReference entriesRef = _firestore
        .collection('mood_diary')
        .doc(widget.userId)
        .collection('mood')
        .doc(today)
        .collection('entries');

    // Add a new mood entry with a timestamp
    await entriesRef.add({
      'mood': mood,
      'timestamp': FieldValue.serverTimestamp(), // Server-side timestamp
    });

    print("Mood saved successfully: $mood");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Mood tracked: $mood")),
    );
  } catch (e) {
    print("Error saving mood: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error tracking mood: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 237, 236),


      body: Stack( 
        children: [
      
      SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.06),

              // Company Name Heading
              Text(
                "Arise",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "MinervaModern",
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              

              SizedBox(height: screenHeight * 0.03),

              // Animation
              Center(
                child: Lottie.asset(
                  'assets/animations/peacefirst.json',
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.25,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Paragraph
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  "What happened? Here is the Relaxation Dope.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                   fontFamily: 'Gentium',
                    fontSize: 18,
                  ),

                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Emotion Buttons (Clickable)
              Wrap(
                spacing: screenWidth * 0.03,
                runSpacing: screenHeight * 0.02,
                children: emotions.map((emotion) {
                  return GestureDetector(
                    onTap: () => _scrollToSection(emotion),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.06,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Text(
                        emotion,
    
                        style: TextStyle
                        (        
                       fontFamily: 'Gentium',
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: screenHeight * 0.05),

      // Emotion Sections--------------------emotions start here-------------------

    Column(
          children: [

    // Fear Section emotion here 
    Padding(
      key: _sectionKeys["Fear"],
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.07, // Space between sections
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emotion Heading
          Text(
            "Fear",
            style: TextStyle(
              fontFamily: 'Gentium',
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

         

          // Description
          Text(
            "Fear is a natural response to danger, preparing the body for fight or flight. 1.Slow down for a bit . 2) You have faced a lot like this. 3) face it . But first  slow down ",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),

          Text(
            " 1. Slow breathing-",
            style: TextStyle(
              fontFamily: 'Gentium',
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

           // Animation
          Center(
            child: Lottie.asset(
              'assets/animations/breathtechnique.json',
              width: screenWidth * 0.6,
              height: screenHeight * 0.25,
              fit: BoxFit.cover,
            ),
          ),
       SizedBox(height: screenHeight * 0.02),

          Text(
            "2. 3-3-3 Rule -"
             " Name any 3 things you see, 3 things you hear , Move 3 parts of your body ",
            style: TextStyle(
              fontFamily: 'Gentium',
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

              SizedBox(height: screenHeight * 0.04),

          Text(
            "3.Face it. You Can -",
            style: TextStyle(
              fontFamily: 'Gentium',
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

             SizedBox(height: screenHeight * 0.04),


        ],
      ),
      
    ),
 
     


    // Sadness Section
    Padding(
      key: _sectionKeys["Sadness"],
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.07,
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sadness",
            style: TextStyle(
              fontFamily: 'Gentium',
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

       
          
         

          Text(
            "Sadness is an emotional state that signals loss or disappointment. Dont worry I am Here ",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

           SizedBox(height: screenHeight * 0.04),
          Text(
            "1.Write  all your worries and Think why are sad. what makes you sad , note a list.\n" "If you cant control the things leave it . Change the Things that you can control...\n\n" "But first throw some unnecessary  fealings to this dustbin",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

          Center(
            child: Lottie.asset(
              'assets/animations/dustbin.json',
              width: screenWidth * 0.5,
              height: screenHeight * 0.25,
              fit: BoxFit.cover,
            ),
          ),

        ],


        
      ),
    ),






    // Anger Section---------------------------------

    Padding(
      key: _sectionKeys["Anger"],
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.07,
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Anger",
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

        
          SizedBox(height: screenHeight * 0.02),

          Text(
            "Anger arises when we feel threatened or treated unfairly. Learn to Forgive \n Its the true emotion use it wisely, anger is the double edged sword .",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

           SizedBox(height: screenHeight * 0.02),

          Text(
            " 1. Slow breathing-",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

           // Animation
          Center(
            child: Lottie.asset(
              'assets/animations/breathtechnique.json',
              width: screenWidth * 0.6,
              height: screenHeight * 0.25,
              fit: BoxFit.cover,
            ),
          ),
       SizedBox(height: screenHeight * 0.02),

      
      Text(
            "2. Stay Control\n\n Arguing with a fool  only proves there are Two \n" " Be cool and fly like this and dont comeback ..\n",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

          Center(
            child: Lottie.asset(
              'assets/animations/rocketlaunch.json',
              width: screenWidth * 0.6,
              height: screenHeight * 0.25,
              fit: BoxFit.cover,
            ),
          ),
           Text(
            " Just kidding, see your reaction on mirror or phone that better now  ..chill",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

        ],
      ),
    ),

    // ...................Guilt emotion -------------------------------------------


    Padding(
      key: _sectionKeys["Guilt"],
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.07,
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Guilt",
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

       
          
         

          Text(
            "Guilt is an emotional response that comes when a person believes they have done something wrong, failed to meet their own moral standards, or hurt someone.\n""Self Satisfaction is more than anything in life , You can Cheat anyone but not yourself\n""Dont worry I Can help to remove it only if you let me..",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

           SizedBox(height: screenHeight * 0.04),
          Text(
            "1. Accept that you done a mistake, acknowledge it \n""2.Forgive Yourself, if there is nothing you can do \n""3. If it really Important or person is important make ammends people will always not  be the same , the more you make late the concequences are more ",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),


        ],


        
      ),
    ),


// Jealousy
 Padding(
      key: _sectionKeys["Jealousy"],
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.07,
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Jealous",
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

        
          SizedBox(height: screenHeight * 0.02),

          Text(
            "Jealousy is a complex emotion that arises when you feel threatened by the possibility of losing something valuable to someone else—whether it's a relationship, status, attention, or success. It often comes with insecurity, fear, and resentment.\n" ,
                style: TextStyle(
              fontFamily: 'Gentium',
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

           SizedBox(height: screenHeight * 0.04),
     Text(
            "1. Acknowledge it dont deny it . \n2. Stop Comparing Yourself to Others \n3. You are the way better than you think ,dont underestimate yourself , the world you live is danger , dont make it more trouble by looking pity and small on you .\n 4. The moment you Jealous is the the moment you gave othersthe control on yourself.\n " ,
            style: TextStyle(
              
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),
          


           // Animation
          Center(
            child: Lottie.asset(
              'assets/animations/pandalove.json',
              width: screenWidth * 0.9,
              height: screenHeight * 0.30,
              fit: BoxFit.contain,
            ),
          ),
       SizedBox(height: screenHeight * 0.02),

           Text(
            " Love yourself- Develop your self",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

        ],
      ),
    ),

// Over thinking -------------------
     Padding(
      key: _sectionKeys["OverThinking"],
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.07, // Space between sections
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emotion Heading
          Text(
            "OverThinking",
            style: TextStyle(
              fontFamily: 'Gentium',
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

         

          // Description
          Text(
            "Overthinking is when your mind gets stuck in a loop of analyzing, questioning, and imagining different scenarios—most of them negative. It feels like a mental prison where you keep replaying the past or fearing the future",
                 style: TextStyle(
                  fontFamily: 'Gentium',
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),

          Text(
           "Count how many times the monkey swing in the next 30 seconds ,count by yourself",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

           // Animation
          Center(
            child: Lottie.asset(
              'assets/animations/mindmonkey.json',
              width: screenWidth * 0.6,
              height: screenHeight * 0.25,
              fit: BoxFit.cover,
            ),
          ),
       SizedBox(height: screenHeight * 0.02),

          Text(
            "2. No matter how much you overthink, the past won't change. Accept it .\n\n 3. Accept the Uncertainty - Not every question has an answer. Some things are just meant to be left behind.\n\n 4. I Know Some things are hard to accept But some things comes into our life for our development and they leave-Leason Learned. Dont hold to their feeling, you loose yourself .\n5. Live for youself and your future ,dont try to prove them wrong , its wrong way to put your energy",
            style: TextStyle(
              
              fontSize: screenWidth * 0.045,
              color: Colors.black54,
            ),
          ),

              SizedBox(height: screenHeight * 0.04),



        ],
      ),
    ),





 



  ],
),

             ],
          ),
        ),


      ),
      Positioned( // Correctly placed inside the Stack's children list
      bottom: screenHeight * 0.05,
      right: screenWidth * 0.05,
      child: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      )),
        ]
          
      ),



      // below is for scaffold
    );
  }
}
