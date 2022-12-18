//
//  ButtonModifiers.swift
//  HandicappUI
//
//  Created by Brian Quick on 2021-03-10.
//
// Requires myGradients.swift

import SwiftUI

struct myButton<textContent: View>: View {

    let action: () -> Void
    let content: textContent
    var width: CGFloat
    var height: CGFloat

    init(action: @escaping () -> Void, @ViewBuilder content: () -> textContent,  width: CGFloat = 80, height: CGFloat = 20, myPresented: Bool = false) {
        self.action = action
        self.content = content()
        self.width = width
        self.height = height
    }
    var body: some View {
        Button(action: action) {
            content
                .myButtonViewStyle(width: width, height: height)

        }
        .myButtonViewStyle(width: width, height: height)
        .buttonStyle(StaticButtonStyle())
//        .myButtonStyle()
    }
}
//extension View {
//    func hiddenConditionally(isHidden: Bool) -> some View {
//        isHidden ? AnyView(self.hidden()) : AnyView(self)
//    }
//}
extension View {

    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func hiddenConditionally(_ hidden: Bool, remove: Bool = true) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}


struct myButtonTextModifier: ViewModifier {
    func body(content: Content) -> some View {

    GeometryReader { geo in
        content
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .modifier(BackgroundGradientViewModifier())
    }
//    .background(LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[1]), Color(MyDefaults().gradientDefaults[0])]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(8)
    }
}
extension View {
    func myButtonTextStyle() -> some View {
        self.modifier(myButtonTextModifier())
    }
}
struct myButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.init(Color.RGBColorSpace.sRGB, red: 0.0, green: 0.0, blue: 1.0))
            .padding(6)
            .modifier(BackgroundGradientViewModifier())
//            .background(LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[1]), Color(MyDefaults().gradientDefaults[0])]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(8)

    }
}
extension View {
    func myButtonStyle() -> some View {
        self.modifier(myButtonModifier())
    }
}


struct myGradientView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[1]), Color(MyDefaults().gradientDefaults[0])]), startPoint: .top, endPoint: .bottom)
    }
}
struct myBackgroundModifierRed: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[1]), Color(MyDefaults().gradientDefaults[0])]), startPoint: .top, endPoint: .bottom))
    }
}
extension View {
    func myBackgroundStyleRed() -> some View {
        self.modifier(myBackgroundModifierRed())
    }
}
struct myRectangle: View {

    var highLight: Bool = false
    var body: some View {
        Rectangle()
            .fill(highLight ? LinearGradient(gradient: Gradient(colors: [.yellow, .blue ]), startPoint: .top, endPoint: .bottom) : LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[1]), Color(MyDefaults().gradientDefaults[0])]), startPoint: .top, endPoint: .bottom))

        }
    }

struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

