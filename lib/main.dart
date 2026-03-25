import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'constants.dart';
import 'providers/display_provider.dart';
import 'screens/display_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  WakelockPlus.enable();

  // Force portrait + immersive
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const BISLDisplayApp());
}

class BISLDisplayApp extends StatelessWidget {
  const BISLDisplayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DisplayProvider()..init(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.dark(
            primary: VividColors.electric,
            secondary: VividColors.gold,
            surface: const Color(0xFF1A1A2E),
          ),
          fontFamily: AppFonts.body,
        ),
        home: const DisplayScreen(),
      ),
    );
  }
}
