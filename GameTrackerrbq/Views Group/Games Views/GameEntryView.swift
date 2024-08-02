//
//  GameEntry.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-24.
//

import SwiftUI
import AlertKit

struct GameEntryView: View {

    @State private var winner: String = "1"
    @State private var winnerID: Int64 = 0
    @State private var datePlayed: Date = Date()
    @State private var score1: Double = 0
    @State private var score2: Double = 0
    @State private var msgtext: String = ""
    @State private var selectedBoardName: String = ""
    
    @State private var angle: Double = 360  // Initial rotation angle for one clockwise revolution
    @State private var scale: CGFloat = 1.0
    
    let isTracing: Bool = true
    let pickerWidth = 260
    @State private var opacity = 1.0
    @State var showBanana = false
    @State var returnedMessage = ""

    // These two lisvarts will not contain one anothers selected players
    // ex: select a player1, it will not show in the playr2 list
    var listPlayer1: [Player] {
        return players.players.filter {
            $0.myID != games.player2ID
        }
    }

    var listPlayer2: [Player] {
        return players.players.filter {
            $0.myID != games.player1ID
        }
    }
    @State private var pickedGameWinner: String = ""
    @State private var myBoard: Board = Board(Name: "Euchre", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 10, myID: 1)!


    @State private var myGame: Game = Game(BoardID: 0, Board: "", DatePlayed: Date(), WinnerID: 0, Player1ID: 0, Score1: 0, Player2ID: 0, Score2: 0, myID: 0)!
    var myPlayers: [Player] {
        return players.players.filter {
            $0.myID == games.player1ID || $0.myID == games.player2ID
        }
    }
    @State private var GameEntryEditingIdx: Int = 0
    @State private var GameEntryShowing: Bool = false
    @State private var GameEntryNewGame: Bool = false
   
