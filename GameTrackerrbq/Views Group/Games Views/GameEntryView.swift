//
//  GameEntry.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-24.
//

import SwiftUI
import AlertKit

struct GameEntryView: View {
    @State private var board: String = "1"
    @State private var boardID: Int64 = 0
    @State private var winner: String = "1"
    @State private var winnerID: Int64 = 0
    @State private var datePlayed: Date = Date()
    @State private var player1: String = "38"
    @State private var player1ID: Int64 = 0
    @State private var score1: Double = 0
    @State private var player2: String = "1"
    @State private var player2ID: Int64 = 0
    @State private var score2: Double = 0
    @State private var rubbersPlayer1Today = 0
    @State private var rubbersPlayer2Today = 0
    @State private var rubbersPlayer1Total = 0
    @State private var rubbersPlayer2Total = 0

    let pickerWidth = 260

    @State var returnedMessage = ""

    // These two lisvarts will not contain one anothers selected players
    // ex: select a player1, it will not show in the playr2 list
    var listPlayer1: [Player] {
        return players.players.filter {
            String($0.myID) != player2
        }
    }

    var listPlayer2: [Player] {
        return players.players.filter {
            String($0.myID) != player1
        }
    }
    @State private var pickedGameWinner: String = ""
    @State private var myBoard: Board = Board(Name: "Euchre", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 10, myID: 1)!
    var listGames: [Game] {
        if player1 == "0" || player2 == "0" {
            return games.games.filter {
                $0.BoardID == boardID
                && (( $0.Player1ID == player1ID || $0.Player1ID == player2ID )
                    || ( $0.Player2ID == player1ID || $0.Player2ID == player2ID) )
            }
        } else {
            return games.games.filter {
                $0.BoardID == boardID
                && ( $0.Player1ID == player1ID || $0.Player1ID == player2ID )
                && ( $0.Player2ID == player1ID || $0.Player2ID == player2ID )
            }
        }
    }
    var lastDate: Date {
        if listGames.count > 0 {
            return listGames[0].DatePlayed
        } else {
            return Date()
        }
    }
    var todayGames: [Game] {
        return listGames.filter { game in
            Calendar.current.isDate( game.DatePlayed, equalTo: lastDate, toGranularity: .day)
        }
    }
    var player1TodayGamesWon: [Game] {
        return todayGames.filter { game in
            player1ID == game.WinnerID
        }
    }
    var player2TodayGamesWon: [Game] {
        return todayGames.filter { game in
            player2ID == game.WinnerID
        }
    }
    var player1TotalGamesWon: [Game] {
        return listGames.filter { game in
            player1ID == game.WinnerID
        }
    }
    var player2TotalGamesWon: [Game] {
        return listGames.filter { game in
            player2ID == game.WinnerID
        }
    }
    @State private var myGame: Game = Game(BoardID: 0, Board: "", DatePlayed: Date(), WinnerID: 0, Player1ID: 0, Score1: 0, Player2ID: 0, Score2: 0, myID: 0)!
    var myPlayers: [Player] {
        return players.players.filter {
            String($0.myID) == player1 || String($0.myID) == player2
        }
    }
    @State private var GameEntryEditingIdx: Int = 0
    @State private var GameEntryShowing: Bool = false
    @State private var GameEntryNewGame: Bool = false
    private var GameEntryCanShow: Bool {
        if player1.isEmpty || player2.isEmpty {
            return false
        } else {
            return true
        }
    }

    @State private var orientation = UIDeviceOrientation.unknown

    private var rotationHeight: CFloat {
        switch orientation {
        case .portrait:
            return 52
        case .landscapeLeft:
            return 20
        case .landscapeRight:
            return 20
        default:
            return 20
        }
    }
    @EnvironmentObject var sm: StateManager
    @EnvironmentObject var boards: Boards
    @EnvironmentObject var games: Games
    @EnvironmentObject var players: Players

    @StateObject var alertManager = AlertManager()

/*
    I have messed with this for over two weeks now trying to get the ipad to display the three vstacks
        and the iphone with a scroll view and the game selection centered.
    I could not condition the views
    DO NOT try and move the vstack to their view, I get a compile error exit code zero
    This is not a pretty solution and I hope I can get back to this someday.
    for now, this is the way it works
 */

