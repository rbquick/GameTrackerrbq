//
//  myColors.swift
//  HandicappMulti
//
//  Created by Brian Quick on 2022-02-02.
//
/*
 These are the names of the colors defined in the Assets

 See PlayingColors project to examples
    it also has swiftgen running in it to get a different outlook

 Converting the assets to different color requirements
 for any selected color like blue
 let assetName = myColors.blue.rawValue
 let color = Color(assetName)
 let uiColor = UIColor(named: assetName) // for iOS
 let nsColor = NSColor(named: NSColor.Name(assetName)) // for macOS
 */

import Foundation

enum myColors: String, CaseIterable, Identifiable {
    case beige
    case black
    case blue
    case brown
    case cyan
    case gray
    case green
    case indigo
    case link
    case magenta
    case metal
    case mint
    case orange
    case pink
    case purple
    case red
    case rose
    case ruby
    case teal
    case white
    case yellow
    var id: myColors { self }
}
