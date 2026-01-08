// void main() async {
//   runApp(
//     MaterialApp(
//       builder: (context, child) {
//         return Scaffold(appBar: AppBar(), body: AnimatedBox());
//       },
//     ),
//   );
// }
// class AnimatedBox extends StatefulWidget {
//   const AnimatedBox({super.key});

//   @override
//   State<AnimatedBox> createState() => _AnimatedBoxState();
// }

// class _AnimatedBoxState extends State<AnimatedBox>
//     with TickerProviderStateMixin {
//   late AnimationController _zController;
//   late Animation _zAxisRotation;

//   late AnimationController _yController;
//   late Animation _yAxisRotation;

//   @override
//   void initState() {
//     _zController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     );

//     _zAxisRotation = Tween<double>(
//       begin: 0,
//       end: -pi / 2,
//     ).animate(CurvedAnimation(parent: _zController, curve: Curves.bounceOut));

//     _yController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     );
//     _yAxisRotation = Tween<double>(
//       begin: 0,
//       end: pi,
//     ).animate(CurvedAnimation(parent: _yController, curve: Curves.bounceOut));

//     _zController.addStatusListener((status) {
//       if (AnimationStatus.completed == status) {
//         _yAxisRotation =
//             Tween<double>(
//               begin: _yAxisRotation.value,
//               end: pi + _yAxisRotation.value,
//             ).animate(
//               CurvedAnimation(parent: _yController, curve: Curves.bounceOut),
//             );
//         _yController
//           ..reset()
//           ..forward();
//       }
//     });

//     _yController.addStatusListener((status) {
//       if (AnimationStatus.completed == status) {
//         _zAxisRotation =
//             Tween<double>(
//               begin: _zAxisRotation.value,
//               end: _zAxisRotation.value + -pi / 2,
//             ).animate(
//               CurvedAnimation(parent: _zController, curve: Curves.bounceOut),
//             );
//         _zController
//           ..reset()
//           ..forward();
//       }
//     });

//     _zController.forward();

//     super.initState();
//   }

//   @override
//   void dispose() {
//     _zController.dispose();
//     _yController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _zController,
//       builder: (context, child) {
//         return Transform(
//           alignment: Alignment.center,
//           transform: Matrix4.identity()..rotateZ(_zAxisRotation.value),
//           child: Center(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 AnimatedBuilder(
//                   animation: _yController,
//                   builder: (context, child) {
//                     return Transform(
//                       alignment: Alignment.centerRight,
//                       transform: Matrix4.identity()
//                         ..rotateY(_yAxisRotation.value),
//                       child: Container(
//                         width: 100,
//                         height: 200,
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           border: BoxBorder.all(width: 2, color: Colors.orange),
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(100),
//                             bottomLeft: Radius.circular(100),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 AnimatedBuilder(
//                   animation: _yController,
//                   builder: (context, child) {
//                     return Transform(
//                       alignment: Alignment.centerLeft,
//                       transform: Matrix4.identity()
//                         ..rotateY(_yAxisRotation.value),
//                       child: Container(
//                         width: 100,
//                         height: 200,
//                         decoration: BoxDecoration(
//                           color: Colors.yellow,
//                           border: BoxBorder.all(width: 2, color: Colors.orange),
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(100),
//                             bottomRight: Radius.circular(100),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
