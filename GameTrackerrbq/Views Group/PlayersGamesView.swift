//
//  PlayersGamesView.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-12-07.
//

import SwiftUI
struct PlayerGame: Identifiable {
    var id: Int64
    var Board: String
    var Player: String
    var GamesPlayed: Int
    var GamesWon: Int
    var GamesLost: Int
}

struct PlayersGamesView: View {

    @State private var playerGames = [PlayerGame]()
    @State var sectionDictionary : Dictionary<String , [PlayerGame]> = [:]
    @State private var header: Int64 = 0
    @State private var searchTerm: String = ""
    @State private var PlayerGameID: Int64 = 0
    @EnvironmentObject var games: Games
    @EnvironmentObject var players: Players
    @EnvironmentObject var boards: Boards
    var body: some View {
        VStack {
            HStack {
                SearchBar(searchTerm: $searchTerm)

            }
            ScrollView {
                ForEach(sectionDictionary.keys.sorted(), id:\.self) { key in
                    if let contacts = sectionDictionary[key]!.filter({ (contact) -> Bool in
                        self.searchTerm.isEmpty ?
                        true :
                        "\(contact)".lowercased().contains(self.searchTerm.lowercased())}), !contacts.isEmpty
                    {
                        Section(header: SectionHeader(key: key).background(Color.red), footer: EmptyView()) {
                            ForEach(contacts){ value in
                                SectionLine(record: value)
                            }
                        }
                    }
                }
                .onAppear() {
                    BuildResults()
                }
            }
        }
    }
}
    struct PlayersGamesView_Previews: PreviewProvider {
        static var previews: some View {
            PlayersGamesView()
                .environmentObject(Boards())
                .environmentObject(Games())
                .environmentObject(Players())
        }
    }

    extension PlayersGamesView {
        func BuildOne(board: String, player: String, winner: String) {
            var pgIdx = playerGames.firstIndex(where: { ($0.Board == board) && ($0.Player == player) })
            if pgIdx == nil {
                playerGames.append(PlayerGame(id: PlayerGameID, Board: board, Player: player, GamesPlayed: 0, GamesWon: 0, GamesLost: 0))
                pgIdx = playerGames.count - 1
                PlayerGameID += 1
            }
            playerGames[pgIdx ?? 0].GamesPlayed += 1
            if player == winner {
                playerGames[pgIdx ?? 0].GamesWon += 1

            } else {
                playerGames[pgIdx ?? 0].GamesLost += 1
            }
        }
        func BuildResults() {
            for game in games.games {

                let board = boards.getName(myID: game.BoardID)
                let winner = players.getName(myID: game.WinnerID)
                
                var player = players.getName(myID: game.Player1ID)
                BuildOne(board: board, player: player, winner: winner)

                player = players.getName(myID: game.Player2ID)
                BuildOne(board: board, player: player, winner: winner)

            }
            sectionDictionary = [:]
            sectionDictionary = getSectionedDictionary()
        }


        func getSectionedDictionary() -> Dictionary <String , [PlayerGame]> {
            let sectionDictionary: Dictionary<String, [PlayerGame]> = {
                return Dictionary(grouping: playerGames, by: {
                    let name = $0.Board
                    let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                    let firstChar = String(normalizedName).uppercased()
                    return firstChar
                })
            }()
            return sectionDictionary
        }

        struct SectionLine: View {
            var record: PlayerGame

            var body: some View {

                HStack(alignment: .center) {
                    Text("\(record.Player) Played:\(record.GamesPlayed) Won:\(record.GamesWon) Lost:\(record.GamesLost)")

                }.modifier(BackgroundGradientViewModifier())
            }
        }
    }

