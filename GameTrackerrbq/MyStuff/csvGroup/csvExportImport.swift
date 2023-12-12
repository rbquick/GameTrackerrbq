//
//  csvExportImport.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2023-12-01.
//

import SwiftUI
import CloudKit
import Combine

struct csvExportImport: View {
    @EnvironmentObject var sm: StateManager
    @EnvironmentObject var boards: Boards
    @EnvironmentObject var players: Players
    @EnvironmentObject var games: Games

    let buttonWidth:CGFloat = 200

    @State private var showingBoardExporter = false
    @State private var showingBoardImporter = false
    @State private var showingPlayerExporter = false
    @State private var showingPlayerImporter = false
    @State private var showingGameExporter = false
    @State private var showingGameImporter = false


    @State var cancellables = Set<AnyCancellable>()
    @State private var returnedMessage = ""

    @State private var aDate: Date = myDateFormatter(inDate:  "2023-11-22 20:39:32 +0000")
    var body: some View {
    VStack {
        Group {
        Divider()
            .overlay(Color.red)
                VStack(spacing: 0) {
                    Text("There are \(boards.boards.count) boards on file")
                    Text("\(Board.example1().csvHeadingLine)")
                    myButton(action: {
                        boards.fetchAll() { rtnMessage in
                            returnedMessage = rtnMessage
                            players.sectionDictionary = [:]
                            players.sectionDictionary = players.getSectionedDictionary()
                            showingBoardExporter.toggle()
                        }
                    }, content: {
                        Text("Export Boards")
                    }, width: buttonWidth
                    )
                    .fileMover(isPresented: $showingBoardExporter, file: Board.example1().csvfileURL(from: boards.boards, outFile: "Boards.csv")) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }

                    myButton(action: {
                        var myBoards = [Board]()
                        let predicate = NSPredicate(value: true)
                        CloudKitUtility.getAllRecordsAndDelete(predicate: predicate, recordType: myRecordType.Board.rawValue)
                            .receive(on: DispatchQueue.main)
                            .sink { _ in
                                print("delete count = \(myBoards.count)")
                                showingBoardImporter.toggle()
                            } receiveValue: { returnedBoards in
                                myBoards = returnedBoards
                            }
                            .store(in: &cancellables)

                    }, content: {
                        Text("Import Boards")
                    }, width: buttonWidth
                    )
                    .fileImporter(
                        isPresented: $showingBoardImporter,
                        allowedContentTypes: [.plainText],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            if selectedFile.startAccessingSecurityScopedResource() {
                                guard let data = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                                defer { selectedFile.stopAccessingSecurityScopedResource() }
                                boards.boards = Board.dataToStructGeneric(data: data)
                                var newBoards:[CKRecord] = []
                                for board in boards.boards {
                                    let newRec = Board(Name: board.Name, GameType: board.GameType, minScore: board.minScore, maxScore: board.maxScore, myID: board.myID)!
                                    newBoards.append(newRec.record)
                                }
                                CloudKitUtility.saveAllRecords(newBoards)
                            } else {
                                // Handle denied access
                            }
                            //data = try String(contentsOf: fileURL, encoding: .utf8)
    //                        print("imported")

                        } catch {
                            // Handle failure.
                            print(error.localizedDescription)
                        }
                    }
                }
        }

