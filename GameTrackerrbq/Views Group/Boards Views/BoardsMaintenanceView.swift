//
//  BoardsMaintenanceView.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-12-02.
//



import SwiftUI
import AlertKit

struct BoardsMaintenanceView: View {

    @State var myBoard: Board
    @State var BoardEntryNewBoard: Bool

    @State private var name: String = ""
    @State private var GameTypeStr: String = ""
    @State private var GameType: Int64 = 0
    @State private var minScoreStr: String = ""
    @State private var minScore: Double = 0
    @State private var maxScoreStr: String = ""
    @State private var maxScore: Double = 0



    @EnvironmentObject var boards: Boards
    @Environment(\.presentationMode) var presentationMode
    @StateObject var alertManager = AlertManager()

    @State var returnedMessage = ""
    @State private var BoardEntryShowing: Bool = false

    var body: some View {

        VStack {

            EntryFields
                .padding()

            Text(returnedMessage)

            EntrySelect

        }


    }
}

struct BoardsMaintenanceView_Previews: PreviewProvider {
    static var previews: some View {

        BoardsMaintenanceView(myBoard: Board.example1(), BoardEntryNewBoard: false)
                .environmentObject(Boards())

    }
}
extension BoardsMaintenanceView {

    private var EntryFields: some View {

        VStack(alignment: .leading) {
            Text("BoardID:\(myBoard.myID)")
            myTextField(value: $name, title: "Board Name", texttype: .String)
                .frame(width: 300, height: 25)
            myTextField(value: $GameTypeStr, title: "Game Type", texttype: .Int)
                .frame(width: 300, height: 25)
            myTextField(value: $minScoreStr, title: "Min Score", texttype: .Double)
                .frame(width: 300, height: 25)
            myTextField(value: $maxScoreStr, title: "Max Score", texttype: .Double)
                .frame(width: 300, height: 25)
        }
        .onAppear() {
            restore(board: myBoard)
            returnedMessage = "\(BoardEntryNewBoard ? "Entering New" : "Changing") Board"
            BoardEntryShowing = true
        }

    }
    private var EntrySelect: some View {

        HStack {

            myButton(action: {
                delete()
            }, content: {
                Text("Delete")
            }).hiddenConditionally(BoardEntryNewBoard)

            myButton(action: {
                BoardEntryNewBoard = false
                BoardEntryShowing.toggle()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }
            myButton(action: {
                if BoardEntryNewBoard {
                    add()
                } else {
                    change()
                    BoardEntryNewBoard = false
                    BoardEntryShowing.toggle()
                    presentationMode.wrappedValue.dismiss()
                }

            }) {
                Text("Finish")
            }

        }.uses(alertManager)


    }

    func restore(board: Board) {
        name = board.Name
        GameType = board.GameType
        minScore = board.minScore
        maxScore = board.maxScore
        changeInt64ToSelections()
    }
    func changeSelectionsToInt64() {
        GameType = Int64(GameTypeStr) ?? 901
        minScore = Double(minScoreStr) ?? 902
        maxScore = Double(maxScoreStr) ?? 901
    }
    func changeInt64ToSelections() {
        GameTypeStr = String(GameType)
        minScoreStr = String(format: "%.0f", minScore)
        maxScoreStr = String(format: "%.0f", maxScore)
    }
    func add() {
        guard boards.boards.firstIndex(where: { name == $0.Name }) == nil else {
            alertManager.show(dismiss: .warning(title: "Board already exists"))
            return }
        changeSelectionsToInt64()
        boards.add(Name: name, GameType: GameType, minScore: minScore, maxScore: maxScore) { rtnMessage in
            boards.sectionDictionary = [:]
            boards.sectionDictionary = boards.getSectionedDictionary()
            returnedMessage = rtnMessage
            presentationMode.wrappedValue.dismiss()
        }
    }
    func change() {
        changeSelectionsToInt64()
        guard let changeRec = myBoard.update(Name: name, Gametype: GameType, minScore: minScore, maxScore: maxScore) else { return }
        myBoard = changeRec
        boards.change(board: changeRec) { rtnMessage in
            boards.sectionDictionary = [:]
            boards.sectionDictionary = boards.getSectionedDictionary()
            returnedMessage = rtnMessage
        }
    }
    func delete() {
        alertManager.show(primarySecondary: .success(title: "Are you sure you want to delete this Board?",
                                                     message: "WARNING: not checking for entered games on this board!",
                                                     primaryButton: Alert.Button.destructive(Text("Delete"),
                                                                                             action: {
            boards.delete(board: myBoard) { rtnMessage in
                boards.sectionDictionary = [:]
                boards.sectionDictionary = boards.getSectionedDictionary()
                returnedMessage = rtnMessage
                presentationMode.wrappedValue.dismiss()
            }
            }), secondaryButton: .cancel()))
        }
}
