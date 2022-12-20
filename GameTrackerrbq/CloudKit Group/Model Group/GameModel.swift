//
//  GameModel.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-27.
//

import CloudKit
import Combine

class Games: ObservableObject {
    @Published var games = [Game]()
    @Published var sectionDictionary : Dictionary<String , [Game]>
    @Published var isPresenting = [Bool]()
    @Published var isLoading: Bool = true
    @Published var isChanged: Int = 0
    @Published var errorMessage: String? = nil
    @Published var canDeleteGame: Bool = false

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
        games.removeAll()
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
                    self.tracing(function: "add .finished")
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
    func fetchAll(_ completion: @escaping (String) -> ()) {
        tracing(function: "fetchAll enter")
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "DatePlayed", ascending: false)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Game.rawValue, sortDescriptions: sort)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "fetchAll .finished")
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
}
