//
//  csvFileHandling.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2023-12-01.
//

import Foundation
import SwiftUI
import CloudKit

protocol CSVLoadable {
    init?(raw: [String])
    var fieldNames: [String] { get }
    var csvHeadingLine: String { get }
    var record: CKRecord { get }
}

extension CSVLoadable {
    func csvfileURL<T: CSVLoadable>(from recArray: [T], outFile: String = "Output.csv") -> URL? {

        Player.createCSV(from: recArray, outFile: outFile)
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let myURL = path.appendingPathComponent(outFile)
            return myURL
        } catch {
            print("error creating file")
            return nil
        }
    }

//
//
//    static func createCSVBoard(from recArray: [Board], outFile: String = "Boards.csv") {
//       // header row
//        var csvString = Board.example1().csvHeadingLine  //Board.csvHeadingLine
//       for board  in recArray {
//           csvString = csvString.appending("\(board.Name),\(board.GameType),\(board.minScore),\(board.maxScore),\(board.myID)\n")
//       }
//
//       let fileManager = FileManager.default
//       do {
//           let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
//           let fileURL = path.appendingPathComponent(outFile)
//           try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
//       } catch {
//           print("error creating file")
//       }
//
//   }
    static func createCSV<T: CSVLoadable>(from recArray: [T], outFile: String = "Output.csv") {
       // header row
        var csvString = ""
       for record  in recArray {
           if csvString.isEmpty {
               csvString.append(record.csvHeadingLine)
           }
           var aLine = ""
           for name in record.fieldNames {
               if let value = record.record.value(forKey: name) {
                   let stringValue = String(describing: value)
                   if !aLine.isEmpty {
                       aLine.append(",")
                   }
                   aLine.append(stringValue)
               }
           }
           csvString.append(aLine)
           csvString.append("\n")
       }

       let fileManager = FileManager.default
       do {
           let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
           let fileURL = path.appendingPathComponent(outFile)
           try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
       } catch {
           print("error creating file")
       }

   }
//    static func createCSVGame(from recArray: [Game], outFile: String = "Games.csv") {
//       // header row
//        var csvString = Game.example1().csvHeadingLine
//       for game  in recArray {
//           csvString = csvString.appending("\(game.BoardID),\(game.Board),\(game.DatePlayed),\(game.WinnerID),\(game.Player1ID),\(game.Score1),\(game.Player2ID),\(game.Score2),\(game.myID)\n")
//       }
//
//       let fileManager = FileManager.default
//       do {
//           let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
//           let fileURL = path.appendingPathComponent(outFile)
//           try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
//       } catch {
//           print("error creating file")
//       }
//
//   }

    static func dataToStructGeneric<T: CSVLoadable>(data: String) -> [T] {
        var csvToStruct = [T]()
        var rows = data.components(separatedBy: "\n")
        let columnCount = rows.first?.components(separatedBy: ",").count
        rows.removeFirst()
        for row in rows {
            let csvColumns = row.components(separatedBy: ",")
            if csvColumns.count == columnCount {
                let genericStruct = T.init(raw: csvColumns)
                csvToStruct.append(genericStruct!)
            }
        }
        return csvToStruct
    }
}