        Group {
        Divider()
            .overlay(Color.red)
                VStack(spacing: 0) {
                    Text("There are \(players.players.count) players on file")
                    Text("\(Player.example1().csvHeadingLine)")
                    myButton(action: {
                        showingPlayerExporter.toggle()
                    }, content: {
                        Text("Export Players")
                    }, width: buttonWidth
                    )
                    .fileMover(isPresented: $showingPlayerExporter, file: Player.example1().csvfileURL(from: players.players, outFile: "Players.csv")) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }

                    myButton(action: {
                        var myPlayers = [Player]()
                        let predicate = NSPredicate(value: true)
                        CloudKitUtility.getAllRecordsAndDelete(predicate: predicate, recordType: myRecordType.Player.rawValue)
                            .receive(on: DispatchQueue.main)
                            .sink { _ in
                                print("delete count = \(myPlayers.count)")
                                showingPlayerImporter.toggle()
                            } receiveValue: { returnedPlayers in
                                myPlayers = returnedPlayers
                            }
                            .store(in: &cancellables)
                    }, content: {
                        Text("Import Players")
                    }, width: buttonWidth
                    )
                    .fileImporter(
                        isPresented: $showingPlayerImporter,
                        allowedContentTypes: [.plainText],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            if selectedFile.startAccessingSecurityScopedResource() {
                                guard let data = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                                defer { selectedFile.stopAccessingSecurityScopedResource() }
                                players.players = Player.dataToStructGeneric(data: data)
                                var newPlayers:[CKRecord] = []
                                for player in players.players {
                                    let newrec = Player(Name: player.Name, myID: player.myID)!
                                    newPlayers.append(newrec.record)
                                }
                                CloudKitUtility.saveAllRecords(newPlayers)
                            } else {
                                // Handle denied access
                            }
                            //data = try String(contentsOf: fileURL, encoding: .utf8)
    //                        print("imported")

                        } catch {
                            // Handle failure.
                            print(error.localizedDescription)
                        }
                    }
                }
        }
        Group {
        Divider()
                .overlay(Color.red)

                VStack(spacing: 0) {
                    Text("There are \(games.games.count) games on file")
                    Text("\(Game.example1().csvHeadingLine)")
                    myButton(action: {
                        games.fetchAllRestricted = false
//                        sm.isLoading = true
                        games.fetchAll() { rtnMessage in
                            returnedMessage = rtnMessage
                            games.sectionDictionary = [:]
                            games.sectionDictionary = games.getSectionedDictionary()
                            sm.isLoading = false
                            showingGameExporter.toggle()
                        }
                    }, content: {
                        Text("Export Games")
                    }, width: buttonWidth
                    )
                    .fileMover(isPresented: $showingGameExporter, file: games.games[0].csvfileURL(from: games.games, outFile: "Games.csv")) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    myButton(action: {
                        var myGames = [Game]()
                        let predicate = NSPredicate(value: true)
                        CloudKitUtility.getAllRecordsAndDelete(predicate: predicate, recordType: myRecordType.Game.rawValue)
                            .receive(on: DispatchQueue.main)
                            .sink { _ in
                                print("delete count = \(myGames.count)")
                                showingGameImporter.toggle()
                            } receiveValue: { returnedGames in
                                myGames = returnedGames
                            }
                            .store(in: &cancellables)
                    }, content: {
                        Text("Import Games")
                    }, width: buttonWidth
                    )
                    .fileImporter(
                        isPresented: $showingGameImporter,
                        allowedContentTypes: [.plainText],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            guard let selectedFile: URL = try result.get().first else { return }
                            if selectedFile.startAccessingSecurityScopedResource() {
                                guard let data = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                                defer { selectedFile.stopAccessingSecurityScopedResource() }
                                games.games = Game.dataToStructGeneric(data: data)
                                var newGames:[CKRecord] = []
                                for game in games.games {
                                    let newrec = Game(BoardID: game.BoardID, Board: game.Board, DatePlayed: game.DatePlayed, WinnerID: game.WinnerID, Player1ID: game.Player1ID, Score1: game.Score1, Player2ID: game.Player2ID, Score2: game.Score2, myID: game.myID)!
                                    newGames.append(newrec.record)
                                }
                                CloudKitUtility.saveAllRecords(newGames)
                            } else {
                                // Handle denied access
                            }
                            //data = try String(contentsOf: fileURL, encoding: .utf8)
    //                        print("imported")

                        } catch {
                            // Handle failure.
                            print(error.localizedDescription)
                        }
                    }

                }
        }
        Divider()
            .overlay(Color.red)
    }
    }
}

struct csvExportImport_Previews: PreviewProvider {
    static var previews: some View {
        csvExportImport()
            .environmentObject(StateManager())
            .environmentObject(Boards())
            .environmentObject(Players())
            .environmentObject(Games())
    }
}

extension csvExportImport {
    func fileURLPlayer() -> URL? {
        Player.createCSV(from: players.players, outFile: "Players.csv")
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let myURL = path.appendingPathComponent("Players.csv")
            return myURL
        } catch {
            print("error creating file")
            return nil
        }
    }
    func fileURLBoard() -> URL? {
        Board.createCSV(from: boards.boards, outFile: "Boards.csv")
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let myURL = path.appendingPathComponent("Boards.csv")
            return myURL
        } catch {
            print("error creating file")
            return nil
        }
    }
    func fileURLGame() -> URL? {
        Game.createCSV(from: games.games, outFile: "Games.csv")
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let myURL = path.appendingPathComponent("Games.csv")
            return myURL
        } catch {
            print("error creating file")
            return nil
        }
    }


     func dataToStruct(data: String) -> [Board] {
        var csvToStruct = [Board]()
        var rows = data.components(separatedBy: "\n")
        // remove header rows
        let columnCount = rows.first?.components(separatedBy: ",").count
        rows.removeFirst()

        // now loop around each row and split into columns
        for row in rows {
            let csvColumns = row.components(separatedBy: ",")
            if csvColumns.count == columnCount {
                let genericStruct = Board.init(raw: csvColumns)
                csvToStruct.append(genericStruct!)
            }
        }
        return csvToStruct
    }

}
