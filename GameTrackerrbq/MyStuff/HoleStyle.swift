//
//  HoleStyle.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-29.
//
//  Think of a hole as a square on the screen
//  just a little place to show a number or a color
import SwiftUI

extension Text {
    func holeStyle() -> some View {
        self.modifier(holeModifier())
    }
}
extension TextField {
    func holeStyle() -> some View {
        self.modifier(holeModifier())
    }
}
struct holeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: holeDimensions().holeWidth)
            .foregroundColor(.black)
            //.background(.blue)
            .padding(holeDimensions().holePadding)
            .border(Color.black)
    }
}
struct holeDimensions {
    let titleColumnWidth:CGFloat = 70
    let holeWidth:CGFloat = 20
       let holePadding:CGFloat = 3
}
