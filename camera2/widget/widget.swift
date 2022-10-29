//
//  widget.swift
//  widget
//
//  Created by Данила Ярмаркин on 03.01.2022.
//

import WidgetKit
import SwiftUI
import Intents
import Firebase
import CoreMedia

struct Provider: IntentTimelineProvider {
    let ref = Database.database(url: "https://camera-scan2.europe-west1.firebasedatabase.app/").reference()
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), devicesAmount: 0)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, devicesAmount: 0)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        ref.child("devicesAmount").getData() {error, snapshot in
            let val = snapshot.value
            if let v = val as? Int {
                entries.append(SimpleEntry(date: Date(), configuration: configuration, devicesAmount: v))
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let devicesAmount: Int
}

struct widgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        VStack {
            Text("Devices Amount")
            Text("\(entry.devicesAmount)")
        }
    }
}

@main
struct widget: Widget {
    init() {
        FirebaseApp.configure()
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            WidgetCenter.shared.reloadAllTimelines()
        }
        timer.tolerance = 0.5
    }
    
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
    
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), devicesAmount: 0))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
