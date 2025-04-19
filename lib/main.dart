import 'package:flutter/material.dart';
import 'package:persistent_random_word_generator/repository/objectbox.dart';
import 'package:provider/provider.dart';
import 'package:persistent_random_word_generator/providers/app_state.dart';
import 'package:persistent_random_word_generator/screens/home_page.dart';

Future<void> main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  final objectBox = await ObjectBox.create();

  runApp(MyApp(objectBox: objectBox));
}

class MyApp extends StatelessWidget {
  final ObjectBox objectBox;

  const MyApp({super.key, required this.objectBox});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(objectBox),
      child: MaterialApp(
        title: 'Random Name Generator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}
