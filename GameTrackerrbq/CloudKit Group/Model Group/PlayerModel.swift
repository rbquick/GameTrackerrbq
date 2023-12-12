//
//  PlayerModel.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-27.
//

import CloudKit
import Combine

class Players: ObservableObject {
    @Published var players = [Player]()
    @Published var sectionDictionary : Dictionary<String , [Player]>
    @Published var isPresenting = [Bool]()
    @Published var isLoading: Bool = true
    @Published var isChanged: Int = 0
    @Published var errorMessage: String? = nil
    @Published var canDeletePlayer: Bool = false
    private var nextGameID: Int64 = 0
    var cancellables = Set<AnyCancellable>()

    var isTracing: Bool = false
    func tracing(function: String) {
        if isTracing {
            print("\(Date()):Players \(function) ")
            Logger.log("Players \(function)")
        }
    }
    init() {
        self.players = [
            Player.example1(),
            Player.example2()
        ]
        sectionDictionary = [:]
        sectionDictionary = getSectionedDictionary()
    }
    func rebuildDictionary() {
        players.sort {
            $0.Name < $1.Name
        }
        sectionDictionary = [:]
        sectionDictionary = getSectionedDictionary()
    }
    func getSectionedDictionary() -> Dictionary <String , [Player]> {
        let sectionDictionary: Dictionary<String, [Player]> = {
            return Dictionary(grouping: players, by: {
                var name = $0.Name
                if name.isEmpty { name = "A"} // #TODO this can be removed when the picker is fixed for a blank
                let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                let firstChar = String(normalizedName.first!).uppercased()
                tracing(function: "getSectionedDictiony \(normalizedName)")
                return firstChar
            })
        }()
        return sectionDictionary
    }
    // This is done to select nothing for a player?
    func BlankAdd() {
        if players.count > 0 {
            if players[0].Name != "" {
                players.insert(Player(Name: "", myID: 0)!, at: 0)
            }
        }
    }
    func BlankRemove() {
        players.removeAll(where: {$0.Name == ""})
        tracing(function: "Playrs.BlankRemove")
    }
    func GetNextID(_ completion: @escaping (Int64) -> ()) {
        tracing(function: "GetNextID")
        var lastRecord = [Player]()
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "myID", ascending: false)]
        CloudKitUtility.fetchOne(predicate: predicate, recordType: myRecordType.Player.rawValue, sortDescriptions: sort, resultsLimit: 1)
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
    func getName(myID: Int64) -> String {
        var idx = 0
        if let index = players.firstIndex(where: {$0.myID == myID}) {
            idx = index
        }
        return players[idx].Name
    }
    func getPlayerName(myID: String) -> String {
        return getName(myID: Int64(myID) ?? 0)

    }
    func getmyIDFromStringID(myID: String) -> Int64 {
        var idx = 0
        if let index = players.firstIndex(where: {$0.myID == Int64(myID)}) {
            idx = index
        }
        return players[idx].myID
    }
    func findPlayersRecord(Name: String) -> Player {

            return players.first(where: { $0.Name == Name}) ?? Player(Name: "New Record", myID: 1)!

    }
    func add(Name: String, _ completion: @escaping (String) -> ()) {
        tracing(function: "add")
        // this is really an add function since the record does not exist and cloudkit thinks it is smart
        GetNextID() { nextmyID in

            guard let newRec = Player(Name: Name, myID: nextmyID) else { return }
        CloudKitUtility.update(item: newRec)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "add .finished")
                    completion("Player added")
                case .failure(let error):
                    self.tracing(function: "add error = \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] returnedItems in
                self?.players.append(newRec)
                self?.rebuildDictionary()
            }
            .store(in: &self.cancellables)
        }
    }
    func change(player: Player, _ completion: @escaping (String) -> ()) {
        tracing(function: "change")

        guard let index = players.firstIndex(where: { $0.id == player.id }) else { return }
        CloudKitUtility.update(item: player)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "change .finished")
                    completion("Player changed")
                case .failure(let error):
                    self.tracing(function: "change error = \(error.localizedDescription)")
                    completion("change error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
                self.tracing(function: "change success is \(success)")
                self.players[index] = player
                self.rebuildDictionary()
            }
            .store(in: &cancellables)
    }
    // passing in the playerRec in case you would want to log the delete by name
    func delete(player: Player, _ completion: @escaping (String) -> ()) {
        tracing(function: "delete")
        guard let index = players.firstIndex(where: { $0.id == player.id }) else
                    { return  }
        CloudKitUtility.delete(item: player)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "add .finished")
                    completion("Player deleted")
                case .failure(let error):
                    self.tracing(function: "change error = \(error.localizedDescription)")
                    completion("delete error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
                self.tracing(function: "Delete is \(success)")
                self.players.remove(at: index)
                self.rebuildDictionary()
            }
            .store(in: &cancellables)
    }
    func fetchAll(_ completion: @escaping (String) -> ()) {
        tracing(function: "fetchAll enter")
        let predicate = NSPredicate(value: true)
        let sort = [NSSortDescriptor(key: "Name", ascending: true)]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.Player.rawValue, sortDescriptions: sort)
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
                self?.players = returnedItems
//                 self?.sectionDictionary = [:]
//                 sectionDictionary = getSectionedDictionary()
            }
            .store(in: &cancellables)
        tracing(function: "fetchAll exit")
    }
}
