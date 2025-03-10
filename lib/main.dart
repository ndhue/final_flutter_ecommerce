import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/routes/router.dart' as router;
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      onGenerateRoute: router.generateRoute,
      //home: RegistrationScreen(),
      initialRoute: entryPointScreenRoute,
    );
  }
}
