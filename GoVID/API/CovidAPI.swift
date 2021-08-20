//
//  CovidAPI.swift
//  CovidNums
//
//  Created by Dylan Elliott on 20/8/21.
//

import Foundation
import SwiftSoup

enum CovidAPIError: Error {
    case keyMissing(String)
}

struct CovidStats {
    enum Keys: String {
        case livesLostLast24Hrs = "lives lost (last 24 hours)"
        case livesLostTotal = "total lives lost"
        case casesActive = "active cases"
        case casesInHospital = "cases in hospital"
        case casesInICU = "cases in ICU"
        case casesLast24HrsAcquiredInternationallyOrInQuarantine = "internationally acquired & in quarantine (last 24 hours)"
        case casesLast24HrsAcquiredLocally = "cases acquired locally (last 24 hours)"
        case updated = "updated"
    }
    
    let activeCases: Int
    let locallyAcquiredCasesLast24Hrs: Int
    let internationallyAcquiredAndQuarantinedCases: Int
    let totalLivesLost: Int
    let updated: String
    
    init(activeCases: Int, locallyAcquiredCasesLast24Hrs: Int, internationallyAcquiredAndQuarantinedCases: Int, totalLivesLost: Int, updated: String = Date().description) {
        self.activeCases = activeCases
        self.locallyAcquiredCasesLast24Hrs = locallyAcquiredCasesLast24Hrs
        self.internationallyAcquiredAndQuarantinedCases = internationallyAcquiredAndQuarantinedCases
        self.totalLivesLost = totalLivesLost
        self.updated = updated
    }
    
    init(dict: [String: Int], updated: String) throws {
        guard let activeCases = dict[Keys.casesActive.rawValue] else { throw CovidAPIError.keyMissing(Keys.casesActive.rawValue) }
        self.activeCases = activeCases
        
        guard let casesLast24HrsAcquiredLocally = dict[Keys.casesLast24HrsAcquiredLocally.rawValue] else { throw CovidAPIError.keyMissing(Keys.casesLast24HrsAcquiredLocally.rawValue) }
        self.locallyAcquiredCasesLast24Hrs = casesLast24HrsAcquiredLocally
        
        guard let internationallyAcquiredAndQuarantinedCases = dict[Keys.casesLast24HrsAcquiredInternationallyOrInQuarantine.rawValue] else { throw CovidAPIError.keyMissing(Keys.casesLast24HrsAcquiredInternationallyOrInQuarantine.rawValue) }
        self.internationallyAcquiredAndQuarantinedCases = internationallyAcquiredAndQuarantinedCases
        
        guard let livesLostTotal = dict[Keys.livesLostTotal.rawValue] else { throw CovidAPIError.keyMissing(Keys.livesLostTotal.rawValue) }
        self.totalLivesLost = livesLostTotal
        
        self.updated = updated
    }
}

struct CovidAPI {
    let url = URL(string: "https://www.coronavirus.vic.gov.au/victorian-coronavirus-covid-19-data")!
    let loader = WebLoader()
    
    func load(completion: @escaping (CovidStats) -> Void) {
        loader.load(url: url) { html in
            do {
                let doc: Document = try SwiftSoup.parse(html)
                let statEls = try doc.select(".ch-daily-update__statistics-item-inner")
                let statsDict = try statEls.reduce(into: [String: Int]()) { dict, el in
                    let text: Array = try el.children().map { try $0.text() }.reversed()
                    guard let count = Int(text[1]) else { return }
                    dict[text[0]] = count
                }
                
                let updated = try doc.getElementsByClass("app-content")[0].getElementsByTag("h2")[0].text().replacingOccurrences(of: "Updated: ", with: "")
                
                let stats = try mapStatsDict(statsDict, updated: updated)
                
                completion(stats)
            } catch {
                print(error)
            }
        }
    }
    
    private func mapStatsDict(_ stats: [String: Int], updated: String) throws -> CovidStats {
        return try .init(dict: stats, updated: updated)
    }
}
