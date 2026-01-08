// class ThreeDBoxAnimation extends StatefulWidget {
//   const ThreeDBoxAnimation({super.key});

//   @override
//   State<ThreeDBoxAnimation> createState() => _ThreeDBoxAnimationState();
// }

// class _ThreeDBoxAnimationState extends State<ThreeDBoxAnimation>
//     with TickerProviderStateMixin {
//   late AnimationController _xController;
//   late AnimationController _yController;
//   late AnimationController _zController;

//   late Animation _xRotation;
//   late Animation _yRotation;
//   late Animation _zRotation;

//   @override
//   void initState() {
//     _xController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 10),
//     );

//     _yController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 20),
//     );

//     _zController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 30),
//     );

//     _xRotation = Tween<double>(begin: 0, end: 2 * pi).animate(_xController);
//     _yRotation = Tween<double>(begin: 0, end: 2 * pi).animate(_yController);
//     _zRotation = Tween<double>(begin: 0, end: 2 * pi).animate(_zController);

//     _xController.repeat();
//     _yController.repeat();
//     _zController.repeat();

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: AnimatedBuilder(
//         animation: Listenable.merge([_xController, _yController, _zController]),
//         builder: (context, child) {
//           return Transform(
//             transform: Matrix4.identity()
//               ..rotateZ(_zRotation.value)
//               ..rotateY(_yRotation.value)
//               ..rotateX(_xRotation.value),
//             alignment: Alignment.center,
//             child: Stack(
//               children: [
//                 Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(color: Colors.red),
//                   child: Center(child: Text("Front")),
//                 ),
//                 Transform(
//                   alignment: Alignment.centerRight,
//                   transform: Matrix4.identity()..rotateY(-pi / 2),
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(color: Colors.green),
//                     child: Center(child: Text("Right")),
//                   ),
//                 ),
//                 Transform(
//                   alignment: Alignment.centerLeft,
//                   transform: Matrix4.identity()..rotateY(pi / 2),
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(color: Colors.orange),
//                     child: Center(child: Text("Left")),
//                   ),
//                 ),
//                 Transform(
//                   alignment: Alignment.bottomCenter,
//                   transform: Matrix4.identity()..rotateX(pi / 2),
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(color: Colors.pink),
//                     child: Center(child: Text("Bottom")),
//                   ),
//                 ),
//                 Transform(
//                   alignment: Alignment.topCenter,
//                   transform: Matrix4.identity()..rotateX(-pi / 2),
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(color: Colors.deepPurple),
//                     child: Center(child: Text("Top")),
//                   ),
//                 ),
//                 Transform(
//                   transform: Matrix4.identity()
//                     ..translateByVector3(Vector3(0, 0, -100)),
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(color: Colors.blue),
//                     child: Center(child: Text("Back")),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
