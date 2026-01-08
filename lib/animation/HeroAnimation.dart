// class HeroAnimation extends StatelessWidget {
//   HeroAnimation({super.key});

//   final peoples = [
//     Person("John", 20, '🙋‍♂️'),
//     Person("Jack", 22, '🫅'),
//     Person("Jane", 18, '🧔🏿'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "List of users",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.amber,
//       ),
//       body: ListView.builder(
//         itemCount: peoples.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => UserPage(user: peoples[index]),
//                 ),
//               );
//             },
//             leading: Hero(
//               tag: peoples[index].name,
//               child: Text(peoples[index].emoji, style: TextStyle(fontSize: 40)),
//             ),
//             title: Text(peoples[index].name),
//             subtitle: Text('${peoples[index].age} year old'),
//             trailing: Icon(Icons.chevron_right, size: 32),
//           );
//         },
//       ),
//     );
//   }
// }

// class Person {
//   final String name;
//   final int age;
//   final emoji;
//   Person(this.name, this.age, this.emoji);
// }

// class UserPage extends StatelessWidget {
//   final Person user;
//   const UserPage({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Hero(
//           tag: user.name,
//           flightShuttleBuilder:
//               (
//                 flightContext,
//                 animation,
//                 flightDirection,
//                 fromHeroContext,
//                 toHeroContext,
//               ) {
//                 switch (flightDirection) {
//                   case HeroFlightDirection.push:
//                     return Material(
//                       color: Colors.transparent,
//                       child: ScaleTransition(
//                         scale: animation.drive(
//                           Tween<double>(begin: 0, end: 1).chain(
//                             CurveTween(curve: Curves.fastEaseInToSlowEaseOut),
//                           ),
//                         ),
//                         child: fromHeroContext.widget,
//                       ),
//                     );
//                   case HeroFlightDirection.pop:
//                     return Material(
//                       color: Colors.transparent,
//                       child: ScaleTransition(
//                         scale: animation.drive(Tween<double>(begin: 1, end: 1)),
//                         child: toHeroContext.widget,
//                       ),
//                     );
//                 }
//               },
//           child: Text(user.emoji, style: TextStyle(fontSize: 48)),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.amber,
//       ),
//       body: Align(
//         alignment: Alignment.topCenter,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [Text(user.name), Text('${user.age}')],
//         ),
//       ),
//     );
//   }
// }
