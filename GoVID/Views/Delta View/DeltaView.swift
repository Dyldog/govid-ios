//
//  DeltaView.swift
//  GoVID
//
//  Created by Dylan Elliott on 28/8/21.
//

import SwiftUI
import SwiftUICharts

enum ChartMode: CaseIterable {
    case value
    case change
    
    var title: String {
        switch self {
        case .value: return "Value"
        case .change: return "Change"
        }
    }
}
enum ChartInterval: CaseIterable {
    case week
    case month
    case year
    case allTime
    
    var title: String {
        switch self {

        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        case .allTime: return "All"
        }
    }
    
    var days: Int? {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        case .allTime: return nil
        }
    }
}
struct DeltaView: View {
    @ObservedObject var viewModel = DeltaViewModel()
    @State private var displayedInterval: ChartInterval = .week
    @State private var chartMode: ChartMode = .value

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Historical Case Numbers")
                    .font(.title)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(white: 0.2).opacity(0.1))
                    .frame(height: 300)
                LineView(
                    data: viewModel.stats(for: displayedInterval, mode: chartMode).map { Double($0.1) },
                    style: ChartStyle(
                        backgroundColor: Color.clear,
                        accentColor: .white,
                        secondGradientColor: .white,
                        textColor: .white,
                        legendTextColor: .white,
                        dropShadowColor: .clear
                    )
                )
                .frame(height: 300)
                .padding()
            }
            .background(Color.clear)
//            .frame(height: 300)
            
            Picker(
                selection: $displayedInterval,
                label: Text("Show")
            ) {
                ForEach(ChartInterval.allCases, id: \.self) {
                    Text($0.title)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Picker(
                selection: $chartMode,
                label: Text("Mode")
            ) {
                ForEach(ChartMode.allCases, id: \.self) {
                    Text($0.title)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
        }
        .padding()
        .background(Color.blue)
        .edgesIgnoringSafeArea(.top)
    }
}

struct DeltaView_Previews: PreviewProvider {
    
    static var previews: some View {
        DeltaView()
    }
}
