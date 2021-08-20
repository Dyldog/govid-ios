//
//  LoadingSpinner.swift
//  CovidNums
//
//  Created by Dylan Elliott on 20/8/21.
//

import SwiftUI

struct LoadingSpinner: View {
    @State var angle: Double = 0.0
        @State var isAnimating = false
        
        var foreverAnimation: Animation {
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        }

    var body: some View {
        VStack {
            Image("Face").renderingMode(.template)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .rotationEffect(Angle(degrees: self.isAnimating ? 360.0 : 0.0))
                    .animation(self.foreverAnimation, value: isAnimating)
                    .onAppear {
                        self.isAnimating = true
                }
        }
    }
}

struct LoadingSpinner_Previews: PreviewProvider {
    static var previews: some View {
        LoadingSpinner()
    }
}
