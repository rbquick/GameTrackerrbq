//
//  BoardMessage.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2024-07-30.
//

import Foundation
import CloudKit
import Combine

class BoardMessages:  ObservableObject {
    @Published var messages = [BoardMessage]()
    var cancellables = Set<AnyCancellable>()
    var isTracing: Bool = false
    func tracing(function: String) {
        if isTracing {
            print("\(Date()):BoardMessages \(function) ")
            Logger.log("BoardMessages \(function)")
        }
    }
    init() {
        self.messages = [BoardMessage.example1(),
                         BoardMessage.example2(),
                         BoardMessage.example3()]
    }
    func getmsgtext(boardname: String, score: Double) -> String {
        var msg = ""
        for i in 0...messages.count - 1 {
            if messages[i].boardName == boardname {
                msg += checkCondition(Int(score), messages[i].relation, Int(messages[i].score)) ? messages[i].msgtext : ""
               msg += " "
            }
        }
        return msg
    }
    func findMessagesRecord(Name: String) -> BoardMessage {

        return messages.first(where: { $0.boardName == Name}) ?? BoardMessage(boardName: "unknown", score: 99, relation: ">", msgtext: "unknown")!

    }
    func add(boardName: String, score: Double, relation: String, msgtext: String, _ completion: @escaping (String) -> ()) {
        guard let newRec = BoardMessage(boardName: boardName, score: score, relation: relation, msgtext: msgtext) else { return }
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
                self?.messages.append(newRec)
            }
            .store(in: &self.cancellables)
    }
    func change(boardmessage: BoardMessage, _ completion: @escaping (String) -> ()) {
        tracing(function: "change")

        guard let index = messages.firstIndex(where: { $0.id == boardmessage.id }) else { return }
        CloudKitUtility.update(item: boardmessage)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "change .finished")
                    completion("BoardMessage changed")
                case .failure(let error):
                    self.tracing(function: "change error = \(error.localizedDescription)")
                    completion("change error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
                self.tracing(function: "change success is \(success)")
                self.messages[index] = boardmessage
            }
            .store(in: &cancellables)
    }
    // passing in the playerRec in case you would want to log the delete by name
    func delete(boardmessage: BoardMessage, _ completion: @escaping (String) -> ()) {
        tracing(function: "delete")
        guard let index = messages.firstIndex(where: { $0.id == boardmessage.id }) else
                    { return  }
        CloudKitUtility.delete(item: boardmessage)
            .receive(on: DispatchQueue.main)
            .sink { c in
                switch c {
                case .finished:
                    self.tracing(function: "delete .finished")
                    completion("Board deleted")
                case .failure(let error):
                    self.tracing(function: "change error = \(error.localizedDescription)")
                    completion("delete error = \(error.localizedDescription)")
                }
            } receiveValue: { success in
                self.tracing(function: "Delete is \(success)")
                self.messages.remove(at: index)
            }
            .store(in: &cancellables)
    }
    func fetchAll(_ completion: @escaping (String) -> ()) {
        tracing(function: "fetchAll enter")
        messages.removeAll()
        let predicate = NSPredicate(value: true)
        let sort = [
            NSSortDescriptor(key: "boardName", ascending: true)
//            NSSortDescriptor(key: "score", ascending: true)
        ]
        CloudKitUtility.fetchAll(predicate: predicate, recordType: myRecordType.BoardMessage.rawValue, sortDescriptions: sort)
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
                self?.messages = returnedItems
            }
            .store(in: &cancellables)
        tracing(function: "fetchAll exit")
    }
    
}
