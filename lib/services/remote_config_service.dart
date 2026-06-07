import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'settings_service.dart';

/// שירות אופציונלי לעדכון תוכן מרחוק.
///
/// אם [kRemoteConfigUrl] ריק — השירות לא עושה דבר (אופליין מלא).
/// אחרת, הוא מנסה למשוך קובץ JSON בענן ולעדכן כותרת/תאריך/תווית/תמונת רקע.
/// כל הערכים נשמרים מקומית, כך שגם בלי רשת התצוגה משתמשת בערך האחרון.
///
/// מבנה ה-JSON הנתמך (כל השדות אופציונליים):
/// {
///   "title": "עד החתונה שלנו",
///   "hebrewDate": "יום שני · י\"ד בתמוז תשפ\"ו",
///   "weddingDateTime": "2026-06-29T19:00:00",
///   "backgroundImageUrl": "https://.../photo.jpg"
/// }
class RemoteConfigService {
  static const _kBgUrlKey = 'wedding_remote_bg_url';
  static const _kTitleKey = 'wedding_title';
  static const _kImageKey = 'wedding_bg_image';

  /// מושך ומחיל את ההגדרות מהענן. מחזיר true אם משהו השתנה.
  /// בטוח לחלוטין: כל תקלה/היעדר רשת פשוט מוחזרת כ-false.
  Future<bool> fetchAndApply() async {
    if (kRemoteConfigUrl.trim().isEmpty) return false;

    try {
      final response = await http
          .get(Uri.parse(kRemoteConfigUrl))
          .timeout(kRemoteTimeout);

      if (response.statusCode != 200) return false;

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map) return false;

      final prefs = await SharedPreferences.getInstance();
      var changed = false;

      final title = data['title'];
      if (title is String && title.trim().isNotEmpty) {
        await prefs.setString(_kTitleKey, title.trim());
        changed = true;
      }

      final hebrew = data['hebrewDate'];
      if (hebrew is String && hebrew.trim().isNotEmpty) {
        await prefs.setString(SettingsService.kRemoteHebrewKey, hebrew.trim());
        changed = true;
      }

      final dateStr = data['weddingDateTime'];
      if (dateStr is String && dateStr.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(dateStr.trim());
        if (parsed != null) {
          await prefs.setInt(
            SettingsService.kRemoteDateKey,
            parsed.millisecondsSinceEpoch,
          );
          changed = true;
        }
      }

      final bgUrl = data['backgroundImageUrl'];
      if (bgUrl is String && bgUrl.trim().isNotEmpty) {
        final downloaded = await _downloadImageIfNew(prefs, bgUrl.trim());
        if (downloaded) changed = true;
      }

      return changed;
    } catch (_) {
      // אין רשת / שגיאה — מתעלמים בשקט. האפליקציה ממשיכה אופליין.
      return false;
    }
  }

  /// מוריד את תמונת הרקע רק אם הכתובת שונה מזו שכבר הורדה.
  Future<bool> _downloadImageIfNew(SharedPreferences prefs, String url) async {
    try {
      final lastUrl = prefs.getString(_kBgUrlKey);
      if (lastUrl == url && prefs.getString(_kImageKey) != null) {
        return false; // כבר הורדה
      }

      final response = await http.get(Uri.parse(url)).timeout(kRemoteTimeout);
      if (response.statusCode != 200) return false;

      final dir = await getApplicationDocumentsDirectory();
      var ext = p.extension(Uri.parse(url).path);
      if (ext.isEmpty || ext.length > 5) ext = '.jpg';
      final dest = p.join(
        dir.path,
        'wedding_bg_remote_${DateTime.now().millisecondsSinceEpoch}$ext',
      );
      await File(dest).writeAsBytes(response.bodyBytes);

      await prefs.setString(_kImageKey, dest);
      await prefs.setString(_kBgUrlKey, url);
      return true;
    } catch (_) {
      return false;
    }
  }
}
