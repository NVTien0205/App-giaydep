import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:giaydep_app/utils/common_func.dart';
import 'package:giaydep_app/utils/notification_controller.dart';
import 'package:giaydep_app/view/splash_screen/splash_screen.dart';
import 'package:giaydep_app/viewmodel/auth_viewmodel.dart';
import 'package:giaydep_app/viewmodel/order_viewmodel.dart';
import 'package:giaydep_app/viewmodel/post_viewmodel.dart';
import 'package:giaydep_app/viewmodel/product_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

GlobalKey<NavigatorState> navigationKey = GlobalKey();

final formatCurrency =
    NumberFormat.currency(locale: 'vi_VN', decimalDigits: 0, symbol: 'đ');

Future<void> main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationController.initializeNotifications(debug: true);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white, // navigation bar color
    statusBarColor: Colors.white, // status bar color
  ));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => ProductViewModel()),
      ChangeNotifierProvider(create: (_) => PostViewModel()),
      ChangeNotifierProvider(create: (_) => OrderViewModel()),
    ],
    child: Builder(
      builder: (context) {
        return const MyApp();
      },
    ),
  ));

  CommonFunc.configLoading();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigationKey,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Bỏ const nếu SplashScreen không hỗ trợ const
      builder: EasyLoading.init(),
    );
  }
}
