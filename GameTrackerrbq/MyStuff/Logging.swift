//
//  Logging.swift
//  HandicappUI
//
//  Created by Brian Quick on 2021-03-29.
//

import SwiftUI

func myLog(_ log: String) -> EmptyView {
    if MyDefaults().appLogging {
    print("** \(log)")
    }
    return EmptyView()
}