    private var GameEntryCanShow: Bool {
        if games.player1.isEmpty || games.player2.isEmpty {
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
    @EnvironmentObject var bmm: BoardMessages
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
        VStack(alignment: .center) {
            if !GameEntryShowing {
                VStack(alignment: .center) {
                        ScrollViewReader { value in
                            ScrollView(.horizontal) {
                                HStack {
                                    Spacer(minLength: 500)
                                    HStack {
                                        VStack {
                                            Text("Todays Statistics")
                                                .fontWeight(.bold)
                                            Text("Games Played: \(games.todayGames.count)")
                                                .fontWeight(.bold)
                                            Text("\(players.getName(myID: games.player1ID)) won: \(games.player1TodayGamesWon.count)")
                                            Text("\(players.getName(myID: games.player2ID)) won: \(games.player2TodayGamesWon.count)")
                                            Text("Rubbers won")
                                                .fontWeight(.bold)
                                            Text("\(players.getName(myID: games.player1ID)) won: \(games.rubbersPlayer1Today)")
                                            Text("\(players.getName(myID: games.player2ID)) won: \(games.rubbersPlayer2Today)")
                                        }.id(0)
                                        VStack {
                                            GameSelection
                                            PlayerSelection
                                        }.id(1)
                                        VStack {
                                            Text("Overall Statistics")
                                                .fontWeight(.bold)
                                            Text("Games Played: \(games.GlistGames.count)")
                                                .fontWeight(.bold)
                                            Text("\(players.getName(myID: games.player1ID)) won: \(games.player1TotalGamesWon)")
                                            Text("\(players.getName(myID: games.player2ID)) won: \(games.player2TotalGamesWon)")
                                            Text("Rubbers won")
                                                .fontWeight(.bold)

                                            Text("\(players.getName(myID: games.player1ID)) won: \(games.rubbersPlayer1Total)")
                                            Text("\(players.getName(myID: games.player2ID)) won: \(games.rubbersPlayer2Total)")
                                            myButton(action: {
                                                sm.isLoading = true
                                                fetchSelectedGames() { completion in
                                                    sm.isLoading = false
                                                }
                                            }) {
                                                Text("Get All")
                                            }
                                        }.id(2)
                                    }
                                    Spacer(minLength: 500)
                                }
                            }
                            .onAppear() {
                                value.scrollTo(1, anchor: .center)
                            }
                        }
                    }
            }

            GameEntrySelect
//            Text("games.count \(games.games.count) games.GlistGames.count \(games.GlistGames.count)")
// TODAY
            if !GameEntryShowing {
                ListGames
            }


        }
        .onAppear() {

//            players.BlankAdd()

            setInitialGame()

        }
        .onDisappear() {
            players.BlankRemove()
        }

    }
}
struct GameEntry_Previews: PreviewProvider {
    static var previews: some View {
        GameEntryView()
            .environmentObject(StateManager())
            .environmentObject(Boards())
            .environmentObject(BoardMessages())
            .environmentObject(Games())
            .environmentObject(Players())
    }
}

extension GameEntryView {
    func setInitialGame() {
                    if games.games.count > 0 {
                        games.player1 = String(games.games[0].Player1ID)
                        games.player2 = String(games.games[0].Player2ID)
                        winner = games.player1
                        games.board = String(games.games[0].BoardID)
                        myBoard =  boards.boards.first(where: {$0.myID == games.boardID}) ?? Board(Name: "Unknown", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 0, myID: 0)!
                        selectedBoardName = myBoard.Name
                    }

        print("\(Date()):setInitialGame DONE")
        //        CountRubbers()
    }
    func fetchSelectedGames(_ completion: @escaping (String) -> ()) {
        games.fetchSelective(board: MyDefaults().BoardID, player1ID: MyDefaults().Player1ID, player2ID: MyDefaults().Player2ID) {
            rtnMessage in
//            returnedMessage = rtnMessage
//            games.sectionDictionary = [:]
//            games.sectionDictionary = games.getSectionedDictionary()
//            if games.games.count > 0 {
//                games.player1 = String(games.games[0].Player1ID)
//                games.player2 = String(games.games[0].Player2ID)
//                winner = games.player1
//                games.board = String(games.games[0].BoardID)
//                myBoard =  boards.boards.first(where: {$0.myID == games.boardID}) ?? Board(Name: "Unknown", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 0, myID: 0)!
//            }
            completion("FetchSectedGames done")
        }
    }

    private var GameSelection: some View {
        VStack {
            Text("Select the Game board = \(games.board)")
            Picker("", selection: $games.board) {
                ForEach(boards.boards) { board in
                    Text("\(board.Name)").tag("\(board.myID)")
                }
            }
            .myButtonViewStyle(width: CGFloat(pickerWidth))
            .onChange(of: games.board) { selection in
                //rbq boardID = Int64(board) ?? 910
                myBoard =  boards.boards.first(where: {$0.myID == games.boardID}) ?? Board(Name: "Unknown", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 0, myID: 0)!
                MyDefaults().BoardID = myBoard.myID
                selectedBoardName = myBoard.Name
                setPlayersForBoard(board: myBoard)
//                fillSelectedGames()
            }
        }
    }

