//
//  boardMessage.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2024-07-30.
//


import Foundation
import CloudKit

struct BoardMessage: Identifiable, CloudKitableProtocol, CSVLoadable {

    let id: CKRecord.ID
    let boardName: String
    let score: Double
    let relation: String
    let msgtext: String
    let record: CKRecord
    
    enum StructNames: String, CaseIterable {
        case boardName = "boardName"
        case score = "score"
        case relation = "relation"
        case msgtext = "msgtext"
    }

    init?(raw: [String]) {
        boardName = raw[0]
        score = Double(raw[1]) ?? 99.9
        relation = raw[2]
        msgtext = raw[3]
        record = CKRecord(recordType: myRecordType.BoardMessage.rawValue)
        id = record.recordID
    }
    init?(record: CKRecord) {
        self.id = record.recordID
        self.boardName = record[StructNames.boardName.rawValue] as? String ?? "Euchre"
        self.score = record[StructNames.score.rawValue] as? Double ?? 0
        self.relation = record[StructNames.relation.rawValue] as? String ?? "<="
        self.msgtext = record[StructNames.msgtext.rawValue] as? String ?? "Skunked"
        self.record = record
    }

    init?(boardName: String, score: Double, relation: String, msgtext: String) {
        let record = CKRecord(recordType: myRecordType.BoardMessage.rawValue)
        record[StructNames.boardName.rawValue] = boardName
        record[StructNames.score.rawValue] = score
        record[StructNames.relation.rawValue] = relation
        record[StructNames.msgtext.rawValue] = msgtext
        self.init(record: record)
    }
    

    let fieldNames = StructNames.allCases.map { $0.rawValue }
    var csvHeadingLine: String {
        return csvHeading(for: StructNames.self)
    }
    
    func update(boardName: String, score: Double, relation: String, msgtext: String) -> BoardMessage? {
        let record = record
        record[StructNames.boardName.rawValue] = boardName
        record[StructNames.score.rawValue] = score
        record[StructNames.relation.rawValue] = relation
        record[StructNames.msgtext.rawValue] = msgtext
        return BoardMessage(record: record)
    }

    static func example1() -> BoardMessage {
        return BoardMessage(boardName: "Euchre", score: 0, relation: "==", msgtext: "Skunked")!
    }
    static func example2() -> BoardMessage {
        return BoardMessage(boardName: "Cribbage", score: 90, relation: "<=", msgtext: "Skunked")!
    }
    static func example3() -> BoardMessage {
        return BoardMessage(boardName: "Cribbage", score: 60, relation: "<=", msgtext: "Double Skunked")!
    }
}


