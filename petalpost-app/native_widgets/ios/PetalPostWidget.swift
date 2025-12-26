import WidgetKit
import SwiftUI
import HomeWidget

struct PetalPostWidget: Widget {
  let kind: String = "PetalPostWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      PetalPostWidgetView(entry: entry)
    }
    .configurationDisplayName("PetalPost")
    .description("Latest note and anniversary info.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), preview: "Open PetalPost", sender: "")
  }

  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
    let entry = loadEntry()
    completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 15))))
  }

  private func loadEntry() -> SimpleEntry {
    let data = HomeWidgetData()
    let preview = data.string(forKey: "latest_note_preview") ?? "Open PetalPost"
    let sender = data.string(forKey: "latest_note_sender") ?? ""
    return SimpleEntry(date: Date(), preview: preview, sender: sender)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let preview: String
  let sender: String
}

struct PetalPostWidgetView: View {
  var entry: SimpleEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(entry.preview)
        .font(.headline)
      if !entry.sender.isEmpty {
        Text("From \(entry.sender)")
          .font(.caption)
      }
    }
    .padding()
  }
}