    var body: some View {
        VStack {
            if !GameEntryShowing {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    VStack {
                        GeometryReader { geo in
                            HStack {
                                VStack {
                                    Text("Todays Statistics")
                                        .fontWeight(.bold)
                                    Text("Games Played: \(todayGames.count)")
                                        .fontWeight(.bold)
                                    Text("\(players.getName(myID: Int64(player1) ?? 802)) won: \(player1TodayGamesWon.count)")
                                    Text("\(players.getName(myID: Int64(player2) ?? 803)) won: \(player2TodayGamesWon.count)")
                                    Text("Rubbers won")
                                        .fontWeight(.bold)
                                    Text("\(players.getName(myID: Int64(player1) ?? 802)) won: \(rubbersPlayer1Today)")
                                        .onAppear() {
                                            CountRubbers()
                                        }

                                    Text("\(players.getName(myID: Int64(player2) ?? 803)) won: \(rubbersPlayer2Today)")
                                }.frame(width: geo.size.width / 3)
                                VStack {
                                    GameSelection
                                    PlayerSelection
                                }.frame(width: geo.size.width / 3)
                                VStack {
                                    Text("Total Statistics")
                                        .fontWeight(.bold)
                                    Text("Games Played: \(listGames.count)")
                                        .fontWeight(.bold)
                                    Text("\(players.getName(myID: Int64(player1) ?? 804)) won: \(player1TotalGamesWon.count)")
                                    Text("\(players.getName(myID: Int64(player2) ?? 805)) won: \(player2TotalGamesWon.count)")
                                    Text("Rubbers won")
                                        .fontWeight(.bold)
                                    Text("\(players.getName(myID: Int64(player1) ?? 802)) won: \(rubbersPlayer1Total)")
                                    Text("\(players.getName(myID: Int64(player2) ?? 803)) won: \(rubbersPlayer2Total)")
                                }.frame(width: geo.size.width / 3)
                            }
                        }
                    }
                } else {
                    VStack {
                        ScrollViewReader { value in
                            ScrollView(.horizontal) {
                                HStack {
                                    VStack {
                                        Text("Todays Statistics")
                                            .fontWeight(.bold)
                                        Text("Games Played: \(todayGames.count)")
                                            .fontWeight(.bold)
                                        Text("\(players.getName(myID: Int64(player1) ?? 806)) won: \(player1TodayGamesWon.count)")
                                        Text("\(players.getName(myID: Int64(player2) ?? 807)) won: \(player2TodayGamesWon.count)")
                                        Text("Rubbers won")
                                            .fontWeight(.bold)
                                        Text("\(players.getName(myID: Int64(player1) ?? 802)) won: \(rubbersPlayer1Today)")
                                        Text("\(players.getName(myID: Int64(player2) ?? 803)) won: \(rubbersPlayer2Today)")
                                    }.id(0)
                                    VStack {
                                        GameSelection
                                        PlayerSelection
                                    }.id(1)
                                    VStack {
                                        Text("\(players.getName(myID: Int64(player1) ?? 804)) won: \(player1TotalGamesWon.count)")
                                        Text("\(players.getName(myID: Int64(player2) ?? 805)) won: \(player2TotalGamesWon.count)")
                                        Text("Rubbers won")
                                            .fontWeight(.bold)

                                        Text("\(players.getName(myID: Int64(player1) ?? 802)) won: \(rubbersPlayer1Total)")
                                            .onAppear() {
                                                CountRubbers()
                                            }
                                        Text("\(players.getName(myID: Int64(player2) ?? 803)) won: \(rubbersPlayer2Total)")
                                    }.id(2)
                                }
                            }
                            .onAppear() {
                                value.scrollTo(1, anchor: .center)
                            }
                        }
                    }
                }
            }

            GameEntrySelect
            Text("isChanged:\(games.isChanged)")

            if !GameEntryShowing {
                ListGames
            }


        }
        .onAppear() {

            players.BlankAdd()
            if games.games.count == 0 {
                games.fetchAll() { rtnMessage in

                    if games.games.count > 0 {
                        setInitialGame()
                    }
                }
            } else {
                setInitialGame()
            }
        }
        .onDisappear() {
            players.BlankRemove()
        }

    }
}
struct GameEntry_Previews: PreviewProvider {
    static var previews: some View {
        GameEntryView()
            .environmentObject(Boards())
            .environmentObject(Games())
            .environmentObject(Players())
    }
}

