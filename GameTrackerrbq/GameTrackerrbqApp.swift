//
//  GameTrackerrbqApp.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2022-12-16.
//

import SwiftUI

@main
struct GameTrackerrbqApp: App {
    @StateObject var sm = StateManager()
    @StateObject var boards = Boards()
    @StateObject var games = Games()
    @StateObject var bmm = BoardMessages()
    @StateObject var players = Players()
    var body: some Scene {
        WindowGroup {
//            GameEntryView()
            MenuDriver()
            // got this message from the games maintenance view
            // Probably at least one of the constraints in the following list is o
            // found this solution at
            //     https://www.hackingwithswift.com/forums/100-days-of-swiftui/unable-to-simultaneously-satisfy-constraints-warning-when-adding-a-navigation-title/12883
            //
                .onAppear {
#if DEBUG
                    UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
#endif
                }
                .environmentObject(sm)
                .environmentObject(boards)
                .environmentObject(games)
                .environmentObject(bmm)
                .environmentObject(players)
        }
    }
}
