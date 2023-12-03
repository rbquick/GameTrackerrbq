//
//  ColorDefaults.swift
//  icloudIOS
//
//  Created by Brian Quick on 2021-09-24.
//

import SwiftUI

struct ColorDefaults: View {
    @State private var gradColor = MyDefaults().gradientDefaults
    @State private var parColors: [myColors] = []
    @State private var gradientZero: myColors = myColors.red
    @State private var gradientOne: myColors = myColors.red
    @State private var showColorPicker = false
    @EnvironmentObject var sm: StateManager
    var openingTabs = ["Login", "New Game", "Reporting", "Maintenance", "csvExportImport"]
    @State private var openingTabName = "Reporting"
    var body: some View {

        GeometryReader { geo in
            VStack {
                Text("Select the opening screen selection")
                Picker("Select Opening tab", selection: $openingTabName) {
                    ForEach(openingTabs, id: \.self) { idx in
                        Text(idx)
                    }
                }
                HStack {

                    myButton(action: {
                        gradColor = MyDefaults().gradientDefaults
                        gradientZero = myColors(rawValue: gradColor[0])!
                        gradientOne = myColors(rawValue: gradColor[1])!
                    }, content: {
                        Text("GET Gradients")
                    }, width: 150, height: 20)
                    myButton(action: {
                        gradColor[0] = gradientZero.rawValue
                        gradColor[1] = gradientOne.rawValue
                        MyDefaults().gradientDefaults = gradColor
                        sm.setGradintDefaults()
                    }, content: {
                        Text("SET Gradients")
                    }, width: 150, height: 20)
                }
                VStack {
                    HStack {
                        Text("Top Up")
                            .frame(width: 100)
                        Text("")
                            .holeStyle()
                            .background(Color(gradientZero.rawValue))
                        Picker("Top down", selection: $gradientZero, content: {
                            ForEach(myColors.allCases, content: { color in
                                Text(color.rawValue)
                            })
                        }).frame(width:150)
                    }
                    HStack {
                        Text("Bottom Up")
                            .frame(width: 100)
                        Text("")
                            .holeStyle()
                            .background(Color(gradientOne.rawValue))
                        Picker(selection: $gradientOne, label: Text("Bottom Up"), content: {
                            ForEach(myColors.allCases, content: { color in
                                Text(color.rawValue)
                            })
                        }).frame(width:150)
                    }
                }
            }
            // this shows the currently selected gradient on the selector frame
            .background(LinearGradient(gradient: Gradient(colors: [Color(gradientZero.rawValue), Color(gradientOne.rawValue)]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(20)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .modifier(BackgroundGradientViewModifier())
            .onAppear() {
                openingTabName = openingTabs[MyDefaults().openingTabNumber]
            }
            .onDisappear() {
                var idx = 0
                if let index = openingTabs.firstIndex(where: { $0 == openingTabName }) {
                    idx = index
                }
                MyDefaults().openingTabNumber = idx
            }
        }
        .onAppear() {
            gradientZero = myColors(rawValue: gradColor[0])!
            gradientOne = myColors(rawValue: gradColor[1])!
        }
    }

}

// NOT USED:
struct SquareColorPickerView: View {

    @Binding var colorValue: Color
    var stringColor = "rose"

    var body: some View {

        //colorValue
        Color(stringColor)
            .frame(width: holeDimensions().holeWidth, height: holeDimensions().holeWidth, alignment: .center)
            .padding(holeDimensions().holePadding)
            .border(Color.black)
//            .cornerRadius(10.0)
//            .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.white, style: StrokeStyle(lineWidth: 5)))
//            .padding(10)
//            .background(AngularGradient(gradient: Gradient(colors: [.red,.yellow,.green,.blue,.purple,.pink]), center:.center).cornerRadius(20.0))
            .overlay(ColorPicker("", selection: $colorValue).labelsHidden().opacity(0.015))
//            .shadow(radius: 5.0)

    }
}

// Previews OK
struct ColorDefaults_Previews: PreviewProvider {
    static var previews: some View {
        ColorDefaults()
            .environmentObject(StateManager())
    }
}
