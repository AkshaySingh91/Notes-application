
// class Ushape extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height / 2);
//     // create start & end control point
//     final controlPoint = Offset(size.width / 2, size.height);
//     final controlEndPoint = Offset(size.width, size.height / 2);
//     // give to bezier curve
//     path.quadraticBezierTo(
//       controlPoint.dx,
//       controlPoint.dy,
//       controlEndPoint.dx,
//       controlEndPoint.dy,
//     );

//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }

// class Wave extends StatelessWidget {
//   const Wave({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ClipPath(
//         clipper: Ushape(),
//         child: Container(
//           width: 200,
//           height: 200,
//           decoration: BoxDecoration(color: Colors.amber),
//         ),
//       ),
//     );
//   }
// }

// class HexagonalClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     print(size);
//     Path path = Path();
//     // for hexagon divided side in 3 part
//     final widthOneThird = size.width / 3;
//     final heightOneThird = size.height / 3;

//     path.moveTo(0, size.height / 3);
//     // upper side
//     path.lineTo(widthOneThird, 0);
//     path.lineTo(widthOneThird * 2, 0);
//     // right side
//     path.lineTo(widthOneThird * 3, heightOneThird);
//     path.lineTo(widthOneThird * 3, heightOneThird * 2);
//     // bottom side
//     path.lineTo(widthOneThird * 2, heightOneThird * 3);
//     path.lineTo(widthOneThird, heightOneThird * 3);
//     // left side
//     path.lineTo(0, heightOneThird * 2);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }

// class Hexagonal extends StatelessWidget {
//   const Hexagonal({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ClipPath(
//         clipper: HexagonalClipper(),
//         child: Container(
//           width: 200,
//           height: 200,
//           decoration: BoxDecoration(color: Colors.amber),
//         ),
//       ),
//     );
//   }
// }
