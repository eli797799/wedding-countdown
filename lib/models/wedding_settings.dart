/// תאריך ושעת החתונה — ברירת המחדל הקבועה.
/// י"ד בתמוז תשפ"ו = יום שני, 29 ביוני 2026, בשעה 19:00 (החופה).
/// (ניתן לעדכון אופציונלי מרחוק בלבד — לא דרך מסך האפליקציה.)
final DateTime kWeddingDateTime = DateTime(2026, 6, 29, 19, 0);

/// מחרוזת התאריך העברי להצגה במסך (ברירת מחדל).
const String kWeddingHebrewDate = 'יום שני · י״ד בתמוז תשפ״ו';

/// שמות בני הזוג (תת-כותרת אישית).
const String kCoupleNames = 'אלי & אביטל';

/// מודל ההגדרות של האפליקציה.
/// הכותרת ותמונת הרקע ניתנות לשינוי במסך ההגדרות.
/// התאריך והתווית העברית קבועים במכשיר, אך ניתנים לעדכון אופציונלי מרחוק.
class WeddingSettings {
  /// כותרת אישית שתוצג במסך הראשי.
  final String title;

  /// נתיב מקומי לתמונת רקע מותאמת אישית (null = רקע ברירת מחדל).
  final String? backgroundImagePath;

  /// תאריך ושעת החתונה.
  final DateTime weddingDateTime;

  /// תווית התאריך העברי להצגה.
  final String hebrewDateLabel;

  const WeddingSettings({
    required this.title,
    required this.weddingDateTime,
    required this.hebrewDateLabel,
    this.backgroundImagePath,
  });

  /// ערכי ברירת מחדל בהפעלה ראשונה.
  factory WeddingSettings.defaults() {
    return WeddingSettings(
      title: 'עד החתונה שלנו',
      weddingDateTime: kWeddingDateTime,
      hebrewDateLabel: kWeddingHebrewDate,
      backgroundImagePath: null,
    );
  }

  WeddingSettings copyWith({
    String? title,
    String? backgroundImagePath,
    DateTime? weddingDateTime,
    String? hebrewDateLabel,
    bool clearBackgroundImage = false,
  }) {
    return WeddingSettings(
      title: title ?? this.title,
      weddingDateTime: weddingDateTime ?? this.weddingDateTime,
      hebrewDateLabel: hebrewDateLabel ?? this.hebrewDateLabel,
      backgroundImagePath:
          clearBackgroundImage ? null : (backgroundImagePath ?? this.backgroundImagePath),
    );
  }
}
