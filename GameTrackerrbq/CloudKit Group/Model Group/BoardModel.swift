//
//  BoardModel.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-27.
//

import Foundation
import CloudKit
import Combine

class Boards: ObservableObject {
    @Published var boards = [Board]()
    @Published var sectionDictionary : Dictionary<String , [Board]>
    @Published var isPresenting = [Bool]()
    @Published var isLoading: Bool = true
    @Published var isChanged: Int = 0
    @Published var errorMessage: String? = nil
    @Published var canDeletePlayer: Bool = false
    private var nextBoardID: Int64 = 0
    var cancellables = Set<AnyCancellable>()

    var isTracing: Bool = false
    func tracing(function: String) {
        if isTracing {
            print("Boards \(function) ")
            Logger.log("Boards \(function)")
        }
    }
    init() {
        self.boards = [
            Board.example1(),
            Board.example2()
        ]
        sectionDictionary = [:]
        sectionDictionary = getSectionedDictionary()
    }
    func rebuildDictionary() {
        boards.sort {
            $0.Name < $1.Name
        }
        sectionDictionary = [:]
        sectionDictionary = getSectionedDictionary()
    }
    func getSectionedDictionary() -> Dictionary <String , [Board]> {
        let sectionDictionary: Dictionary<String, [Board]> = {
            return Dictionary(grouping: boards, by: {
                let name = $0.Name
                let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                let firstChar = String(normalizedName.first!).uppercased()
                tracing(function: "getSectionedDictiony \(normalizedName)")
                return firstChar
            })
        }()
        return sectionDictionary
    }
    func GetNextID(_ completion: @escaping (Int64) -> ()) {
        tracing(function: "GetNextID")
        var lastRecord = [Board]()
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "myID", ascending: false)]
        CloudKitUtility.fetchOne(predicate: predicate, recordType: myRecordType.Board.rawValue, sortDescriptions: sort, resultsLimit: 1)
            .receive(on: DispatchQueue.main)
            .sink {  c in
                switch c {
                case .finished:
                    if lastRecord.count == 0 {
                        completion(1)
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
    func getName(myID: Int64) -> String {
        var idx = 0
        if let index = boards.firstIndex(where: {$0.myID == myID}) {
            idx = index
        }
        return boards[idx].Name
    }
    func getID(name: String) -> Int64 {
        var idx = 0
        if let index = boards.firstIndex(where: {$0.Name == name}) {
            idx = index
        }
        return boards[idx].myID
    }
    func getPlayerName(myID: String) -> String {
        return getName(myID: Int64(myID) ?? 0)

    }
    func findBoardsRecord(Name: String) -> Board {

            return boards.first(where: { $0.Name == Name}) ?? Board(Name: "UnKnown", GameType: 1, minScore: 1, maxScore: 10, myID: 0)!

    }
    func add(Name: String, GameType: Int64, minScore: Double, maxScore: Double, _ completion: @escaping (String) -> ()) {
        tracing(function: "add")
        // this is really an add function since the record does not exist and cloudkit thinks it is smart
        GetNextID() { nextmyID in

            guard let newRec = Board(Name: Name, GameType: GameType, minScore: minScore, maxScore: maxScore, myID: nextmyID) else { return }
        CloudKitUtility.update(item: newRec)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "add .finished")
                    completion("Board added")
                case .failure(let error):
                    self.tracing(function: "add error = \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedItems in
                self?.boards.append(newRec)
                self?.rebuildDictionary()
            }
            .store(in: &self.cancellables)
        }
    }
    func change(board: Board, _ completion: @escaping (String) -> ()) {
        tracing(function: "change")

        guard let index = boards.firstIndex(where: { $0.id == board.id }) else { return }
        CloudKitUtility.update(item: board)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "change .finished")
                    completion("Board changed")
                case .failure(let error):
                    self.tracing(function: "change error = \(error.localizedDescription)")
                    completion("change error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
                self.tracing(function: "change success is \(success)")
                self.boards[index] = board
                self.rebuildDictionary()
            }
            .store(in: &cancellables)
    }
    // passing in the playerRec in case you would want to log the delete by name
    func delete(board: Board, _ completion: @escaping (String) -> ()) {
        tracing(function: "delete")
        guard let index = boards.firstIndex(where: { $0.id == board.id }) else
                    { return  }
        CloudKitUtility.delete(item: board)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "add .finished")
                    completion("Board deleted")
                case .failure(let error):
                    self.tracing(function: "change error = \(error.localizedDescription)")
                    completion("delete error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
                self.tracing(function: "Delete is \(success)")
                self.boards.remove(at: index)
                self.rebuildDictionary()
            }
            .store(in: &cancellables)
    }
    func fetchAll(_ completion: @escaping (String) -> ()) {
        tracing(function: "fetchAll enter")
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "Name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Board.rawValue, sortDescriptions: sort)
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
                self?.boards = returnedItems
//                 self?.sectionDictionary = [:]
//                 sectionDictionary = getSectionedDictionary()
            }
            .store(in: &cancellables)
        tracing(function: "fetchAll exit")
    }
}

