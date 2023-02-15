//
//  FireworkParticlesContentView.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2022-12-20.
//
//   Got this from article
//   https://betterprogramming.pub/creating-confetti-particle-effects-using-swiftui-afda4240de6b


import SwiftUI

struct FireworkParticlesContentView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(getRandomColor())
                .frame(width: 30, height: 30)
                .modifier(ParticlesModifier())
                .offset(x: -100, y : -50)

            Circle()
                .fill(getRandomColor())
                .frame(width: 30, height: 30)
                .modifier(ParticlesModifier())
                .offset(x: 60, y : 70)
        }
    }
    func getRandomColor() -> Color{
         let randomRed = CGFloat.random(in: 0...1)
         let randomGreen = CGFloat.random(in: 0...1)
         let randomBlue = CGFloat.random(in: 0...1)
         return Color(red: Double(randomRed), green: Double(randomGreen), blue: Double(randomBlue))
    }
}
