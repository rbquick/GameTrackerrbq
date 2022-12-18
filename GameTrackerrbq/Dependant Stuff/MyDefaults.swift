//
//  MyDefaults.swift
//  Handisqlite
//
//  Created by Brian Quick on 2020-12-23.
//
// Requires files
//  myColors.swift ... along with the colors in the assets

import Foundation

import SwiftUI
    /**
     MyDefaults gets/sets the UserDefaults

     - parameter <#parameterName#>: <#Description#>.
     - returns: appropriate type as stored inthe db
     - warning:

     # Notes: #
     1. If you have to set a value, you must create an occurance
            like
            var myDEF = MyDefaults
     */
class MyDefaults {

    let defaults = UserDefaults.standard

    var appDefaultWidth: CGFloat {
        return 920
    }
    var appDefaultHeight: CGFloat {
        return 520
    }
    var buttonWidth: CGFloat {
        return 160
    }
    var buttonHeight: CGFloat {
        return 20
    }
    var thresholdWidth: CGFloat {
        get {
            var myFloat = defaults.float(forKey: "thresholdWidth")
            if myFloat == 0 {
                myFloat = 720
            }
            return CGFloat(myFloat)
        }
        set { defaults.setValue(newValue, forKey: "thresholdWidth")}
    }

    var gradientDefaults: [String] {
        get {
            var myArray = [String]()
            let oneString = MyDefaults().getString(forKey: "gradientDefaults1")
            if oneString == "UnKnown" {
                myArray.append(myColors.metal.rawValue)
            } else {
                myArray.append(oneString)
            }
            let twoString = MyDefaults().getString(forKey: "gradientDefaults2")
            if twoString == "UnKnown" {
                myArray.append(myColors.white.rawValue)
            } else {
                myArray.append(twoString)
            }
            return myArray
        }
        set {
            if newValue.count < 2 {
                MyDefaults().setString(value: myColors.blue.rawValue, forKey: "gradientDefaults1")
                MyDefaults().setString(value: myColors.white.rawValue, forKey: "gradientDefaults2")
            } else {
                MyDefaults().setString(value: newValue[0], forKey: "gradientDefaults1")
                MyDefaults().setString(value: newValue[1], forKey: "gradientDefaults2")
            }
        }
    }
    func setString(value: String, forKey: String) {
        defaults.setValue(value, forKey: forKey)
    }
    func getString(forKey: String) -> String {
        return defaults.string(forKey: forKey) ?? "UnKnown"
    }
    var sqliteLocation: String {
        get { return defaults.string(forKey: "sqliteLocation") ?? "unKnown" }
        set { defaults.setValue(newValue, forKey: "sqliteLocation")}
    }
    var appisInternetAvailable: Bool {
        get { return defaults.bool(forKey: "appisInternetAvailable") }
        set { defaults.setValue(newValue, forKey: "appisInternetAvailable")}
    }
    var appLogging: Bool {
        get { return defaults.bool(forKey: "appLogging") }
        set { defaults.setValue(newValue, forKey: "appLogging")}
    }
    var sqlLogging: Bool {
        get { return defaults.bool(forKey: "sqlLogging") }
        set { defaults.setValue(newValue, forKey: "sqlLogging")}
    }
    var enteringData: Bool {
        get { return defaults.bool(forKey: "enteringData") }
        set { defaults.setValue(newValue, forKey: "enteringData")}
    }
    var printingScoreCard: Bool {
        get { return defaults.bool(forKey: "printingScoreCard") }
        set { defaults.setValue(newValue, forKey: "printingScoreCard")}
    }
    var popScreenName: String {
        get { return defaults.string(forKey: "popScreenName") ?? "" }
        set { defaults.setValue(newValue, forKey: "popScreenName") }
    }
    var Player1ID: Int64 {
        get {
            let lastUserID = defaults.integer(forKey: "Player1ID")
            if lastUserID != 0 {
                return Int64(lastUserID)
            }
            return Int64(1)
        }
        set { defaults.setValue(newValue, forKey: "Player1ID") }
    }
    var Player2ID: Int64 {
        get {
            let lastUserID = defaults.integer(forKey: "Player2ID")
            if lastUserID != 0 {
                return Int64(lastUserID)
            }
            return Int64(2)
        }
        set { defaults.setValue(newValue, forKey: "Player2ID") }
    }
    var Board: String {
        get {
            let lastBoard = defaults.string(forKey: "Board")
            if lastBoard != nil {
                return lastBoard!
            }
            return "Euchre"
        }
        set { defaults.setValue(newValue, forKey: "Board") }
    }
    var scoreEntrySequence: Int {
        get {
            let lastUsed = defaults.integer(forKey: "scoreEntrySequence")
            return lastUsed
        }
        set { defaults.setValue(newValue, forKey: "scoreEntrySequence") }
    }
    var openingTabNumber: Int {
        get {
            var lastUsed = defaults.integer(forKey: "openingTabNumber")
            if lastUsed == 0 {
                lastUsed = 3    // default to maintenance if never run before...s/b 0 for login
            }
            return lastUsed
        }
        set { defaults.setValue(newValue, forKey: "openingTabNumber") }
    }
//    var playerLevel: Int {
//        get {
//            let lastUsed = defaults.integer(forKey: "playerLevel")
//            if lastUsed == 0 {
//                return 1
//            }
//            return lastUsed
//        }
//        set { defaults.setValue(newValue, forKey: "playerLevel") }
//    }
    var playerName: String {
        get {
            let lastPlayerName = defaults.string(forKey: "playerName") ?? ""
            if lastPlayerName.isEmpty {
                return "Regis"
            }
            return lastPlayerName
        }
        set { defaults.setValue(newValue, forKey: "playerName") }
    }
    var numberOfTriviaSayings: Int {
        get {
            let numberOfSayings = defaults.integer(forKey: "numberOfTriviaSayings")
            if numberOfSayings == 0 {
                return 64
            }
            return numberOfSayings
        }
        set { defaults.setValue(newValue, forKey: "numberOfTriviaSayings") }
    }
    var seconds: Double {
        get { return defaults.double(forKey: "secords") }
        set { defaults.setValue(newValue, forKey: "secords") }
    }
    var showDetails: Bool {
        get { return defaults.bool(forKey: "showDetails") }
        set { defaults.setValue(newValue, forKey: "showDetails")}
    }
    var showViewNames: Bool {
        get { return defaults.bool(forKey: "showViewNames") }
        set { defaults.setValue(newValue, forKey: "showViewNames")}
    }
//    var gameID: Int {
//        get { return defaults.integer(forKey: "gameID") }
//        set { defaults.setValue(newValue, forKey: "gameID") }
//    }
//    var courseID: Int {
//        get { return defaults.integer(forKey: "courseID") }
//        set { defaults.setValue(newValue, forKey: "courseID") }
//    }
//    var teeID: Int {
//        get { return defaults.integer(forKey: "teeID") }
//        set { defaults.setValue(newValue, forKey: "teeID") }
//    }


}
