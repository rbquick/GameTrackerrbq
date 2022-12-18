//
//  GameRec.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-27.
//

import CloudKit

struct Game: Identifiable, CloudKitableProtocol {
    let id: CKRecord.ID
    let BoardID: Int64
    let Board: String
    let DatePlayed: Date
    let WinnerID: Int64
    let Player1ID: Int64
    let Score1: Double
    let Player2ID: Int64
    let Score2: Double
    let myID: Int64
    let record: CKRecord

    init?(record: CKRecord) {
        self.id = record.recordID
        self.BoardID = record["BoardID"] as? Int64 ?? 0
        self.Board = record["Board"] as? String ?? ""
        self.DatePlayed = record["DatePlayed"] as? Date ?? Date()
        self.WinnerID = record["WinnerID"] as? Int64 ?? 0
        self.Player1ID = record["Player1ID"] as? Int64 ?? 0
        self.Score1 = record["Score1"] as? Double ?? 0
        self.Player2ID = record["Player2ID"] as? Int64 ?? 0
        self.Score2 = record["Score2"] as? Double ?? 0
        self.myID = record["myID"] as? Int64 ?? 0
        self.record = record
    }
    init?(BoardID: Int64, Board: String, DatePlayed: Date, WinnerID: Int64, Player1ID: Int64, Score1: Double, Player2ID: Int64, Score2: Double, myID: Int64) {
        let record = CKRecord(recordType: myRecordType.Game.rawValue)
        record["BoardID"] = BoardID
        record["Board"] = Board
        record["DatePlayed"] = DatePlayed
        record["WinnerID"] = WinnerID
        record["Player1ID"] = Player1ID
        record["Score1"] = Score1
        record["Player2ID"] = Player2ID
        record["Score2"] = Score2
        record["myID"] = myID
        self.init(record: record)
    }
    func update(BoardID: Int64, Board: String, DatePlayed: Date, WinnerID: Int64, Player1ID: Int64, Score1: Double, Player2ID: Int64, Score2: Double) -> Game? {
        let record = record
        record["BoardID"] = BoardID
        record["Board"] = Board
        record["DatePlayed"] = DatePlayed
        record["WinnerID"] = WinnerID
        record["Player1ID"] = Player1ID
        record["Score1"] = Score1
        record["Player2ID"] = Player2ID
        record["Score2"] = Score2
        return Game(record: record)
    }

    static func example1() -> Game {
        return Game(BoardID: 1, Board: "Euchre", DatePlayed: Date(), WinnerID: 1, Player1ID: 1, Score1: 10, Player2ID: 2, Score2: 1, myID: 1)!
    }
    static func example2() -> Game {
        return Game(BoardID: 1, Board: "Euchre", DatePlayed: Date(), WinnerID: 1, Player1ID: 2, Score1: 10, Player2ID: 1, Score2: 2, myID: 2)!
    }
}
