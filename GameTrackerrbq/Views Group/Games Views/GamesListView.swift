//
//  GamesListView.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-12-03.
//


import SwiftUI
import CloudKit

struct GamesListView: View {
    @EnvironmentObject var games: Games
    @EnvironmentObject var players: Players
    @EnvironmentObject var boards: Boards
    @State var searchTerm = ""
    @State var myGame = Game(BoardID: 0, Board: "Euchre", DatePlayed: Date(), WinnerID: 1, Player1ID: 1, Score1: 1, Player2ID: 2, Score2: 2, myID: 0)!
    @State private var returnedMessage = ""

    @State var fillGames = [fillGame]()
    @State var sectionDictionary : Dictionary<String , [fillGame]> = [:]

    var body: some View {
        VStack {
            HStack {
                SearchBar(searchTerm: $searchTerm)

            }

            ScrollView {
                ForEach(sectionDictionary.keys.sorted(), id:\.self) { key in
                    if let contacts = sectionDictionary[key]?.filter({ (contact) -> Bool in
                        self.searchTerm.isEmpty ? true :
                        "\(contact)".lowercased().contains(self.searchTerm.lowercased())}), !contacts.isEmpty
                    {
                        Section(header: SectionHeader(key: key).background(Color.red), footer: EmptyView()) {
                            ForEach(contacts){ value in
                                HStack(alignment: .center) {
                                    SectionLine(record: value)
                                }
                            }.modifier(BackgroundGradientViewModifier())
                        }
                    }
                }
            }

        }
        .onAppear() {
            buildfillGames()
//            .refreshable {
            // This is done in the menudriver at startup.  will be changed to not get them all sometime in the future
//                games.fetchAll() { rtnMessage in
//                    returnedMessage = rtnMessage
//                    games.sectionDictionary = [:]
//                    games.sectionDictionary = games.getSectionedDictionary()
//                }
        }
    }
    func buildfillGames() {
        for game in games.games {
            let fillRec = fillGame(rid: game.id, rBoard: game.Board, rDatePlayed: game.DatePlayed, rWinnerID: game.WinnerID, rPlayer1ID: game.Player1ID, rScore1: game.Score1, rPlayer2ID: game.Player2ID, rScore2: game.Score2, rmyID: game.myID, rBoardStr: game.Board, rWinnerStr: players.getName(myID: game.WinnerID), rPlayer1Str: players.getName(myID: game.Player1ID), rPlayer2Str: players.getName(myID: game.Player2ID))
            fillGames.append(fillRec)
        }
        print("fillGames.count = \(fillGames.count)")
        sectionDictionary = [:]
        sectionDictionary = getSectionedDictionary()
    }
    func getSectionedDictionary() -> Dictionary <String , [fillGame]> {
        let sectionDictionary: Dictionary<String, [fillGame]> = {
            return Dictionary(grouping: fillGames, by: {
                let name = $0.WinnerStr
                let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                let firstChar = String(normalizedName.first!).uppercased()
                return firstChar
            })
        }()
        return sectionDictionary
    }

}
//struct GamesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        GamesListView()
//            .environmentObject(Games())
//            .environmentObject(Players())
//            .environmentObject(Boards())
//    }
//}
extension GamesListView {

    struct SectionLine: View {
        var record: fillGame

        var body: some View {

            AdaptiveView {
                HStack {
                    Text("\(myDateFormatter(inDate: record.DatePlayed, outFormat: "yyyy-MM-dd")) ... \(record.Board)")
                    Text("\(record.Player1Str) - \(record.Player2Str)")
                }
                HStack {
                    Text("Winner is \(Text("\(record.WinnerStr)").foregroundColor(Color.red)) \(record.Score1, specifier: "%.0f")-\(record.Score2, specifier: "%.0f")")
                }
            }
            .myBackgroundStyle()
        }
    }
}
struct fillGame: Identifiable {
    var id: CKRecord.ID
    var Board: String
    var DatePlayed: Date
    var WinnerID: Int64
    var Player1ID: Int64
    var Score1: Double
    var Player2ID: Int64
    var Score2: Double
    var myID: Int64
    var BoardStr: String
    var WinnerStr: String
    var Player1Str: String
    var Player2Str: String

    init(rid: CKRecord.ID, rBoard: String, rDatePlayed: Date, rWinnerID: Int64, rPlayer1ID: Int64, rScore1: Double, rPlayer2ID: Int64, rScore2: Double, rmyID: Int64, rBoardStr: String, rWinnerStr: String, rPlayer1Str: String, rPlayer2Str: String) {
        id = rid
        Board = rBoard
        DatePlayed = rDatePlayed
        WinnerID = rWinnerID
        Player1ID = rPlayer1ID
        Score1 = rScore1
        Player2ID = rPlayer2ID
        Score2 = rScore2
        myID = rmyID
        BoardStr = rBoardStr
        WinnerStr = rWinnerStr
        Player1Str = rPlayer1Str
        Player2Str = rPlayer2Str
    }
}


