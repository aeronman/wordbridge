import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:wordbridge/firebase_options.dart';
import 'package:wordbridge/screens/admin_home.dart';
import 'package:wordbridge/screens/home.dart';
import 'package:wordbridge/screens/data/hive.dart';
import 'package:wordbridge/screens/models/item_box.dart';
import 'package:wordbridge/screens/providers/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteModelAdapter());
  favorite = await Hive.openBox<FavoriteModel>('favorite');
  runApp(
    WordBridgeMain(),
  );
}

class WordBridgeMain extends StatelessWidget {
  const WordBridgeMain({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                final userId = snapshot.data!.uid;
                return AdminHome(
                  userId: userId,
                );
              }
              return AppMainScreen();
            }),
      ),
    );
  }
}
