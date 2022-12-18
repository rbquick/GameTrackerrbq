//
//  MaintenanceView.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-29.
//

import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        ScrollView {
            VStack {
                PopoverLink(destination:
                                PlayersListView(),
                            title: "Players list",
                            subtitle: "Players"
                ) {
                    Text("Players List")
                        .myButtonViewStyle()
                }.myButtonViewStyle()
//                PopoverLink(destination:
//                                PlayersMaintenanceView(),
//                            title: "Players",
//                            subtitle: "Players"
//                ) {
//                    Text("Players")
//                        .myButtonViewStyle()
//                }.myButtonViewStyle()
                PopoverLink(destination:
                                BoardsListView(),
                            title: "BoardsListView",
                            subtitle: "BoardsListView"
                ) {
                    Text("Boards")
                        .myButtonViewStyle()
                }.myButtonViewStyle()
                PopoverLink(destination:
                                GamesListView(),
                            title: "Games",
                            subtitle: "Games"
                ) {
                    Text("Games")
                        .myButtonViewStyle()
                }.myButtonViewStyle()
                PopoverLink(destination:
                                ColorDefaults(),
                            title: "Colour",
                            subtitle: "Colour"
                ) {
                    Text("Colour")
                        .myButtonViewStyle()
                }.myButtonViewStyle()

            }
        }
    }
}

struct MaintenanceView_Previews: PreviewProvider {
    static var previews: some View {
        MaintenanceView()
    }
}
