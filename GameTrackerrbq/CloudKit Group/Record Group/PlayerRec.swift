//
//  PlayerRec.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-27.
//

//import Foundation
import CloudKit

struct Player: Identifiable, CloudKitableProtocol, CSVLoadable {

    let id: CKRecord.ID
    let Name: String
    let myID: Int64
    let record: CKRecord

    init?(raw: [String]) {
        Name = raw[0]
        myID = Int64(raw[1]) ?? Int64(99.9)
        record = CKRecord(recordType: myRecordType.Player.rawValue)
        id = record.recordID
    }
    init?(record: CKRecord) {
        self.id = record.recordID
        self.Name = record[StructNames.Name.rawValue] as? String ?? "Brian"
        self.myID = record[StructNames.myID.rawValue] as? Int64 ?? 1
        self.record = record
    }
    init?(Name: String, myID: Int64) {
        let record = CKRecord(recordType: myRecordType.Player.rawValue)
        record[StructNames.Name.rawValue] = Name
        record[StructNames.myID.rawValue] = myID
        self.init(record: record)
    }

    enum StructNames: String, CaseIterable {
        case Name = "Name"
        case myID = "myID"
    }
    let fieldNames = StructNames.allCases.map { $0.rawValue }
    var csvHeadingLine:String {
        return csvHeading(fieldNames: fieldNames)
    }


    func update(Name: String) -> Player? {
        let record = record
        record[StructNames.myID.rawValue] = Name
        return Player(record: record)
    }
    static func example1() -> Player {
        return Player(Name: "Brian/123456789012345", myID: 1)!
    }
    static func example2() -> Player {
        return Player(Name: "Sandy/Lorna", myID: 2)!
    }
}
