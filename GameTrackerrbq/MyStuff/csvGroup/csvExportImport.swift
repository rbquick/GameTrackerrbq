//
//  csvExportImport.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2023-12-01.
//

import SwiftUI

struct csvExportImport: View {
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
                        showingBoardExporter.toggle()
                    }, content: {
                        Text("Export Boards")
                    }, width: buttonWidth
                    )
                    .fileMover(isPresented: $showingBoardExporter, file: fileURLBoard()) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }

                    myButton(action: {
                        showingBoardImporter.toggle()
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
        .hiddenConditionally(boards.boards.count == 0)

        Group {
        Divider()
            .overlay(Color.red)
                VStack(spacing: 0) {
                    Text("There are \(players.players.count) boards on file")
                    Text("\(Player.example1().csvHeadingLine)")
                    myButton(action: {
                        showingPlayerExporter.toggle()
                    }, content: {
                        Text("Export Players")
                    }, width: buttonWidth
                    )
                    .fileMover(isPresented: $showingPlayerExporter, file: fileURLPlayer()) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }

                    myButton(action: {
                        showingPlayerImporter.toggle()
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
        .hiddenConditionally(players.players.count == 0, remove: true)
        Group {
        Divider()
                .overlay(Color.red)

                VStack(spacing: 0) {
                    Text("There are \(games.games.count) boards on file")
                    Text("\(Game.example1().csvHeadingLine)")
                    myButton(action: {
                        showingGameExporter.toggle()
                    }, content: {
                        Text("Export Games")
                    }, width: buttonWidth
                    )
                    .fileMover(isPresented: $showingGameExporter, file: fileURLGame()) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    myButton(action: {
                        showingGameImporter.toggle()
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
        .hiddenConditionally(games.games.count == 0)
        Divider()
            .overlay(Color.red)
    }
    }
}

struct csvExportImport_Previews: PreviewProvider {
    static var previews: some View {
        csvExportImport()
            .environmentObject(Boards())
            .environmentObject(Players())
            .environmentObject(Games())
    }
}

extension csvExportImport {
    func fileURLPlayer() -> URL? {
        // FIXME: working on the generic createCSV function for a player or board
        Player.createCSVPlayer(from: players.players, outFile: "Players.csv")
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
        Board.createCSVBoard(from: boards.boards, outFile: "Boards.csv")
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
        Game.createCSVGame(from: games.games, outFile: "Games.csv")
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
