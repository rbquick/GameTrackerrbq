//
//  TextSpinner.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2024-08-02.
//

import SwiftUI

struct TextSpinner: View {
    @Binding var msgText: String
    @State private var angle: Double = 360  // Initial rotation angle for one clockwise revolution
    @State private var scale: CGFloat = 1.0
    var visibleDuration: Double
    
    var body: some View {
        if msgText != "" {
            Text("\(msgText)")
                .rotationEffect(.degrees(angle))  // Apply initial rotation
                .scaleEffect(scale)
                .onAppear {
                    startAnimation()
                    startTimer()
                }
        }
    }
    
    private func startAnimation() {
        withAnimation(Animation.linear(duration: 1.5).repeatCount(Int(visibleDuration / 1.5), autoreverses: false)) {
            angle = angle == 360 ? -360 : 360  // Alternate between two angles
            scale = angle / 100
        }
    }
    
    private func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + visibleDuration) {
            msgText = ""
        }
    }
}









//struct TextSpinner: View {
//    @Binding var msgText: String
//    @State private var angle: Double = 360  // Initial rotation angle for one clockwise revolution
//    @State private var scale: CGFloat = 1.0
//    var body: some View {
//        if msgText != "" {
//            Text("\(msgText)")
//                .rotationEffect(.degrees(angle))  // Apply initial rotation
//                .scaleEffect(scale)
//                .onAppear() {
//                    withAnimation(Animation.linear(duration: 1.5).repeatCount(5, autoreverses: false)) {
//                        angle = angle == 360 ? -360 : 360  // Alternate between two angles
//                        scale = angle / 100
//                    }
//                }
//            
//        }
//    }
//}

//#Preview {
//    TextSpinner(msgText: "testing spinn")
//}
