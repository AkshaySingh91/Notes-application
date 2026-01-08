
// class ThreeDBoxAnimaton extends StatefulWidget {
//   const ThreeDBoxAnimaton({super.key});

//   @override
//   State<ThreeDBoxAnimaton> createState() => _ThreeDBoxAnimatonState();
// }

// class _ThreeDBoxAnimatonState extends State<ThreeDBoxAnimaton>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
  
//   late Animation _xRotation;
//   late Animation _yRotation;
//   late Animation _zRotation;

//   @override
//   void initState() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 20),
//     );
//     // from 0 -> 0.33 it takes roughly 2sec means x rotation will complete in 2sec
//     _xRotation = Tween<double>(
//       begin: 0,
//       end: 2 * pi,
//     ).animate(CurvedAnimation(parent: _controller, curve: Interval(0, 1)));

//     // from 0.33 -> 0.66 it takes roughly 2sec means y rotation will complete at 4sec
//     _yRotation = Tween<double>(
//       begin: 0,
//       end: 2 * pi,
//     ).animate(CurvedAnimation(parent: _controller, curve: Interval(0, 1)));

//     // from 0.66 -> 1.0 it takes roughly 2sec means y rotation will complete at 6sec
//     _zRotation = Tween<double>(
//       begin: 0,
//       end: 2 * pi,
//     ).animate(CurvedAnimation(parent: _controller, curve: Interval(0, 1)));

//     _controller.repeat();

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: AnimatedBuilder(
//         animation: _controller,
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
