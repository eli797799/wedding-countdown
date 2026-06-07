import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/wedding_settings.dart';
import '../services/remote_config_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/countdown_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SettingsService _service = SettingsService();
  final RemoteConfigService _remoteConfig = RemoteConfigService();

  WeddingSettings? _settings;
  Timer? _timer;

  // ValueNotifier מאפשר לעדכן רק את אזור הספירה כל שנייה,
  // בלי לרנדר מחדש את הרקע/הכותרת — חיסכון משמעותי במכשיר חלש.
  final ValueNotifier<Duration> _remaining =
      ValueNotifier<Duration>(Duration.zero);

  @override
  void initState() {
    super.initState();
    _loadAndStart();
  }

  Future<void> _loadAndStart() async {
    // טעינה מקומית מיידית (עובד תמיד, גם אופליין).
    final settings = await _service.load();
    await _service.syncToWidget(settings);
    if (!mounted) return;
    setState(() => _settings = settings);
    _tick();
    _startTimer();

    // עדכון תוכן מרחוק ברקע (אופציונלי; פעיל רק אם הוגדרה כתובת).
    _refreshFromRemote();
  }

  Future<void> _refreshFromRemote() async {
    final changed = await _remoteConfig.fetchAndApply();
    if (!changed || !mounted) return;
    final updated = await _service.load();
    await _service.syncToWidget(updated);
    if (!mounted) return;
    setState(() => _settings = updated);
    _tick();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final target = _settings?.weddingDateTime;
    if (target == null) return;
    final diff = target.difference(DateTime.now());
    _remaining.value = diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return Scaffold(
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(settings),
    );
  }

  Widget _buildBody(WeddingSettings settings) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(settings),
        // שכבת כהות לשיפור הקריאות: כהה למעלה (לכותרת) ולמטה (לתאריך),
        // ובהיר יותר באמצע כדי שהפנים בתמונה יישארו ברורים.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.32, 0.6, 1.0],
              colors: [
                Colors.black.withOpacity(0.55),
                Colors.black.withOpacity(0.12),
                Colors.black.withOpacity(0.20),
                Colors.black.withOpacity(0.62),
              ],
            ),
          ),
        ),
        SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return _buildResponsiveContent(
                    settings,
                    constraints,
                    orientation,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveContent(
    WeddingSettings settings,
    BoxConstraints constraints,
    Orientation orientation,
  ) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    final isLandscape = orientation == Orientation.landscape;

    // כל הריווחים יחסיים לגובה/רוחב המסך — ללא ערכים קבועים.
    // הכותרת ממוקמת גבוה (מעל הפנים בתמונה), והספירה נמוכה יותר.
    final topGap = h * (isLandscape ? 0.03 : 0.05);
    final gapTitleToCountdown = h * (isLandscape ? 0.06 : 0.14);
    final gapM = h * 0.03;
    final horizontalPad = w * 0.06;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: topGap),
              _buildTitle(settings.title, w, h),
              SizedBox(height: gapTitleToCountdown),
              // רק החלק הזה מתעדכן כל שנייה.
              ValueListenableBuilder<Duration>(
                valueListenable: _remaining,
                builder: (context, remaining, _) {
                  final done = !settings.weddingDateTime.isAfter(DateTime.now());
                  return done ? _buildBigDayMessage(w) : _buildCountdown(remaining, w);
                },
              ),
              SizedBox(height: gapM),
              _buildDateLabel(settings, w),
              SizedBox(height: h * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(WeddingSettings settings) {
    final mq = MediaQuery.of(context);
    final cacheW = (mq.size.width * mq.devicePixelRatio).round();

    // עדיפות 1: תמונה שעודכנה מרחוק (אם פעיל); עדיפות 2: התמונה המוגדרת מראש בפרויקט.
    final path = settings.backgroundImagePath;
    if (path != null && File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        cacheWidth: cacheW > 0 ? cacheW : null,
        filterQuality: FilterQuality.low,
        gaplessPlayback: true,
      );
    }

    // תמונת הרקע המוגדרת מראש (assets/images/background.jpg).
    // אם חסרה מסיבה כלשהי — נופלים חזרה לגרדיאנט רומנטי.
    return Image.asset(
      'assets/images/background.jpg',
      fit: BoxFit.cover,
      cacheWidth: cacheW > 0 ? cacheW : null,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) => Container(
        decoration: const BoxDecoration(gradient: AppPalette.romanticGradient),
      ),
    );
  }

  Widget _buildTitle(String title, double w, double h) {
    final iconSize = (w * 0.11).clamp(26.0, 46.0).toDouble();
    final titleSize = (w * 0.105).clamp(22.0, 42.0).toDouble();

    return Column(
      children: [
        Icon(Icons.favorite, color: AppPalette.rose, size: iconSize),
        SizedBox(height: h * 0.012),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              height: 1.2,
              shadows: const [
                Shadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
          ),
        ),
        SizedBox(height: h * 0.012),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            kCoupleNames,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppPalette.gold,
              fontSize: (w * 0.06).clamp(15.0, 24.0).toDouble(),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              shadows: const [
                Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
          ),
        ),
        SizedBox(height: h * 0.014),
        _buildDivider(w),
      ],
    );
  }

  Widget _buildDivider(double w) {
    final lineWidth = (w * 0.12).clamp(28.0, 60.0).toDouble();
    final heartSize = (w * 0.035).clamp(10.0, 16.0).toDouble();
    final color = AppPalette.gold.withOpacity(0.4);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: lineWidth, height: 1, color: color),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.025),
          child: Icon(Icons.favorite, size: heartSize, color: color),
        ),
        Container(width: lineWidth, height: 1, color: color),
      ],
    );
  }

  Widget _buildCountdown(Duration remaining, double w) {
    // סך השעות הכולל (במקום ימים), ואז דקות ושניות.
    final totalHours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    String two(int n) => n.toString().padLeft(2, '0');

    // רוחב אריח נומינלי יחסי; ה-FittedBox החיצוני יכווץ הכול אם צר מדי.
    final tileW = (w * 0.23).clamp(58.0, 96.0).toDouble();
    final gap = (w * 0.035).clamp(8.0, 16.0).toDouble();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CountdownTile(value: two(seconds), label: 'שניות', width: tileW),
          SizedBox(width: gap),
          CountdownTile(value: two(minutes), label: 'דקות', width: tileW),
          SizedBox(width: gap),
          CountdownTile(value: totalHours.toString(), label: 'שעות', width: tileW),
        ],
      ),
    );
  }

  Widget _buildBigDayMessage(double w) {
    final emojiSize = (w * 0.13).clamp(34.0, 56.0).toDouble();
    final msgSize = (w * 0.09).clamp(24.0, 40.0).toDouble();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.07, vertical: w * 0.06),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(w * 0.06),
        border: Border.all(color: AppPalette.gold.withOpacity(0.8), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎉', style: TextStyle(fontSize: emojiSize)),
          SizedBox(height: w * 0.03),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'היום הגדול הגיע!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: msgSize,
                fontWeight: FontWeight.w800,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateLabel(WeddingSettings settings, double w) {
    final gregorian =
        DateFormat("d בMMMM yyyy", 'he').format(settings.weddingDateTime);
    final hebrewSize = (w * 0.05).clamp(14.0, 20.0).toDouble();
    final gregSize = (w * 0.038).clamp(11.0, 15.0).toDouble();

    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            settings.hebrewDateLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: hebrewSize,
              fontWeight: FontWeight.w700,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
        ),
        SizedBox(height: w * 0.01),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            gregorian,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppPalette.blush,
              fontSize: gregSize,
              fontWeight: FontWeight.w500,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
        ),
      ],
    );
  }
}
