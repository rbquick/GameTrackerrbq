//
//  BoardRec.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-27.
//

import Foundation
import CloudKit
enum gametype: Int64 {
    case onePlayer = 1
    case twoPlayer = 2
    case threePlayer = 3
    case fourPlayer = 4
}
struct Board: Identifiable, CloudKitableProtocol {
    let id: CKRecord.ID
    let Name: String
    let GameType: Int64
    let minScore: Double
    let maxScore: Double
    let myID: Int64
    let record: CKRecord

    init?(record: CKRecord) {
        self.id = record.recordID
        self.Name = record["Name"] as? String ?? "Brian"
        self.GameType = record["GameType"] as? gametype.RawValue ?? gametype.twoPlayer.rawValue
        self.minScore = record["minScore"] as? Double ?? 0
        self.maxScore = record["maxScore"] as? Double ?? 10
        self.myID = record["myID"] as? Int64 ?? 1
        self.record = record
    }

    init?(Name: String, GameType: Int64, minScore: Double, maxScore: Double, myID: Int64) {
        let record = CKRecord(recordType: myRecordType.Board.rawValue)
        record["Name"] = Name
        record["GameType"] = GameType
        record["minScore"] = minScore
        record["maxScore"] = maxScore
        record["myID"] = myID
        self.init(record: record)
    }

    func update(Name: String, Gametype: Int64, minScore: Double, maxScore: Double) -> Board? {
        let record = record
        record["Name"] = Name
        record["GameType"] = GameType
        record["minScore"] = minScore
        record["maxScore"] = maxScore
        return Board(record: record)
    }

    static func example1() -> Board {
        return Board(Name: "Euchre", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 10, myID: 1)!
    }
    static func example2() -> Board {
        return Board(Name: "Cribbage", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 121, myID: 2)!
    }
}
