//
//  MainView.swift
//  GoVID
//
//  Created by Dylan Elliott on 28/8/21.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem { Label("Today", systemImage: "chart.bar.fill") }
            DeltaView()
                .tabItem { Label("History", systemImage: "calendar") }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
