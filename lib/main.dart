import 'package:final_ecommerce/data/mock_chat_provider.dart';
import 'package:final_ecommerce/firebase_options.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/routes/router.dart' as router;
import 'package:final_ecommerce/providers/cart_provider.dart'; // ✅ Thêm dòng này
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockChatProvider()),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ), // ✅ Thêm dòng này
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      onGenerateRoute: router.generateRoute,
      initialRoute: entryPointScreenRoute,
    );
  }
}
