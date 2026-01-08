// class ThreeDBoxAnimaton extends StatefulWidget {
//   const ThreeDBoxAnimaton({super.key});

//   @override
//   State<ThreeDBoxAnimaton> createState() => _ThreeDBoxAnimatonState();
// }

// class _ThreeDBoxAnimatonState extends State<ThreeDBoxAnimaton>
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
//       duration: Duration(seconds: 5),
//     );

//     _yController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     );

//     _zController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 7),
//     );

//     _xRotation = Tween<double>(begin: 0, end: 2 * pi).animate(_xController);
//     _yRotation = Tween<double>(begin: 0, end: 2 * pi).animate(_yController);
//     _zRotation = Tween<double>(begin: 0, end: 2 * pi).animate(_zController);

//     _xController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         // start with y animation
//         _yController.forward();
//       }
//     });
//     _yController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         // start with z animation
//         _zController.forward();
//       }
//     });
//     _zController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         // start with x animation & create a loop
//         // x controller start with 0 & ends at 1.0 means it has reach to end of its animation thus forward() not works because its already at final value same for y & z controller so that need to reset it to restart animation
//         _xController.reset();
//         _yController.reset();
//         _zController.reset();
//         _xController.forward();
//       }
//     });
//     _xController.forward();
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
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(color: Colors.red),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }