# 💍 ספירה לאחור לחתונה — Wedding Countdown

אפליקציית Android (Flutter) שמציגה ספירה לאחור רומנטית עד תאריך ושעת החתונה,
כולל **Widget למסך הבית** ותמיכה מלאה ב**עברית / RTL**.
הכל מוגדר מראש (ללא מסך הגדרות), והאפליקציה עובדת **לחלוטין ללא אינטרנט**.

מותאמת ל-**QIN F22 Pro (Android 12)** ולכל מכשיר אנדרואיד עם API 23 ומעלה.

---

## ✨ תכונות

- מסך ראשי עם **תמונת רקע מוגדרת מראש** (`assets/images/background.jpg`).
- כותרת קבועה: "עד החתונה שלנו".
- ספירה לאחור **בזמן אמת**: שעות · דקות · שניות.
- עיצוב מודרני, אלגנטי ורומנטי.
- **בלי כפתורים / בלי מסך הגדרות** — הכל מוגדר מראש בקוד/בנכסים.
- **עובד אופליין** — ללא תלות באינטרנט.
- **Widget למסך הבית** שמציג את הזמן שנותר.
- כשהספירה מגיעה לאפס מוצגת ההודעה: **"היום הגדול הגיע!"** 🎉

---

## 🗂️ מבנה הפרויקט

```
wedding_countdown/
├── pubspec.yaml
├── analysis_options.yaml
├── assets/images/background.jpg      # תמונת הרקע המוגדרת מראש (להחלפה)
├── lib/
│   ├── main.dart                     # נקודת כניסה + RTL + תמה
│   ├── config.dart                   # כתובת עדכון מרחוק (אופציונלי)
│   ├── theme/app_theme.dart          # פלטת צבעים ועיצוב
│   ├── models/wedding_settings.dart  # מודל + מועד החתונה הקבוע
│   ├── services/settings_service.dart      # טעינה + סנכרון Widget
│   ├── services/remote_config_service.dart # עדכון תוכן מרחוק (אופציונלי)
│   ├── widgets/countdown_tile.dart   # אריח ספירה בודד
│   └── screens/
│       └── home_screen.dart          # המסך הראשי + הספירה
└── android/
    └── app/src/main/
        ├── AndroidManifest.xml       # כולל ה-receiver של ה-Widget
        ├── kotlin/.../MainActivity.kt
        ├── kotlin/.../WeddingWidgetProvider.kt  # לוגיקת ה-Widget
        └── res/
            ├── layout/wedding_widget.xml
            ├── xml/wedding_widget_info.xml
            └── drawable/...           # רקע Widget, אייקון, מסך פתיחה
```

---

## 🛠️ דרישות מקדימות

- Flutter SDK (גרסה 3.x ומעלה) — בדקו עם `flutter doctor`.
- Android SDK (מותקן אוטומטית עם Android Studio).
- JDK 17.

---

## 🚀 בנייה והרצה (יצירת APK)

> הפרויקט כולל את כל קבצי המקור. הקובץ הבינארי היחיד שלא ניתן לשלוח כטקסט
> הוא ה-Gradle Wrapper (`gradle-wrapper.jar` + הסקריפטים `gradlew`).
> השלב הראשון למטה מייצר אותו פעם אחת.

### שלב 1 — יצירת ה-Gradle Wrapper (פעם אחת)

הריצו מתוך תיקיית הפרויקט:

```bash
flutter create --platforms=android --org com.eliavital --project-name wedding_countdown temp_scaffold
```

העתיקו מתוך `temp_scaffold/android/` אל `android/` של הפרויקט את:

- `gradle/` (התיקייה כולה — מכילה את `gradle-wrapper.jar`)
- `gradlew`
- `gradlew.bat`

לאחר מכן מחקו את `temp_scaffold`.

> חלופה: אם מותקן אצלכם Gradle גלובלי, אפשר במקום זאת להריץ `gradle wrapper`
> בתוך תיקיית `android/`. או פשוט לפתוח את הפרויקט ב-Android Studio שמייצר את ה-Wrapper אוטומטית.

### שלב 2 — התקנת תלויות

```bash
flutter pub get
```

### שלב 2.5 — יצירת אייקון האפליקציה (פעם אחת)

האייקון נוצר מהתמונה `assets/icon/app_icon.png`. הריצו:

```bash
dart run flutter_launcher_icons
```

> שלב זה חובה לפני הבנייה, מכיוון שה-AndroidManifest מצביע על `@mipmap/ic_launcher`.
> כדי להחליף את האייקון בעתיד — החליפו את `assets/icon/app_icon.png` (תמונה ריבועית) והריצו שוב את הפקודה.

### שלב 3 — בניית ה-APK

```bash
flutter build apk --release
```

