import SwiftUI
import AlertKit

struct GameLineView: View {
    var game: Game
    @EnvironmentObject var players: Players
    var body: some View {

        AdaptiveView {
            HStack {
                Text("\(myDateFormatter(inDate: game.DatePlayed, outFormat: "yyyy-MM-dd")) ... \(game.Board)")
                Text("\(players.getName(myID: game.Player1ID)) - \(players.getName(myID: game.Player2ID))")
            }
            HStack {
                Text("Winner is \(Text("\(players.getName(myID: game.WinnerID))").foregroundColor(Color.red))   \(game.Score1, specifier: "%.0f")-\(game.Score2, specifier: "%.0f")")
            }
        }
        .myBackgroundStyle()
        //.listRowBackground(myListRowBackgroundView())
    }
}