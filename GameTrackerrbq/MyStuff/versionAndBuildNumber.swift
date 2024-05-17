//
//  versionAndBuildNumber.swift
//  HandicappMulti
//
//  Created by Brian Quick on 2024-03-14.
//
import SwiftUI
func versionAndBuildNumber() -> String {
    let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    if let versionNumber = versionNumber, let buildNumber = buildNumber {
        return "\(versionNumber) (\(buildNumber))"
    } else if let versionNumber = versionNumber {
        return versionNumber
    } else if let buildNumber = buildNumber {
        return buildNumber
    } else {
        return ""
    }
}
