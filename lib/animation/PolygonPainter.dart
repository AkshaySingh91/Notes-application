
// class PolygonPainter extends CustomPainter {
//   final side;
//   PolygonPainter({required this.side});

//   @override
//   void paint(Canvas canvas, Size size) {
//     // define paint brush
//     final paint = Paint();
//     paint
//       ..color = Colors.amber
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 3;

//     final path = Path();
//     final radius = size.width / 2;

//     double x = size.width / 2 + radius * Math.cos(0);
//     double y = size.height / 2 + radius * Math.sin(0);

//     path.moveTo(x, y);
//     // generate an angles;
//     final angles = List.generate(side, (index) => index * (2 * Math.pi) / side);

//     for (final angle in angles) {
//       x = size.width / 2 + radius * Math.cos(angle);
//       y = size.height / 2 + radius * Math.sin(angle);
//       path.lineTo(x, y);
//     }
//     path.close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   @override
//   bool shouldRepaint(covariant PolygonPainter oldDelegate) =>
//       oldDelegate.side != side;
// }

// class PolygonAnimation extends StatefulWidget {
//   const PolygonAnimation({super.key});

//   @override
//   State<PolygonAnimation> createState() => _PolygonAnimationState();
// }

// class _PolygonAnimationState extends State<PolygonAnimation>
//     with TickerProviderStateMixin {
//   late AnimationController _sideController;
//   late Animation _sideAnimation;

//   late AnimationController _radiusController;
//   late Animation _radiusAnimation;

//   late AnimationController _rotationController;
//   late Animation _rotationAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _sideController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     );
//     _sideAnimation = IntTween(
//       begin: 3,
//       end: 10,
//     ).animate(CurvedAnimation(parent: _sideController, curve: Curves.linear));

//     _radiusController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     );
//     _radiusAnimation = IntTween(begin: 30, end: 300).animate(
//       CurvedAnimation(parent: _sideController, curve: Curves.bounceInOut),
//     );

//     _rotationController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 5),
//     );
//     _rotationAnimation = Tween<double>(
//       begin: 0,
//       end: 2 * Math.pi,
//     ).animate(CurvedAnimation(parent: _sideController, curve: Curves.bounceIn));

//     _sideController.repeat(reverse: true);
//     _radiusController.repeat(reverse: true);
//     _rotationController.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _sideController.dispose();
//     _radiusController.dispose();
//     _rotationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: AnimatedBuilder(
//         animation: Listenable.merge([
//           _sideController,
//           _radiusController,
//           _rotationController,
//         ]),
//         builder: (context, child) {
//           return Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()
//               ..rotateX(_rotationAnimation.value)
//               ..rotateY(_rotationAnimation.value)
//               ..rotateZ(_rotationAnimation.value),
//             child: CustomPaint(
//               size: Size(
//                 _radiusAnimation.value * 1.0,
//                 _radiusAnimation.value * 1.0,
//               ),
//               painter: PolygonPainter(side: _sideAnimation.value),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
