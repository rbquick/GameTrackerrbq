//
//  GameModel.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-27.
//

import CloudKit
import Combine

class Games: ObservableObject, Equatable {
    static func == (lhs: Games, rhs: Games) -> Bool {
        return true
    }

    @Published var games = [Game]()
    @Published var sectionDictionary : Dictionary<String , [Game]>
    @Published var isPresenting = [Bool]()
    @Published var isLoading: Bool = true
    @Published var isChanged: Int = 0
    @Published var errorMessage: String? = nil
    @Published var canDeleteGame: Bool = false
    @Published var fetchAllRestricted: Bool = true
    @Published var fetchAllRestrictedCount: Int = 5

    // screen input fields are strings and then accessing fields are Int64
    @Published var board: String = "" {
        didSet {
            self.boardID = Int64(board) ?? 0
        }
    }
    @Published var boardID: Int64 = 0
    @Published var player1: String = "" {
        didSet {
            self.player1ID = Int64(player1) ?? 0
        }
    }
    @Published var player1ID: Int64 = 0
    @Published var player2: String = "" {
        didSet {
            self.player2ID = Int64(player2) ?? 0
        }
    }
    @Published var player2ID: Int64 = 0

    // different way to look at the games played
    // all driven by the above variables
     var GlistGames: [Game] {
        if player1ID == 0 || player2ID == 0 {
            return games.filter {
                $0.BoardID == self.boardID
                && (( $0.Player1ID == player1ID || $0.Player1ID == player2ID )
                    || ( $0.Player2ID == player1ID || $0.Player2ID == player2ID) )
            }
        } else {
            return games.filter {
                $0.BoardID == self.boardID
                && ( $0.Player1ID == player1ID || $0.Player1ID == player2ID )
                && ( $0.Player2ID == player1ID || $0.Player2ID == player2ID )
            }
        }
    }
    var lastDate: Date {
        if self.GlistGames.count > 0 {
            return self.GlistGames[0].DatePlayed
        } else {
            return Date()
        }
    }
    var todayGames: [Game] {
        return self.GlistGames.filter { game in
            Calendar.current.isDate( game.DatePlayed, equalTo: lastDate, toGranularity: .day)
        }
    }
    var player1TodayGamesWon: [Game] {

        //return [Game]()
        return todayGames.filter { game in
            self.player1ID == game.WinnerID
        }
    }
    var player2TodayGamesWon: [Game] {
        //return [Game]()
        return todayGames.filter { game in
            self.player2ID == game.WinnerID
        }
    }
    var player1TotalGamesWon: [Game] {
        //return [Game]()
        return self.GlistGames.filter { game in
            self.player1ID == game.WinnerID
        }
    }
    var player2TotalGamesWon: [Game] {
        //return [Game]()
        return self.GlistGames.filter { game in
            self.player2ID == game.WinnerID
        }
    }
    var rubbersPlayer1Today: Int {
        return CountOneRubber(myGames: self.todayGames, playerID: self.player1ID)
    }
    var rubbersPlayer2Today: Int {
        CountOneRubber(myGames: self.todayGames, playerID: self.player2ID)
    }
    var rubbersPlayer1Total: Int {
        CountOneRubber(myGames: self.GlistGames, playerID: self.player1ID)
    }
    var rubbersPlayer2Total: Int {
        CountOneRubber(myGames: self.GlistGames, playerID: self.player2ID)
    }
    //    func CountRubbers() {
    //        rubbersPlayer1Today = CountOneRubber(myGames: todayGames, playerID: Int64(player1) ?? 0)
    //        rubbersPlayer2Today = CountOneRubber(myGames: todayGames, playerID: Int64(player2) ?? 0)
    //        rubbersPlayer1Total = CountOneRubber(myGames: listGames, playerID: Int64(player1) ?? 0)
    //        rubbersPlayer2Total = CountOneRubber(myGames: listGames, playerID: Int64(player2) ?? 0)
    //    }
        func CountOneRubber(myGames: [Game], playerID: Int64) -> Int {
           //return 999
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





    var cancellables = Set<AnyCancellable>()

    var isTracing: Bool = true
    func tracing(function: String) {
        if isTracing {
            print("Games \(function) ")
            Logger.log("Games \(function)")
        }
    }
    init() {
        self.games = [
            Game.example1(),
            Game.example2()
        ]
        sectionDictionary = [:]
        sectionDictionary = getSectionedDictionary()
//        games.removeAll()
        }

func rebuildDictionary() {
    games.sort {
        $0.BoardID < $1.BoardID
    }
    sectionDictionary = [:]
    sectionDictionary = getSectionedDictionary()
}
func getSectionedDictionary() -> Dictionary <String , [Game]> {
    let sectionDictionary: Dictionary<String, [Game]> = {
        return Dictionary(grouping: games, by: {
            let name = $0.Board
            let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            let firstChar = String(normalizedName.first!).uppercased()
            return firstChar
        })
    }()
    return sectionDictionary
}
    func GetNextID(_ completion: @escaping (Int64) -> ()) {
        tracing(function: "GetNextID")
        var lastRecord = [Game]()
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "myID", ascending: false)]
        CloudKitUtility.fetchOne(predicate: predicate, recordType: myRecordType.Game.rawValue, sortDescriptions: sort, resultsLimit: 1)
            .receive(on: DispatchQueue.main)
            .sink {  c in
                switch c {
                case .finished:
                    if lastRecord.count == 0 {
                        completion(0)
                    } else {
                        completion(lastRecord[0].myID + 1)
                    }
                case .failure(let error):
                    self.tracing(function: "GetNextID error = \(error.localizedDescription)")
                }
            } receiveValue: { returnedItems in
                lastRecord = returnedItems
            }
            .store(in: &cancellables)
    }
    func add(BoardID: Int64, Board: String, DatePlayed: Date, WinnerID: Int64, Player1ID: Int64, Score1: Double, Player2ID: Int64, Score2: Double, _ completion: @escaping (String) -> ()) {
        tracing(function: "add")
        GetNextID() { nextmyID in
            guard let newRec = Game(BoardID: BoardID, Board: Board, DatePlayed: DatePlayed, WinnerID: WinnerID, Player1ID: Player1ID, Score1: Score1, Player2ID: Player2ID, Score2: Score2, myID: nextmyID) else { return }
            // this is really an add function since the record does not exist and cloudkit thinks it is smart
            CloudKitUtility.update(item: newRec)
                .receive(on: DispatchQueue.main)
                .sink { c in
                    switch c {
                    case .finished:
                      //  self.GlistGamesBuild()
                        self.tracing(function: "add .finished")
                        completion("Game added")
                    case .failure(let error):
                        self.tracing(function: "add error = \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] returnedItems in
                    self?.games.insert(newRec, at: 0)
                }
                .store(in: &self.cancellables)
        }
    }
    func change(game: Game, _ completion: @escaping (String) -> ()) {
        tracing(function: "change")

        guard let index = games.firstIndex(where: { $0.id == game.id }) else { return }
        CloudKitUtility.update(item: game)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                   // self.GlistGamesBuild()
                    self.tracing(function: "change .finished")
                    completion("Game changed")
                case .failure(let error):
                    self.tracing(function: "change error = \(error.localizedDescription)")
                    completion("change error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
                self.tracing(function: "change success is \(success)")
                self.games[index] = game
            }
            .store(in: &cancellables)
    }
    // passing in the playerRec in case you would want to log the delete by name
    func delete(game: Game, _ completion: @escaping (String) -> ()) {
        tracing(function: "delete")
        guard let index = games.firstIndex(where: { $0.id == game.id }) else
                    { return  }
        CloudKitUtility.delete(item: game)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                  //  self.GlistGamesBuild()
                    self.tracing(function: "delete .finished")
                    completion("Game deleted")
                case .failure(let error):
                    self.tracing(function: "change error = \(error.localizedDescription)")
                    completion("delete error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
                self.tracing(function: "Delete is \(success)")
                self.games.remove(at: index)
            }
            .store(in: &cancellables)
    }
    func fetchSelective(board: Int64, player1ID: Int64, player2ID: Int64, _ completion: @escaping (String) -> ()) {
        tracing(function: "fetchAll enter")
        let predicate = NSPredicate(format:"BoardID == %@ AND Player1ID == %@ AND Player2ID == %@", NSNumber(value: board), NSNumber(value: player1ID), NSNumber(value: player2ID))
        let sort = [
            NSSortDescriptor(key: "BoardID", ascending: true),
            NSSortDescriptor(key: "DatePlayed", ascending: false)
        ]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Game.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
//                    if self.games.count > 0 {
////                        self.player1 = String(self.games[0].Player1ID)
////                        self.player2 = String(self.games[0].Player2ID)
////                        self.board = String(self.games[0].BoardID)
//                    } else {
//                        self.games.append(Game.NoGames())
//                    }
                    // build new table of records and strip for performance
                    if self.fetchAllRestricted {
                        var selectedgames = [Game]()
                        var currentBoardID: Int64 = 0
                        var currentCount: Int = 0
                        for  game in self.games {
                            if game.BoardID != currentBoardID {
                                currentCount = 0
                                currentBoardID = game.BoardID
                            }
                            if currentCount < self.fetchAllRestrictedCount {
                                currentCount += 1
                                selectedgames.append(game)
                            }
                        }
                        self.games = selectedgames
                    }
                  //  self.GlistGamesBuild()
                    self.tracing(function: "fetchAll .finished games.count = \(self.games.count)")
                    completion("fetchAll Completed")
                case .failure(let error):
                    self.tracing(function: "fetchAll error = \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedItems in
                self?.games = returnedItems

            }
            .store(in: &cancellables)
        tracing(function: "fetchAll exit")
    }
    func fetchAll(_ completion: @escaping (String) -> ()) {
        tracing(function: "fetchAll enter")
        let predicate = NSPredicate(value: true)
        let sort = [
            NSSortDescriptor(key: "BoardID", ascending: true),
            NSSortDescriptor(key: "DatePlayed", ascending: false)
        ]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Game.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    if self.games.count > 0 {
                        self.player1 = String(self.games[0].Player1ID)
                        self.player2 = String(self.games[0].Player2ID)
                        self.board = String(self.games[0].BoardID)
                    }
                    // build new table of records and strip for performance
                    if self.fetchAllRestricted {
                        var selectedgames = [Game]()
                        var currentBoardID: Int64 = 0
                        var currentCount: Int = 0
                        for  game in self.games {
                            if game.BoardID != currentBoardID {
                                currentCount = 0
                                currentBoardID = game.BoardID
                            }
                            if currentCount < self.fetchAllRestrictedCount {
                                currentCount += 1
                                selectedgames.append(game)
                            }
                        }
                        self.games = selectedgames
                    }
                  //  self.GlistGamesBuild()
                    self.tracing(function: "fetchAll .finished games.count = \(self.games.count)")
                    completion("fetchAll Completed")
                case .failure(let error):
                    self.tracing(function: "fetchAll error = \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedItems in
                self?.games = returnedItems

            }
            .store(in: &cancellables)
        tracing(function: "fetchAll exit")
    }
    func findFirstForBoard(board: Board) -> Game {
        var thisGame = games.first(where: { $0.BoardID == board.myID })
        if thisGame == nil {
            thisGame = Game(BoardID: 0, Board: "Unknown", DatePlayed: Date(), WinnerID: 0, Player1ID: 0, Score1: 0, Player2ID: 0, Score2: 0, myID: 0)
        }
        return thisGame!
    }
}