    func tracing(function: String) {
        if isTracing {
            print("\(Date()):Players \(function) ")
            Logger.log("Players \(function)")
        }
    }
    func fillSelectedGames() {
        games.fetchAllRestricted = false
        // TODAY
        sm.isLoading = true
        games.fetchSelective(board: games.boardID, player1ID: games.player1ID, player2ID: games.player2ID) { rtnMessage in
            returnedMessage = rtnMessage
            games.sectionDictionary = [:]
            games.sectionDictionary = games.getSectionedDictionary()
            tracing(function: "\(Date()): GameEntryView FillSelectedGames SectionDictionary")
            sm.isLoading = false
        }
    }
    func setPlayersForBoard(board: Board) {
        // I do not want to do this anymore since the games now only contain the initially selected board and players
        return
        let thisGame = games.findFirstForBoard(board: board)
        games.player1 = String(thisGame.Player1ID)
        games.player2 = String(thisGame.Player2ID)
    }
    private var PlayerSelection: some View {
        VStack{
            Text("Select Players")
            AdaptiveView {
                VStack {
                    Text("player1 = \(games.player1)")
                    Picker("", selection: $games.player1) {
                        ForEach(listPlayer1) { player in
                            Text("\(player.Name)").tag("\(String(player.myID))")
                        }
                    }
                    .myButtonViewStyle(width: CGFloat(pickerWidth))
                    .onChange(of: games.player1) { selection in
                        MyDefaults().Player1ID = players.getmyIDFromStringID(myID: selection)
//                        fillSelectedGames()
                    }
                }

                VStack {
                    Text("player2 = \(games.player2)")
                    Picker("", selection: $games.player2) {
                        ForEach(listPlayer2) { player in
                            Text("\(player.Name)").tag("\(String(player.myID))")
                        }
                    }
                    .myButtonViewStyle(width: CGFloat(pickerWidth))
                    .onChange(of: games.player2) { selection in
                        MyDefaults().Player2ID = players.getmyIDFromStringID(myID: selection)
//                        fillSelectedGames()
                    }
                }
            }
            
        }
    }
    private var GameEntrySelect: some View {

            VStack{
                if GameEntryShowing {
                    Spacer()
                    Text("\(selectedBoardName)")
                    Spacer()
                }
            HStack {
                if !GameEntryShowing {
                    Text("New Game")
                    if GameEntryCanShow {
                        myButton(action: {
                            winner = games.player1
                            restore(game: Game(BoardID: games.boardID, Board: boards.getName(myID: games.boardID), DatePlayed: Date(), WinnerID: winnerID, Player1ID: games.player1ID, Score1: 0, Player2ID: games.player2ID, Score2: 0, myID: 0)!)
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
                            GameEntryShowing.toggle()
                        }, content: {
                            Text("Delete")
                        })
                    }
                    myButton(action: {
                        GameEntryNewGame = false
                        GameEntryShowing.toggle()
                    }) {
                        Text("Cancel")
                    }
                    myButton(action: {
                        sm.isLoading = true
                        if GameEntryNewGame {
                            add()
                        } else {
                            change()
                        }
                        games.boardmessagemsgtext = bmm.getmsgtext(boardname: selectedBoardName, score: score1 < score2 ? score1 : score2)
                        GameEntryNewGame = false
                        GameEntryShowing.toggle()

                    }) {
                        Text("Finish")
                    }
                }
            }.uses(alertManager)
            if GameEntryShowing {
                GameEntryViewEntering
                Spacer()
            }
        }
    }
    func add() {
        MyDefaults().Player1ID = games.player1ID
        MyDefaults().Player2ID = games.player2ID
        MyDefaults().Board = games.board
        games.add(BoardID: games.boardID, Board: boards.getName(myID: games.boardID), DatePlayed: datePlayed, WinnerID: winnerID, Player1ID: games.player1ID, Score1: score1, Player2ID: games.player2ID, Score2: score2) { rtnMessage in
            returnedMessage = rtnMessage
            sm.isLoading = false
        }
    }
    func change() {
        guard let changeRec = myGame.update(BoardID: games.boardID, Board: boards.getName(myID: games.boardID), DatePlayed: datePlayed, WinnerID: winnerID, Player1ID: games.player1ID, Score1: score1, Player2ID: games.player2ID, Score2: score2) else { return }
        myGame = changeRec
        games.change(game: changeRec) { rtnMessage in
            returnedMessage = rtnMessage
            sm.isLoading = false
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
    private var GameEntryViewEntering: some View {
        VStack {
            Divider()
            Text("Pick a winner")
        // the following comments are kept for the development of the TextSpinner view
//            Button {
//                games.boardmessagemsgtext = bmm.getmsgtext(boardname: selectedBoardName, score: score1 < score2 ? score1 : score2)
//            } label: {
//                Text("check results")
//            }
//            TextSpinner(msgText: games.boardmessagemsgtext)
//            Text("\(games.boardmessagemsgtext)")
//                .rotationEffect(.degrees(angle))  // Apply initial rotation
//                .scaleEffect(scale)
//                .onChange(of: msgtext, perform: { newValue in
//                    withAnimation(Animation.linear(duration: 1.5).repeatCount(5, autoreverses: false)) {
//                        angle = angle == 360 ? -360 : 360  // Alternate between two angles
////                        scale = scale == 1.0 ? 2.0 : 1.0  // Alternate between original size and expanded size
////                        scale = Double.random(in: 0.5...2.5)
//                        scale = angle / 100
//                    }
//                })
            HStack {
                AdaptiveView {
                    HStack {
                        Button("\(myPlayers[0].Name)") {
                            withAnimation(.easeInOut) { winner = games.player1 }
                        }
                        .myButtonViewStyle(width: 260, height: MyDefaults().buttonHeight)
                        .buttonStyle(StaticButtonStyle())
                        if games.player1 == winner {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 32.0, height: 32.0)
                                .foregroundColor(.red)
                                .font(Font.body.bold())
                                .transition(.slide)
                        }
                    }
                    HStack {
                        Button("\(myPlayers[1].Name)") {
                            withAnimation(.easeInOut) { winner = games.player2 }
                        }
                        .myButtonViewStyle(width: 260, height: MyDefaults().buttonHeight)
                        .buttonStyle(StaticButtonStyle())
                        if games.player2 == winner {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 32.0, height: 32.0)
                                .foregroundColor(.red)
                                .font(Font.body.bold())
                                .transition(.slide)
                        }
                    }
                }
//                myButton(action: {
//                    winner = games.player1
//                }, content: {
//                    Text("\(myPlayers[0].Name)")
//                }, width: CGFloat(pickerWidth))
//
//                myButton(action: {
//                    winner = games.player2
//                }, content: {
//                    Text(" \(myPlayers[1].Name)")
//                },  width: CGFloat(pickerWidth))
//                .animation(.spring())

            }
//            Picker("Winner", selection: $winner) {
//                ForEach(myPlayers) { player in
//                    Text("\(player.myID) \(player.Name)").tag("\(player.myID)")
//                }
//            }
            .onAppear {
                if GameEntryNewGame {
                    winner = games.player1
                    score1 = myBoard.maxScore
                }
            }
            .onChange(of: winner, perform: { _ in
                if GameEntryNewGame {
                    winnerID = Int64(winner) ?? 0
                    if games.player1 == winner {
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
                        Text("\(players.getPlayerName(myID: games.player1)) Score:\(score1, specifier: "%.0f")")
                        Slider(value: $score1, in: myBoard.minScore ... myBoard.maxScore, step: 1.0)
                    }
                    VStack {
                        Text("\(players.getPlayerName(myID: games.player2)) Score:\(score2, specifier: "%.0f")")
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
                    ForEach(games.games.indices, id:\.self) { idx in
                        myButton(action: {
                            myGame = games.games[idx]
                            restore(game: games.games[idx])
                            returnedMessage = "Changing a game"
                            GameEntryEditingIdx = idx
                            GameEntryShowing.toggle()
                        }, content: { GameLineView(game: games.games[idx])}, width: geo.size.width, height: 51)


                    }
                  //  .id(UUID())
                }
            }
            .myBackgroundStyle()
            // .scrollContentBackground(.hidden)  // available in 16.0 only
        }
    }
    func restore(game: Game) {
        games.board = String(game.BoardID)
        score1 = game.Score1
        score2 = game.Score2
        datePlayed = game.DatePlayed
        winner = String(game.WinnerID)
        games.player1 = String(game.Player1ID)
        games.player2 = String(game.Player2ID)
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
            HStack {
                Text("Winner is \(Text("\(players.getName(myID: game.WinnerID))").foregroundColor(Color.red))   \(game.Score1, specifier: "%.0f")-\(game.Score2, specifier: "%.0f")")
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
