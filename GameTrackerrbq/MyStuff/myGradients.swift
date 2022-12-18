//
//  myGradients.swift
//  HandicappMulti
//
//  Created by Brian Quick on 2022-02-06.
//
// Used in ButtonModifiers.swift

import SwiftUI

struct BackgroundGradientViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[0]), Color(MyDefaults().gradientDefaults[1])]), startPoint: .top, endPoint: .bottom))
    }
}



struct myBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[1]), Color(MyDefaults().gradientDefaults[0])]), startPoint: .top, endPoint: .bottom))
    }
}

extension View {
    func myBackgroundStyle() -> some View {
        self.modifier(myBackgroundModifier())
    }
}




struct myButtonViewModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    func body(content: Content) -> some View {

        content
            .frame(width: width, height: height)
            .foregroundColor(.init(Color.RGBColorSpace.sRGB, red: 0.0, green: 0.0, blue: 1.0))
            .background(LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[0]), Color(MyDefaults().gradientDefaults[1])]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(8)
            .font(height == 50 ? .largeTitle : .none)
            .foregroundColor(.init(Color.RGBColorSpace.sRGB, red: 0.0, green: 0.0, blue: 1.0))
            .padding(6)
            .background(LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[1]), Color(MyDefaults().gradientDefaults[0])]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(8)

    }
}
extension View {
    func myButtonViewStyle(width: CGFloat = MyDefaults().buttonWidth, height: CGFloat = MyDefaults().buttonHeight) -> some View {
        self.modifier(myButtonViewModifier(width: width, height: height))
    }
}

