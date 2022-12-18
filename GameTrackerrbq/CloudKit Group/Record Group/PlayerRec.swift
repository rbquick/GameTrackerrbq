//
//  PlayerRec.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-27.
//

//import Foundation
import CloudKit

struct Player: Identifiable, CloudKitableProtocol {
    let id: CKRecord.ID
    let Name: String
    let myID: Int64
    let record: CKRecord

    init?(record: CKRecord) {
        self.id = record.recordID
        self.Name = record["Name"] as? String ?? "Brian"
        self.myID = record["myID"] as? Int64 ?? 1
        self.record = record
    }
    init?(Name: String, myID: Int64) {
        let record = CKRecord(recordType: myRecordType.Player.rawValue)
        record["Name"] = Name
        record["myID"] = myID
        self.init(record: record)
    }

    func update(Name: String) -> Player? {
        let record = record
        record["Name"] = Name
        return Player(record: record)
    }
    static func example1() -> Player {
        return Player(Name: "Brian/123456789012345", myID: 1)!
    }
    static func example2() -> Player {
        return Player(Name: "Sandy/Lorna", myID: 2)!
    }
}
