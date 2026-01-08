
// class ScaleImageAnimation extends StatefulWidget {
//   const ScaleImageAnimation({super.key});

//   @override
//   State<ScaleImageAnimation> createState() => _ScaleImageAnimationState();
// }

// class _ScaleImageAnimationState extends State<ScaleImageAnimation> {
//   bool _isScaled = false;
//   String _buttonText = 'Zoom in';
//   double _width = 100.0;
//   double _height = 100.0;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           AnimatedContainer(
//             duration: Duration(milliseconds: 370),
//             curve: Curves.bounceOut,
//             width: _width,
//             height: _height,
//             color: Colors.amber,
//           ),
//           const SizedBox(height: 10),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _isScaled = !_isScaled;
//                 _buttonText = _isScaled ? "Zoom out" : "Zoom in";
//                 _width = _isScaled ? 200.0 : 100.0;
//                 _height = _isScaled ? 200.0 : 100.0;
//               });
//             },
//             style: ButtonStyle(
//               backgroundColor: WidgetStateProperty.all(
//                 const Color.fromARGB(255, 255, 236, 181),
//               ),
//             ),
//             child: Text(_buttonText),
//           ),
//         ],
//       ),
//     );
//   }
// }
