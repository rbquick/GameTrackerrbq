//
//  GameRec.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-27.
//

import CloudKit

struct Game: Identifiable, CloudKitableProtocol, CSVLoadable {

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

    init?(raw: [String]) {
        BoardID = Int64(raw[0]) ?? Int64(99.9)
        Board = raw[1]
        DatePlayed = myDateFormatter(inDate: raw[2])
        WinnerID = Int64(raw[3]) ?? Int64(99.9)
        Player1ID = Int64(raw[4]) ?? Int64(99.9)
        Score1 = Double(raw[5]) ?? Double(99.9)
        Player2ID = Int64(raw[6]) ?? Int64(99.9)
        Score2 = Double(raw[7]) ?? Double(99.9)
        myID = Int64(raw[8]) ?? Int64(99.9)
        record = CKRecord(recordType: myRecordType.Game.rawValue)
        id = record.recordID
    }
    init?(record: CKRecord) {
        self.id = record.recordID
        self.BoardID = record[StructNames.BoardID.rawValue] as? Int64 ?? 0
        self.Board = record[StructNames.Board.rawValue] as? String ?? ""
        self.DatePlayed = record[StructNames.DatePlayed.rawValue] as? Date ?? Date()
        self.WinnerID = record[StructNames.WinnerID.rawValue] as? Int64 ?? 0
        self.Player1ID = record[StructNames.Player1ID.rawValue] as? Int64 ?? 0
        self.Score1 = record[StructNames.Score1.rawValue] as? Double ?? 0
        self.Player2ID = record[StructNames.Player2ID.rawValue] as? Int64 ?? 0
        self.Score2 = record[StructNames.Score2.rawValue] as? Double ?? 0
        self.myID = record[StructNames.myID.rawValue] as? Int64 ?? 0
        self.record = record
    }
    init?(BoardID: Int64, Board: String, DatePlayed: Date, WinnerID: Int64, Player1ID: Int64, Score1: Double, Player2ID: Int64, Score2: Double, myID: Int64) {
        let record = CKRecord(recordType: myRecordType.Game.rawValue)
        record[StructNames.BoardID.rawValue] = BoardID
        record[StructNames.Board.rawValue] = Board
        record[StructNames.DatePlayed.rawValue] = DatePlayed
        record[StructNames.WinnerID.rawValue] = WinnerID
        record[StructNames.Player1ID.rawValue] = Player1ID
        record[StructNames.Score1.rawValue] = Score1
        record[StructNames.Player2ID.rawValue] = Player2ID
        record[StructNames.Score2.rawValue] = Score2
        record[StructNames.myID.rawValue] = myID
        self.init(record: record)
    }
    enum StructNames: String, CaseIterable {
        case BoardID = "BoardID"
        case Board = "Board"
        case DatePlayed = "DatePlayed"
        case WinnerID = "WinnerID"
        case Player1ID = "Player1ID"
        case Score1 = "Score1"
        case Player2ID = "Player2ID"
        case Score2 = "Score2"
        case myID = "myID"
    }
    let fieldNames = StructNames.allCases.map { $0.rawValue }
    var csvHeadingLine:String {
        return csvHeading(for: StructNames.self)
    }

    func update(BoardID: Int64, Board: String, DatePlayed: Date, WinnerID: Int64, Player1ID: Int64, Score1: Double, Player2ID: Int64, Score2: Double) -> Game? {
        let record = record
        record[StructNames.BoardID.rawValue] = BoardID
        record[StructNames.Board.rawValue] = Board
        record[StructNames.DatePlayed.rawValue] = DatePlayed
        record[StructNames.WinnerID.rawValue] = WinnerID
        record[StructNames.Player1ID.rawValue] = Player1ID
        record[StructNames.Score1.rawValue] = Score1
        record[StructNames.Player2ID.rawValue] = Player2ID
        record[StructNames.Score2.rawValue] = Score2
        return Game(record: record)
    }

    static func example1() -> Game {
        return Game(BoardID: 1, Board: "Euchre", DatePlayed: Date(), WinnerID: 1, Player1ID: 1, Score1: 10, Player2ID: 2, Score2: 1, myID: 1)!
    }
    static func example2() -> Game {
        return Game(BoardID: 1, Board: "Euchre", DatePlayed: Date(), WinnerID: 1, Player1ID: 2, Score1: 10, Player2ID: 1, Score2: 2, myID: 2)!
    }
    static func NoGames() -> Game {
        return Game(BoardID: 1, Board: "NoGames", DatePlayed: Date(), WinnerID: 1, Player1ID: 2, Score1: 10, Player2ID: 1, Score2: 2, myID: 2)!
    }
}
