//
//  PopoverBarView.swift
//  NavigationMacrosMulti
//
//  Created by Brian Quick on 2022-02-08.
//

import SwiftUI

struct PopoverBarView: View {
    @Binding var isActive: Bool

    @State var title: String = ""
    @State var subtitle: String? = nil
    @State var showBackButton: Bool = true

    var body: some View {

        HStack {
            if showBackButton {
            Text("<Back")
                .onTapGesture {
                    isActive = false
                }
            }
            Spacer()
            Text(title)
            if MyDefaults().showViewNames {
            Spacer()

            Text(subtitle ?? "")
            } else {
                Spacer()
            }
        }
        .font(.title3)

        .modifier(BackgroundGradientViewModifier())
    }
}

struct PopoverBarView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverBarView(isActive: .constant(true), title: "Preview title", subtitle: "subtitle", showBackButton: true)
    }
}
