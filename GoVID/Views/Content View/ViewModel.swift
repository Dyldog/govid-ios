//
//  ViewModel.swift
//  GoVID
//
//  Created by Dylan Elliott on 20/8/21.
//

import Foundation
import SwiftUI

class ViewModel: NSObject, ObservableObject {
    @Published var stats: CovidStats? = nil
    let api = CovidAPI()
    
    override init() {
        super.init()
        self.reload()
    }
    
    func reload() {
        self.stats = nil
        api.load { stats in
            self.stats = stats
        }
    }
}
