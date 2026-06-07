package com.eliavital.wedding_countdown

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Widget למסך הבית שמציג את הזמן שנותר עד החתונה.
 * הנתונים (target_millis, widget_title) מגיעים מצד ה-Flutter דרך home_widget.
 * חישוב הימים/שעות/דקות מתבצע בכל רענון של ה-Widget.
 */
class WeddingWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.wedding_widget)

            val title = widgetData.getString("widget_title", "עד החתונה שלנו")
                ?: "עד החתונה שלנו"
            val targetStr = widgetData.getString("target_millis", "0") ?: "0"
            val target = targetStr.toLongOrNull() ?: 0L

            views.setTextViewText(R.id.widget_title, title)

            val now = System.currentTimeMillis()
            val diff = target - now

            if (target <= 0L) {
                views.setTextViewText(R.id.widget_value, "—")
                views.setTextViewText(R.id.widget_caption, "הגדירו תאריך באפליקציה")
            } else if (diff <= 0L) {
                views.setTextViewText(R.id.widget_value, "🎉")
                views.setTextViewText(R.id.widget_caption, "היום הגדול הגיע!")
            } else {
                val totalMinutes = diff / 60000L
                val days = totalMinutes / (60 * 24)
                val hours = (totalMinutes / 60) % 24
                val minutes = totalMinutes % 60

                views.setTextViewText(R.id.widget_value, days.toString())
                views.setTextViewText(
                    R.id.widget_caption,
                    "ימים • $hours שע׳ $minutes דק׳"
                )
            }

            // לחיצה על ה-Widget פותחת את האפליקציה.
            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
