//
//  StateManager.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-29.
//

import SwiftUI

class StateManager: ObservableObject {

    init() {
        setGradintDefaults()
        openingTabNumber = MyDefaults().openingTabNumber

       // openingTabNumber = MyDefaults().openingTabNumber
//        containerEnvironment = Model().getEnvironment() ? "Production" : "Development"
    }
    func setGradintDefaults() {
        gradientDefaults = MyDefaults().gradientDefaults
                gradient = Gradient(colors: [Color(gradientDefaults[0]), Color(gradientDefaults[1])])
                gradientReversed = Gradient(colors: [Color(gradientDefaults[1]), Color(gradientDefaults[0])])
    }
    @Published var isLoading = true
    @Published var isInternetAvailable = false
    @Published var openingTabNumber = 1
    @Published var containerEnvironment = ""

    // PopoverLink variables
    // these are set up bythe 1st screen shown with the size reader
    // from the adaptiveView
    @Published var popoverLinkWidth: CGFloat = 800
    @Published var popoverLinkHeight: CGFloat = 800
    // this is going to go somewhere global when I get the colors
    // straightened around to they are totally common
    // for now, use these with a different color so I know what I have changed
    @Published var gradientDefaults: [String] = MyDefaults().gradientDefaults
    @Published var gradient: Gradient = Gradient(colors: [Color("blue"), Color("white")])
    @Published var gradientReversed: Gradient = Gradient(colors: [Color("white"), Color("blue")])

}
