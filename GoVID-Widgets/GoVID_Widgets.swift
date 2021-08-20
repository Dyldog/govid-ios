//
//  GoVID_Widgets.swift
//  GoVID-Widgets
//
//  Created by Dylan Elliott on 20/8/21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ActiveCasesWidgetView {
        ActiveCasesWidgetView(date: Date(), cases: 1337)
    }

    func getSnapshot(in context: Context, completion: @escaping (ActiveCasesWidgetView) -> ()) {
        ActiveCasesViewModel.fetch { view in
            completion(view)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let comps = DateComponents(hour: 0, minute: 0, second: 0)
        
        let today = Calendar.current.date(from: comps)!
        let midnight = today.addingTimeInterval(60 * 60 * 24)
        
        ActiveCasesViewModel.fetch { view in
            let timeline = Timeline(entries: [view], policy: .after(midnight))
            completion(timeline)
        }
    }
}

struct ActiveCasesWidgetView: View, TimelineEntry {
    var date: Date
    
    let cases: Int
    
    var body: some View {
        HStack(spacing: 0) {
            StatView(backgroundColor: .blue, title: "Active Cases", value: cases, padBottom: true)
        }
    }
}

@main
struct GoVID_Widgets: Widget {
    let kind: String = "GoVID_Widgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ActiveCasesWidgetView(date: Date(), cases: entry.cases)
        }
        .configurationDisplayName("GoVID Active Cases")
        .description("The number of active COVID cases in Victoria as reported by the DHHS.")
    }
}

struct GoVID_Widgets_Previews: PreviewProvider {
    static var previews: some View {
        StatView(backgroundColor: .blue, title: "Active Cases", value: 420, padBottom: true)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
