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
    func jsonDecoder(_ dateFormat: String) -> JSONDecoder {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = .autoupdatingCurrent
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            return dateFormatter.date(from: dateString)!
        })
        return decoder
    }
    
    func load(completion: @escaping (CovidStats) -> Void) {
        loader.load(url: url) { html in
            do {
                let doc: Document = try SwiftSoup.parse(html)
                let statEls = try doc.select(".ch-daily-update__statistics-item-inner")
                let statsDict = try statEls.reduce(into: [String: Int]()) { dict, el in
                    let text: Array = try el.children().map { try $0.text() }.reversed()
                    let sanitisedValue = text[1].replacingOccurrences(of: ",", with: "")
                    guard let count = Int(sanitisedValue) else { return }
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
    
    func loadPostcodeData(completion: @escaping () -> Void) {
        let url = URL(string: "https://discover.data.vic.gov.au/api/3/action/datastore_search?resource_id=e3c72a49-6752-4158-82e6-116bea8f55c8&limit=50000")!
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                
            } else if let data = data {
                do {
                    let convertedData = try jsonDecoder("dd/MM/yyyy").decode(CovidSuburbCasesResponse.self, from: data)
                    print(convertedData.result.records.count)
//                    print(convertedData.result.records)
                    
                    let lastDate = convertedData.result.records.map { $0.data_date }.max()!
                    print(lastDate)
                    let today = convertedData.result.records.filter { NSCalendar.autoupdatingCurrent.isDate(lastDate, inSameDayAs: $0.data_date) }
                    let activeCases = today.reduce(0, { return $0 + $1.active.value })
                    print("Active: \(activeCases)")
                    
                    let newCases = today.reduce(0, { return $0 + $1.new.value })
                    print("New: \(newCases)")
                    
                    let allCases = convertedData.result.records.reduce(0, { $0 + $1.new.value })
                    print("All: \(allCases)")
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func loadAllData(_ completion: @escaping ([(Date, Int)]) -> Void) {
        let url = URL(string: "https://discover.data.vic.gov.au/api/3/action/datastore_search?resource_id=cc6d89f4-046c-4486-b4a9-63a58fcf9785&limit=50000")!
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                
            } else if let data = data {
                do {
                    let convertedData = try jsonDecoder("yyyy/MM/dd").decode(CovidAllCasesByAreaResponse.self, from: data)
                    let counts = convertedData.result.records
                        .sliced(by: [.year, .month, .day], for: \.diagnosis_date)
                        .map { ($0.key, $0.value.count )}
                        .sorted(by: { $0.0 < $1.0 })
                    completion(counts)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    private func mapStatsDict(_ stats: [String: Int], updated: String) throws -> CovidStats {
        return try .init(dict: stats, updated: updated)
    }
}

protocol StringMappable {
    static func mapString(_ string: String) -> Self
}

extension Int: StringMappable {
    static func mapString(_ string: String) -> Int {
        return Int(string.replacingOccurrences(of: ",", with: ""))!
    }
}

extension Float: StringMappable {
    static func mapString(_ string: String) -> Float {
        return Float(string)!
    }
}

struct MappedString<T: StringMappable & Codable>: Codable {
    let stringValue: String
    var value: T { T.mapString(stringValue) }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        stringValue = try container.decode(String.self)
    }
}

struct CovidSuburbCase: Codable {
    let _id: Int // 99,
    let active: MappedString<Int> // "2",
    let band: MappedString<Int> // "1",
    let cases: MappedString<Int> // "48",
    let data_date: Date // "26/08/2021",
    let new: MappedString<Int> // "0",
    let population: MappedString<Int>? // "28357",
    let postcode: String // "3109",
    let rate: MappedString<Float> // "7.1"
}

struct CovidSuburbCasesResponse: Codable {
    let result: Results
    
    struct Results: Codable {
        let records: [CovidSuburbCase]
    }
}

struct CovidAreaCase: Codable {
    let _id: Int
    let diagnosis_date: Date
    let Localgovernmentarea: String
}

struct CovidAllCasesByAreaResponse: Codable {
    let result: Results
    
    struct Results: Codable {
        let records: [CovidAreaCase]
    }
}

extension Array {
  func sliced(by dateComponents: Set<Calendar.Component>, for key: KeyPath<Element, Date>) -> [Date: [Element]] {
    let initial: [Date: [Element]] = [:]
    let groupedByDateComponents = reduce(into: initial) { acc, cur in
      let components = Calendar.current.dateComponents(dateComponents, from: cur[keyPath: key])
      let date = Calendar.current.date(from: components)!
      let existing = acc[date] ?? []
      acc[date] = existing + [cur]
    }

    return groupedByDateComponents
  }
}
