//
//  Delta View Model.swift
//  GoVID
//
//  Created by Dylan Elliott on 28/8/21.
//

import Foundation

class DeltaViewModel: ObservableObject {
    let api = CovidAPI()
    @Published var stats: [(Date, Int)] = []
    
    init() {
        api.loadAllData { counts in
            DispatchQueue.main.async {
                self.stats = counts
            }
        }
    }
    
    private func mapStats(_ statsToMap: [(Date, Int)], for mode: ChartMode) -> [(Date, Int)] {
        switch mode {
        case .value: return statsToMap
        case .change: return zip(statsToMap, statsToMap.dropFirst()).map { ($1.0, $1.1 - $0.1) }
        }
    }
    
    func stats(for interval: ChartInterval, mode: ChartMode) -> [(Date, Int)] {
        guard let numDays = interval.days else { return mapStats(stats, for: mode) }
        let numSecs = numDays * 24 * 60 * 60
        let intervalStats = stats.filter { -Int($0.0.timeIntervalSinceNow) < numSecs }
        return mapStats(intervalStats, for: mode)
        
        
    }
    
}