extension GameEntryView {
    func setInitialGame() {
        player1 = String(games.games[0].Player1ID)
        player2 = String(games.games[0].Player2ID)
        winner = player1
        board = String(games.games[0].BoardID)
        CountRubbers()
    }
    func CountRubbers() {
        rubbersPlayer1Today = CountOneRubber(myGames: todayGames, playerID: Int64(player1) ?? 0)
        rubbersPlayer2Today = CountOneRubber(myGames: todayGames, playerID: Int64(player2) ?? 0)
        rubbersPlayer1Total = CountOneRubber(myGames: listGames, playerID: Int64(player1) ?? 0)
        rubbersPlayer2Total = CountOneRubber(myGames: listGames, playerID: Int64(player2) ?? 0)
    }
    func CountOneRubber(myGames: [Game], playerID: Int64) -> Int {
        if myGames.count == 0 { return 0 }
        var playerwins = 0
        var otherwins = 0
        var numberOfRubbers = 0
        var prevDate = myGames[myGames.count - 1].DatePlayed
        for game in myGames.reversed() {
            if !Calendar.current.isDate(prevDate, inSameDayAs: game.DatePlayed) {
                playerwins = 0
                otherwins = 0
                prevDate = game.DatePlayed
            }
                
                if playerID == game.WinnerID {
                    playerwins += 1
                } else {
                    otherwins += 1
                }
                if playerwins == 2 {
                    numberOfRubbers += 1
                    playerwins = 0
                    otherwins = 0
                }
                if otherwins == 2 {
                    playerwins = 0
                    otherwins = 0
                }
            

        }

        return numberOfRubbers
    }
    private var GameSelection: some View {
        VStack {
            Text("Select the Game board = \(board)")
            Picker("", selection: $board) {
                ForEach(boards.boards) { board in
                    Text("\(board.Name)").tag("\(board.myID)")
                }
//                .onAppear() {
//                    if board == "9999" {
//                        board = boards.boards.count > 0 ? String(boards.boards[0].myID) : "998"
//                    }
//                }
            }
            .myButtonViewStyle(width: CGFloat(pickerWidth))
            .onChange(of: board) { _ in
                boardID = Int64(board) ?? 910
                myBoard =  boards.boards.first(where: {$0.myID == boardID}) ?? Board(Name: "Unknown", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 0, myID: 0)!
            }
        }
    }
    private var PlayerSelection: some View {
        VStack{
            Text("Select Players")
            AdaptiveView {
                VStack {
                    Text("player1 = \(player1)")
                    Picker("", selection: $player1) {
                        ForEach(listPlayer1) { player in
                            Text("\(player.Name)").tag("\(String(player.myID))")
                        }
//                        .onAppear() {
//                            if player1 == "9999" {      // allow selection of a empty player to see all the games for the other player
//                                player1 = games.games.count > 0 ? String(games.games[0].Player1ID) : "998"
//                            }
//                        }
                    }
                    .myButtonViewStyle(width: CGFloat(pickerWidth))
                    .onChange(of: player1) { _ in player1ID = Int64(player1) ?? 800 }
                }
                VStack {
                    Text("player2 = \(player2)")
                    Picker("", selection: $player2) {
                        ForEach(listPlayer2) { player in
                            Text("\(player.Name)").tag("\(String(player.myID))")
                        }
//                        .onAppear() {
//                            if player2 == "9999" {
//                                player2 = games.games.count > 0 ? String(games.games[0].Player2ID) : "999"
//                            }
//                        }
                    }
                    .myButtonViewStyle(width: CGFloat(pickerWidth))
                    .onChange(of: player2) { _ in player2ID = Int64(player2) ?? 801 }
                }
            }
        }
    }
    private var GameEntrySelect: some View {

            VStack{
            HStack {
                if !GameEntryShowing {
                    Text("New Game")
                    if GameEntryCanShow {
                        myButton(action: {
                            winner = player1
                            changeSelectionsToInt64()
                            restore(game: Game(BoardID: boardID, Board: board, DatePlayed: Date(), WinnerID: winnerID, Player1ID: player1ID, Score1: 0, Player2ID: player2ID, Score2: 0, myID: 0)!)
                            returnedMessage = "Entering New Game"
                            GameEntryNewGame = true
                            GameEntryShowing.toggle()
                        }) {
                            Text("Start")
                        }
                    }
                }
                if GameEntryShowing {
                    Text("Game options")
                    if !GameEntryNewGame {
                        myButton(action: {
                            delete()
                            CountRubbers()
                            GameEntryShowing.toggle()
                        }, content: {
                            Text("Delete")
                        })
                    }
                    myButton(action: {
                        CountRubbers()
                        GameEntryNewGame = false
                        GameEntryShowing.toggle()
                    }) {
                        Text("Cancel")
                    }
                    myButton(action: {
                        if GameEntryNewGame {
                            add()
                            CountRubbers()
                        } else {
                            change()
                        }
                        GameEntryNewGame = false
                        GameEntryShowing.toggle()
                    }) {
                        Text("Finish")
                    }
                }
            }.uses(alertManager)
            if GameEntryShowing {
                GameEntryView
            }
        }
    }
    func changeSelectionsToInt64() {
        player1ID = Int64(player1) ?? 901
        player2ID = Int64(player2) ?? 902
        winnerID = Int64(winner) ?? 901
    }
    func changeInt64ToSelections() {
        player1 = String(player1ID)
        player2 = String(player2ID)
        winner = String(winnerID)
    }
    func add() {
        changeSelectionsToInt64()
        MyDefaults().Player1ID = player1ID
        MyDefaults().Player2ID = player2ID
        MyDefaults().Board = board
        games.add(BoardID: boardID, Board: boards.getName(myID: boardID), DatePlayed: datePlayed, WinnerID: winnerID, Player1ID: player1ID, Score1: score1, Player2ID: player2ID, Score2: score2) { rtnMessage in
            returnedMessage = rtnMessage
        }
    }
    func change() {
        changeSelectionsToInt64()
        guard let changeRec = myGame.update(BoardID: boardID, Board: boards.getName(myID: boardID), DatePlayed: datePlayed, WinnerID: winnerID, Player1ID: player1ID, Score1: score1, Player2ID: player2ID, Score2: score2) else { return }
        myGame = changeRec
        games.change(game: changeRec) { rtnMessage in
            returnedMessage = rtnMessage
        }
    }
    func delete() {
        alertManager.show(primarySecondary: .success(title: "Are you sure you want to delete this Game?",
                                                     message: "There is no recovery for this action",
                                                     primaryButton: Alert.Button.destructive(Text("Delete"),
                                                                                             action: {
            games.delete(game: myGame) { rtnMessage in
                returnedMessage = rtnMessage
            }
            }), secondaryButton: .cancel()))
        }
    private var GameEntryView: some View {
        VStack {
            Divider()
            Text("Pick a winner")
            Picker("Winner", selection: $winner) {
                ForEach(myPlayers) { player in
                    Text("\(player.myID) \(player.Name)").tag("\(player.myID)")
                }
            }
            .onAppear {
                if GameEntryNewGame {
                    winner = player1
                    score1 = myBoard.maxScore
                }
            }
            .onChange(of: winner, perform: { _ in
                if GameEntryNewGame {
                    if player1 == winner {
                        score1 = myBoard.maxScore
                    } else {
                        score2 = myBoard.maxScore
                    }
                }
            })
            Divider()
            DatePicker("Date Played", selection: $datePlayed)
            if myBoard.maxScore > 0 {
                AdaptiveView {
                    VStack {
                        Text("\(players.getPlayerName(myID: player1)) Score:\(score1, specifier: "%.0f")")
                        Slider(value: $score1, in: myBoard.minScore ... myBoard.maxScore, step: 1.0)
                    }
                    VStack {
                        Text("\(players.getPlayerName(myID: player2)) Score:\(score2, specifier: "%.0f")")
                        Slider(value: $score2, in: myBoard.minScore ... myBoard.maxScore, step: 1.0)
                    }
                }
            }
        }
    }
    private var ListGames: some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(listGames.indices, id:\.self) { idx in
                        myButton(action: {
                            myGame = listGames[idx]
                            restore(game: listGames[idx])
                            returnedMessage = "Changing a game"
                            GameEntryEditingIdx = idx
                            GameEntryShowing.toggle()
                        }, content: { GameLineView(game: listGames[idx])}, width: geo.size.width, height: 51)
                        
                        
                    }
                }
            }
            .myBackgroundStyle()
            // .scrollContentBackground(.hidden)  // available in 16.0 only
        }
    }
    func restore(game: Game) {
        board = game.Board
        score1 = game.Score1
        score2 = game.Score2
        datePlayed = game.DatePlayed
        winner = String(game.WinnerID)
        player1 = String(game.Player1ID)
        player2 = String(game.Player2ID)
        // changeInt64ToSelections()
    }
}

struct GameLineView: View {
    var game: Game
    @EnvironmentObject var players: Players
    var body: some View {

        AdaptiveView {
            HStack {
                Text("\(myDateFormatter(inDate: game.DatePlayed, outFormat: "yyyy-MM-dd")) ... \(game.Board)")
                Text("\(players.getName(myID: game.Player1ID)) - \(players.getName(myID: game.Player2ID))")
            }
            VStack {
                Text("Winner is \(Text("\(players.getName(myID: game.WinnerID))").foregroundColor(Color.red)) \(game.Score1, specifier: "%.0f")-\(game.Score2, specifier: "%.0f")")
            }
        }
        .myBackgroundStyle()
        //.listRowBackground(myListRowBackgroundView())
    }
}
struct myListRowBackgroundView: View {
    var body: some View {
        Rectangle()
        //.cornerRadius(50)
            .opacity(0)
            .background(LinearGradient(gradient: Gradient(colors: [Color(MyDefaults().gradientDefaults[1]), Color(MyDefaults().gradientDefaults[0])]), startPoint: .top, endPoint: .bottom))
    }
}
