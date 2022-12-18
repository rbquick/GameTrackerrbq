//
//  GamesMaintenanceView.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-29.
//

import SwiftUI

struct GamesMaintenanceView: View {
    @State var myGame: Game
    var body: some View {
        Text("\(myGame.Board) Played on \(myGame.DatePlayed)")
    }
}

struct GamesMaintenanceView_Previews: PreviewProvider {
    static var previews: some View {
        GamesMaintenanceView(myGame: Game(BoardID: 1, Board: "Euchre", DatePlayed: Date(), WinnerID: 1, Player1ID: 1, Score1: 5, Player2ID: 2, Score2: 10, myID: 0)!)
    }
}
