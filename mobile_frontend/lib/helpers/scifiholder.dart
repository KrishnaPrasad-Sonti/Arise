// import 'dart:async';
// import 'package:flutter/material.dart';


// class SciFiProgressBar extends StatefulWidget {
//   final String userId;

//   const SciFiProgressBar({super.key, required this.userId});
  

//   @override
//   SciFiProgressBarState createState() => SciFiProgressBarState();
// }

// class SciFiProgressBarState extends State<SciFiProgressBar> {
//   double progress = 0.0;
//   Timer? timer;
//   bool isHolding = false;

//   void startProgress() {
//     isHolding = true;
//     timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
//       if (progress < 1.0) {
//         setState(() => progress += 0.02);
//       } else {
//         t.cancel();
//         isHolding = false;
//         navigateToNextPage();
//       }
//     });
//   }

//   void stopProgress() {
//     isHolding = false;
//     timer?.cancel();
//     setState(() => progress = 0.0);
//   }

//   void navigateToNextPage() {
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) =>  Hiddenarise(userId: widget.userId)),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: GestureDetector(
//           onTapDown: (_) => startProgress(),
//           onTapUp: (_) => stopProgress(),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Container(
//                 width: 200,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.blue, width: 4),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.6),
//                       blurRadius: 15,
//                       spreadRadius: 5,
//                     )
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 width: 150,
//                 height: 150,
//                 child: CircularProgressIndicator(
//                   value: progress,
//                   strokeWidth: 8,
//                   color: Colors.blue,
//                   backgroundColor: Colors.white.withOpacity(0.2),
//                 ),
//               ),
//               Text(
//                 "${(progress * 100).toInt()}%",
//                 style: const TextStyle(
//                     color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

