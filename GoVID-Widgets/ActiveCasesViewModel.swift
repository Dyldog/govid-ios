//
//  ActiveCasesViewModel.swift
//  GoVID
//
//  Created by Dylan Elliott on 20/8/21.
//

import Foundation
import SwiftUI
import WidgetKit

class ActiveCasesViewModel: NSObject, ObservableObject {
    static func fetch(completion: @escaping (ActiveCasesWidgetView) -> Void) {
        CovidAPI().load { stats in
            completion(ActiveCasesWidgetView(date: Date(), cases: stats.activeCases))
        }
    }
}
