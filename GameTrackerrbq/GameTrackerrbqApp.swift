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
                .environmentObject(sm)
                .environmentObject(boards)
                .environmentObject(games)
                .environmentObject(bmm)
                .environmentObject(players)
        }
    }
}
