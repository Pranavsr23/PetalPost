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
    SimpleEntry(
      date: Date(),
      preview: "Open PetalPost",
      sender: "",
      mode: "latest",
      daysTogether: 0,
      nextMilestone: 0,
      blurMode: true,
      lockedUntil: "",
      hasUnread: false,
      anniversaryDate: ""
    )
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
    let mode = data.string(forKey: "widget_mode") ?? "latest"
    let daysTogether = data.int(forKey: "anniversary_days") ?? 0
    let nextMilestone = data.int(forKey: "anniversary_next_milestone") ?? 0
    let blurMode = data.bool(forKey: "widget_blur_mode") ?? true
    let lockedUntil = data.string(forKey: "latest_note_locked_until") ?? ""
    let hasUnread = data.bool(forKey: "latest_note_unread") ?? false
    let anniversaryDate = data.string(forKey: "anniversary_date") ?? ""
    return SimpleEntry(
      date: Date(),
      preview: preview,
      sender: sender,
      mode: mode,
      daysTogether: daysTogether,
      nextMilestone: nextMilestone,
      blurMode: blurMode,
      lockedUntil: lockedUntil,
      hasUnread: hasUnread,
      anniversaryDate: anniversaryDate
    )
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let preview: String
  let sender: String
  let mode: String
  let daysTogether: Int
  let nextMilestone: Int
  let blurMode: Bool
  let lockedUntil: String
  let hasUnread: Bool
  let anniversaryDate: String
}

struct PetalPostWidgetView: View {
  var entry: SimpleEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    Group {
      if entry.mode == "anniversary" {
        AnniversaryWidgetView(entry: entry, family: family)
      } else {
        LatestNoteWidgetView(entry: entry, family: family)
      }
    }
    .widgetURL(URL(string: "petalpost://home"))
  }
}

struct LatestNoteWidgetView: View {
  let entry: SimpleEntry
  let family: WidgetFamily

  private var labelText: String {
    entry.sender.isEmpty ? "PetalPost" : "From \(entry.sender)"
  }

  private var isLocked: Bool {
    !entry.lockedUntil.isEmpty
  }

  private var showBlur: Bool {
    entry.blurMode || isLocked
  }

  private var displayPreview: String {
    showBlur ? "Tap to reveal" : entry.preview
  }

  private var metaText: String {
    entry.hasUnread ? "New" : "Updated"
  }

  private var isEmptyState: Bool {
    entry.preview == "Open PetalPost" && entry.sender.isEmpty
  }

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [Color(red: 0.98, green: 0.9, blue: 0.93), .white],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      switch family {
      case .systemSmall:
        VStack(spacing: 8) {
          HStack {
            Text(labelText)
              .font(.caption2)
              .fontWeight(.bold)
              .foregroundColor(.secondary)
            Spacer()
            if entry.hasUnread {
              Circle()
                .fill(Color.petalPrimary)
                .frame(width: 6, height: 6)
            }
          }
          Spacer()
          if isEmptyState {
            VStack(spacing: 6) {
              Image(systemName: "square.and.pencil")
                .font(.title2)
                .foregroundColor(Color.petalPrimary)
              Text("Send a note")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color.petalInk)
            }
          } else {
            Text(displayPreview)
              .font(.system(size: 14, weight: .bold))
              .multilineTextAlignment(.center)
              .foregroundColor(Color.petalInk)
              .lineLimit(3)
          }
          Spacer()
          Text(isEmptyState ? "Your turn" : metaText)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
        }
        .padding()
      case .systemMedium:
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            Text(labelText)
              .font(.caption2)
              .fontWeight(.bold)
              .foregroundColor(.secondary)
            Spacer()
            Text(isEmptyState ? "No notes" : metaText)
              .font(.caption2)
              .fontWeight(.bold)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.white.opacity(0.3))
              .clipShape(Capsule())
              .foregroundColor(.white)
          }
          Spacer()
          if isEmptyState {
            VStack(alignment: .leading, spacing: 6) {
              Text("Thinking of them?")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.petalInk)
              Text("Send a note")
                .font(.caption)
                .fontWeight(.bold)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color.petalPrimary)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
          } else {
            Text(displayPreview)
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(Color.petalInk)
              .lineLimit(2)
            Text(entry.sender.isEmpty ? "" : "From \(entry.sender)")
              .font(.caption)
              .fontWeight(.semibold)
              .foregroundColor(.secondary)
          }
        }
        .padding()
      default:
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Text(entry.sender.isEmpty ? "Your Note" : entry.sender)
              .font(.headline)
              .foregroundColor(Color.petalInk)
            Spacer()
            Text(isEmptyState ? "Quiet" : metaText)
              .font(.caption2)
              .fontWeight(.bold)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color.petalPrimary.opacity(0.15))
              .clipShape(Capsule())
              .foregroundColor(Color.petalPrimary)
          }
          if isEmptyState {
            Text("Your inbox is quiet.")
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(Color.petalInk)
            Text("Be the first to send love.")
              .font(.caption)
              .foregroundColor(Color.petalMuted)
            Text("Send a note")
              .font(.caption)
              .fontWeight(.bold)
              .padding(.vertical, 8)
              .frame(maxWidth: .infinity)
              .background(Color.petalPrimary)
              .foregroundColor(.white)
              .clipShape(Capsule())
          } else {
            Text(displayPreview)
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(Color.petalInk)
              .lineLimit(3)
            if showBlur {
              Text("Tap to reveal")
                .font(.caption)
                .fontWeight(.bold)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.petalPrimary)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
          }
          Spacer()
        }
        .padding()
      }
    }
  }
}

