import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/wedding_settings.dart';

/// שירות שמרכז את שמירת/טעינת ההגדרות (עובד לחלוטין ללא אינטרנט)
/// ואת סנכרון הנתונים אל ה-Widget במסך הבית.
///
/// הכותרת ותמונת הרקע נשמרות מהמשתמש.
/// התאריך/התווית העברית מגיעים מברירת המחדל הקבועה, אלא אם עודכנו מרחוק.
class SettingsService {
  static const _kTitleKey = 'wedding_title';
  static const _kImageKey = 'wedding_bg_image';

  // מפתחות לערכים שניתנים לעדכון אופציונלי מרחוק בלבד.
  static const kRemoteDateKey = 'wedding_remote_datetime_millis';
  static const kRemoteHebrewKey = 'wedding_remote_hebrew_label';

  /// מזהה שצריך להתאים לשם ה-AppWidgetProvider בצד אנדרואיד.
  static const _androidWidgetName = 'WeddingWidgetProvider';

  /// טעינת ההגדרות מהאחסון המקומי.
  Future<WeddingSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final title = prefs.getString(_kTitleKey);
    final imagePath = prefs.getString(_kImageKey);
    final remoteMillis = prefs.getInt(kRemoteDateKey);
    final remoteHebrew = prefs.getString(kRemoteHebrewKey);
    final defaults = WeddingSettings.defaults();

    return WeddingSettings(
      title: title ?? defaults.title,
      backgroundImagePath: imagePath,
      weddingDateTime: remoteMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(remoteMillis)
          : defaults.weddingDateTime,
      hebrewDateLabel: remoteHebrew ?? defaults.hebrewDateLabel,
    );
  }

  /// שמירת ההגדרות שהמשתמש עורך (כותרת ותמונה) + עדכון ה-Widget.
  Future<void> save(WeddingSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_kTitleKey, settings.title);

    if (settings.backgroundImagePath != null) {
      await prefs.setString(_kImageKey, settings.backgroundImagePath!);
    } else {
      await prefs.remove(_kImageKey);
    }

    await syncToWidget(settings);
  }

  /// כותב את הנתונים הרלוונטיים אל אחסון ה-Widget ומבקש רענון.
  Future<void> syncToWidget(WeddingSettings settings) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'target_millis',
        settings.weddingDateTime.millisecondsSinceEpoch.toString(),
      );
      await HomeWidget.saveWidgetData<String>('widget_title', settings.title);

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (_) {
      // אם ה-Widget לא זמין (למשל בהרצה ראשונית) פשוט מתעלמים.
    }
  }
}
