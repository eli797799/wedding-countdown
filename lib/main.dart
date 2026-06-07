import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // טעינת נתוני תאריכים לעברית (נדרש לעיצוב תאריכים אופליין).
  await initializeDateFormatting('he', null);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const WeddingCountdownApp());
}

class WeddingCountdownApp extends StatelessWidget {
  const WeddingCountdownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ספירה לאחור לחתונה',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // תמיכה מלאה בעברית ובכיוון מימין לשמאל.
      locale: const Locale('he', 'IL'),
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // הגבלת קנה-המידה של הגופנים כדי שטקסט לא יחרוג במסך הקטן של ה-QIN,
        // גם אם המשתמש הגדיר גופן גדול במערכת ההפעלה.
        final clampedScaler = mq.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.15,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clampedScaler),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
