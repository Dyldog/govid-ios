//
//  StatView.swift
//  GoVID
//
//  Created by Dylan Elliott on 20/8/21.
//

import SwiftUI

struct StatView: View {
    let backgroundColor: Color
    let title: String
    let value: Int
    let padBottom: Bool
    
    var fontSize: CGFloat = 80
    var paddingSize: CGFloat {
        -(fontSize * 0.15)
    }
    
    var body: some View {
        GeometryReader { metrics in
            HStack(alignment: .center) {
                VStack(spacing: padBottom ? 20 : 0) {
                    Spacer()
                    Text(title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 0.1 * metrics.size.width)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    if padBottom == false {
                        Spacer()
                    }
                    
                    Text("\(value)")
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .foregroundColor(.white)
                        .font(.system(size: fontSize, weight: .bold))
                        .padding(.vertical, paddingSize)
                        .padding(.horizontal, 20)
                    
                    if padBottom {
                        Spacer()
                    }
                }
                .frame(maxHeight: 180, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
        }
    }
}
