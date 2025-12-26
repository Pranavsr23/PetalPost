package com.example.petalpost

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class PetalPostWidgetProvider : AppWidgetProvider() {
  override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
    val data = HomeWidgetPlugin.getData(context)
    val preview = data.getString("latest_note_preview", "Open PetalPost")
    val sender = data.getString("latest_note_sender", "")
    val hasUnread = data.getBoolean("latest_note_unread", false)
    val blurMode = data.getBoolean("widget_blur_mode", true)
    val lockedUntil = data.getString("latest_note_locked_until", "")
    val isLocked = !lockedUntil.isNullOrEmpty()
    val mode = data.getString("widget_mode", "latest")
    val daysTogether = data.getInt("anniversary_days", 0)
    val nextMilestone = data.getInt("anniversary_next_milestone", 0)
    val anniversaryDate = data.getString("anniversary_date", "")

    appWidgetIds.forEach { widgetId ->
      val size = resolveWidgetSize(appWidgetManager, widgetId)
      val layoutId = when (mode) {
        "anniversary" -> when (size) {
          WidgetSize.LARGE -> R.layout.petalpost_widget_anniversary_large
          WidgetSize.MEDIUM -> R.layout.petalpost_widget_anniversary_medium
          WidgetSize.SMALL -> R.layout.petalpost_widget_anniversary_small
        }
        else -> when (size) {
          WidgetSize.LARGE -> R.layout.petalpost_widget_latest_large
          WidgetSize.MEDIUM -> R.layout.petalpost_widget_latest_medium
          WidgetSize.SMALL -> R.layout.petalpost_widget_latest_small
        }
      }

      val views = RemoteViews(context.packageName, layoutId)
      if (mode == "anniversary") {
        val hasAnniversary = !anniversaryDate.isNullOrEmpty() && daysTogether > 0
        val dayText = if (hasAnniversary) daysTogether.toString() else "--"
        val labelText = if (hasAnniversary) "Days Together" else "Set a date"
        val milestoneText = if (hasAnniversary) {
          if (nextMilestone == 0) "Next: Today"
          else "Next: ${daysTogether + nextMilestone}"
        } else {
          "Add Anniversary"
        }
        views.setTextViewText(R.id.anniversary_days, dayText)
        views.setTextViewText(R.id.anniversary_label, labelText)
        views.setTextViewText(R.id.anniversary_milestone, milestoneText)
      } else {
        val isEmpty = preview.isNullOrEmpty() || (preview == "Open PetalPost" && sender.isNullOrEmpty())
        val displayPreview = when {
          isLocked -> "Opens soon"
          blurMode -> "Tap to reveal"
          isEmpty -> "Send a note"
          else -> preview
        }
        val senderLine = if (sender.isNullOrEmpty()) "" else "From $sender"
        val label = if (size == WidgetSize.SMALL) {
          if (senderLine.isEmpty()) "PetalPost" else senderLine
        } else {
          "PetalPost"
        }
        val meta = when {
          hasUnread -> "New"
          isEmpty -> "Your turn"
          else -> "Updated"
        }
        val actionText = if (isLocked || blurMode) "Tap to reveal" else "Open PetalPost"
        views.setTextViewText(R.id.latest_label, label)
        views.setTextViewText(R.id.latest_preview, displayPreview)
        views.setTextViewText(R.id.latest_meta, meta)
        views.setTextViewText(R.id.latest_sender, senderLine)
        views.setTextViewText(R.id.latest_action, actionText)
        views.setViewVisibility(
          R.id.unread_dot,
          if (hasUnread) android.view.View.VISIBLE else android.view.View.INVISIBLE
        )
      }

      val intent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("petalpost://home"))
      val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
      views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  private fun resolveWidgetSize(
    appWidgetManager: AppWidgetManager,
    widgetId: Int,
  ): WidgetSize {
    val options = appWidgetManager.getAppWidgetOptions(widgetId)
    val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
    val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
    return when {
      minHeight >= 250 -> WidgetSize.LARGE
      minWidth >= 250 -> WidgetSize.MEDIUM
      else -> WidgetSize.SMALL
    }
  }
}

private enum class WidgetSize {
  SMALL,
  MEDIUM,
  LARGE,
}