struct AnniversaryWidgetView: View {
  let entry: SimpleEntry
  let family: WidgetFamily

  private var hasDate: Bool {
    !entry.anniversaryDate.isEmpty && entry.daysTogether > 0
  }

  private var milestoneText: String {
    if !hasDate {
      return "Add Anniversary"
    }
    if entry.nextMilestone == 0 {
      return "Next: Today"
    }
    return "Next: \(entry.daysTogether + entry.nextMilestone)"
  }

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [Color.white, Color(red: 0.98, green: 0.96, blue: 0.97)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      switch family {
      case .systemSmall:
        VStack(spacing: 6) {
          Spacer()
          Text(hasDate ? "\(entry.daysTogether)" : "--")
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(Color.petalPrimary)
          Text(hasDate ? "Days Together" : "Set a date")
            .font(.caption)
            .foregroundColor(Color.petalMuted)
          Spacer()
          Text(milestoneText)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.petalPrimary.opacity(0.15))
            .clipShape(Capsule())
            .foregroundColor(Color.petalPrimary)
        }
        .padding()
      case .systemMedium:
        ZStack {
          Color.white
          VStack(alignment: .leading, spacing: 6) {
            Text(hasDate ? "\(entry.daysTogether)" : "--")
              .font(.system(size: 44, weight: .bold))
              .foregroundColor(Color.petalPrimary)
            Text(hasDate ? "Days Together" : "Set a date")
              .font(.caption)
              .foregroundColor(Color.petalMuted)
            Spacer()
            Text(milestoneText)
              .font(.caption2)
              .fontWeight(.bold)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color.petalPrimary.opacity(0.15))
              .clipShape(Capsule())
              .foregroundColor(Color.petalPrimary)
          }
          .padding()
        }
      default:
        ZStack {
          Color.white
          VStack(alignment: .leading, spacing: 10) {
            Text("PetalPost")
              .font(.caption)
              .fontWeight(.bold)
              .foregroundColor(Color.petalPrimary)
            Spacer()
            Text(hasDate ? "\(entry.daysTogether)" : "--")
              .font(.system(size: 54, weight: .bold))
              .foregroundColor(Color.petalPrimary)
            Text(hasDate ? "Days Loving You" : "Set a date")
              .font(.headline)
              .foregroundColor(Color.petalMuted)
            Text(milestoneText)
              .font(.caption)
              .fontWeight(.bold)
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(Color.petalPrimary.opacity(0.15))
              .clipShape(Capsule())
              .foregroundColor(Color.petalPrimary)
            Spacer()
          }
          .padding()
        }
      }
    }
  }
}

private extension Color {
  static let petalPrimary = Color(red: 0.93, green: 0.17, blue: 0.36)
  static let petalInk = Color(red: 0.13, green: 0.05, blue: 0.07)
  static let petalMuted = Color(red: 0.6, green: 0.3, blue: 0.37)
  static let petalDark = Color(red: 0.13, green: 0.06, blue: 0.08)
}
