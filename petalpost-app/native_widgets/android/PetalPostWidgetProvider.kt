package com.petalpost.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PetalPostWidgetProvider : AppWidgetProvider() {
  override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
    val data = HomeWidgetPlugin.getData(context)
    val preview = data.getString("latest_note_preview", "Open PetalPost")
    val sender = data.getString("latest_note_sender", "")
    val hasUnread = data.getBoolean("latest_note_unread", false)

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.petalpost_widget)
      views.setTextViewText(R.id.preview_text, preview)
      views.setTextViewText(R.id.sender_text, sender)
      views.setViewVisibility(R.id.unread_dot, if (hasUnread) android.view.View.VISIBLE else android.view.View.INVISIBLE)
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
