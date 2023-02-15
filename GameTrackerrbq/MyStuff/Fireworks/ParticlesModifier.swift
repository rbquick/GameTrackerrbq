//
//  ParticlesModifier.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2022-12-20.
//

import SwiftUI

struct ParticlesModifier: ViewModifier {
    @State var time = 0.0
    @State var scale = 0.2
    let duration = 15.0

    func body(content: Content) -> some View {
        ZStack {
            ForEach(0..<180, id: \.self) { index in
                content
                    .hueRotation(Angle(degrees: time * 80))
//                    .scaleEffect(scale)
                    .scaleEffect(Double.random(in: 0.5...1.5))
                    .modifier(FireworkParticlesGeometryEffect(time: time))
                    .opacity(((duration-time) / duration))
            }
        }
        .onAppear {
            withAnimation (.easeOut(duration: duration)) {
                self.time = duration
                self.scale = 0.5
            }
        }
    }
}