קובץ ה-APK ייווצר בנתיב:

```
build/app/outputs/flutter-apk/app-release.apk
```

העבירו אותו ל-QIN F22 Pro והתקינו (יש לאשר "התקנה ממקורות לא ידועים").

### 💡 APK קל יותר למכשיר חלש (מומלץ ל-QIN)

כדי לקבל קובץ קטן בהרבה (במקום APK אוניברסלי כבד), בנו לפי ארכיטקטורה:

```bash
flutter build apk --release --split-per-abi
```

ייווצרו מספר קבצים בתיקייה `build/app/outputs/flutter-apk/`. ל-QIN F22 Pro
התקינו בדרך כלל את **`app-armeabi-v7a-release.apk`** (מעבד 32-ביט נפוץ במכשירים חלשים);
אם הוא לא מתקין, נסו את **`app-arm64-v8a-release.apk`**. זהו ה-APK הקל ביותר.

### הרצה ישירה על המכשיר (לפיתוח)

```bash
flutter run --release
```

---

## 📱 הוספת ה-Widget למסך הבית

1. התקינו והפעילו את האפליקציה פעם אחת (כדי לאתחל את הנתונים).
2. לחיצה ארוכה על מסך הבית ← **ווידג'טים / Widgets**.
3. אתרו את "ספירה לחתונה" וגררו אותו למסך.
4. ה-Widget מתעדכן אוטומטית כל ~30 דקות, וכן בכל פעם שתשמרו הגדרות חדשות.
   לחיצה על ה-Widget פותחת את האפליקציה.

> הערה טכנית: ווידג'טים של אנדרואיד אינם מתעדכנים כל שנייה (מגבלת מערכת),
> ולכן ה-Widget מציג ימים/שעות/דקות. הספירה לשנייה מופיעה בתוך האפליקציה עצמה.

---

## 🎨 מועד החתונה והגדרות

מועד החתונה **קבוע בקוד ואינו ניתן לשינוי באפליקציה**:
**י״ד בתמוז תשפ״ו = יום שני, 29 ביוני 2026, החופה בשעה 19:00**.
הוא מוגדר בקבוע `kWeddingDateTime` בקובץ `lib/models/wedding_settings.dart`.

**הכל מוגדר מראש — אין מסך הגדרות באפליקציה.**
- **כותרת:** ברירת מחדל `'עד החתונה שלנו'` (ב-`lib/models/wedding_settings.dart`).
- **תמונת רקע:** החליפו את הקובץ `assets/images/background.jpg` בתמונה שלכם **לפני הבנייה**
  (אם הקובץ חסר — מוצג גרדיאנט רומנטי כברירת מחדל).

---

## ☁️ עדכון תוכן מרחוק (אופציונלי — כבוי כברירת מחדל)

האפליקציה עובדת אופליין לחלוטין. אם תרצו, ניתן להפעיל **עדכון תוכן מרחוק**
כך שתוכלו לשנות כותרת / תאריך / תווית עברית / תמונת רקע **בלי לבנות APK מחדש**:

1. העלו קובץ JSON לענן (למשל [GitHub Gist](https://gist.github.com) ולחצו **Raw**, או קובץ ב-repo ציבורי דרך כתובת `raw.githubusercontent.com`). מבנה לדוגמה ב-`wedding_config.example.json`:

```json
{
  "title": "עד החתונה שלנו",
  "hebrewDate": "יום שני · י\"ד בתמוז תשפ\"ו",
  "weddingDateTime": "2026-06-29T19:00:00",
  "backgroundImageUrl": "https://example.com/our-photo.jpg"
}
```

2. הדביקו את הקישור הישיר (raw) בקבוע `kRemoteConfigUrl` בקובץ `lib/config.dart`:

```dart
const String kRemoteConfigUrl = 'https://raw.githubusercontent.com/USER/REPO/main/wedding_config.json';
```

3. בנו והתקינו מחדש פעם אחת. מעתה, בכל פתיחת אפליקציה **עם אינטרנט** היא תמשוך את הערכים העדכניים ותשמור אותם מקומית. בלי אינטרנט — משתמשת בערך האחרון שנשמר.

> כל השדות אופציונליים. אם משאירים את `kRemoteConfigUrl` ריק — הפיצ'ר כבוי לגמרי ואין שום פנייה לרשת.
> שימו לב: ערך שמגיע מהענן דורס את מה שהוגדר מקומית באפליקציה.

---

## 🔐 חתימת ה-APK

לצורך בנייה מהירה, גרסת ה-release חתומה במפתח ה-debug
(ראו `android/app/build.gradle`). זה מספיק להתקנה אישית על המכשיר.
להפצה רשמית מומלץ ליצור `keystore` אישי ולעדכן את `signingConfigs`.
