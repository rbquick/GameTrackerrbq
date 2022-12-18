//
//  SectionHeader.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-12-09.
//

import SwiftUI

struct SectionHeader: View {
    @State var key: String
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Text("\(key)")
                    .fontWeight(.bold)
                Spacer()
            }
        }.modifier(BackgroundGradientViewModifier())
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(key: "Section Key")
    }
}
