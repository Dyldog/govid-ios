//
//  ContentView.swift
//  CovidNums
//
//  Created by Dylan Elliott on 20/8/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if let stats = viewModel.stats {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            StatView(backgroundColor: .blue, title: "Active Cases", value: stats.activeCases, padBottom: false)
                            StatView(backgroundColor: .red, title: "Locally Acquired Cases\n(Last 24 Hours)", value: stats.locallyAcquiredCasesLast24Hrs, padBottom: false)
                        }
                        HStack(spacing: 0) {
                            StatView(backgroundColor: .green, title: "Cases Acquired Internationally/In Quarantine\n(Last 24 Hours)", value: stats.internationallyAcquiredAndQuarantinedCases, padBottom: false)
                            StatView(backgroundColor: .orange, title: "Total Lives Lost", value: stats.totalLivesLost, padBottom: false)
                        }
                        Text("Data updated \(stats.updated)")
                            .fontWeight(.bold)
                            .padding()
                            .padding(.bottom, proxy.safeAreaInsets.bottom / 2)
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                    }
                } else {
                    VStack {
                        LoadingSpinner()
                            .frame(width: 200, height: 200)
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 110, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.blue)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onTapGesture(count: 3, perform: {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Code@*/ /*@END_MENU_TOKEN@*/
            })
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
