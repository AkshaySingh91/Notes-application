// class CircleClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }

// class ImplicitTweenColorAnimation extends StatefulWidget {
//   const ImplicitTweenColorAnimation({super.key});

//   @override
//   State<ImplicitTweenColorAnimation> createState() =>
//       ImplicitTweenColorAnimationState();
// }

// class ImplicitTweenColorAnimationState
//     extends State<ImplicitTweenColorAnimation> {
//   Color _endColor = Colors.red;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TweenAnimationBuilder(
//             tween: ColorTween(begin: Colors.amber, end: _endColor),
//             duration: Duration(seconds: 1),
//             builder: (context, value, child) {
//               return ClipPath(
//                 clipper: CircleClipper(),
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(color: Color(value!.toARGB32())),
//                 ),
//               );
//             },
//             onEnd: () {
//               setState(() {
//                 print("end");
//                 int r = Math.Random().nextInt(255);
//                 int g = Math.Random().nextInt(255);
//                 int b = Math.Random().nextInt(255);
//                 _endColor = Color.fromARGB(255, r, g, b);
//               });
//             },
//           ),
//           TextButton(onPressed: () {}, child: const Text("Increase count")),
//         ],
//       ),
//     );
//   }
// }
