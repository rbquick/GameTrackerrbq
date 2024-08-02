//
//  BoardMessageMaintenanceView.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2024-07-30.
//

import SwiftUI
import AlertKit

struct BoardMessageMaintenanceView: View {
    @EnvironmentObject var bmm: BoardMessages
    @EnvironmentObject var boards: Boards
    @State var myMessage: BoardMessage
    @State var boardmessageNewEntry: Bool
    @State private var messageEntryShowing: Bool = false
    @State var boardname: String = ""
    @State private var scoreStr: String = ""
    @State private var score: Double = 0.0
    @State private var relation: String = ""
    @State private var msgtext: String = ""
    
    var pickerWidth = 260
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var alertManager = AlertManager()

    @State var returnedMessage = ""
    
    var body: some View {
        VStack {

            EntryFields
                .padding()

            Text(returnedMessage)

            EntrySelect

        }
    }
}

extension BoardMessageMaintenanceView {
    
    private var GameSelection: some View {
        
            Picker("", selection: $boards.board) {
                ForEach(boards.boards) { board in
                    Text("\(board.Name)").tag("\(board.myID)")
                }
            }
            .myButtonViewStyle(width: CGFloat(pickerWidth))
            .onChange(of: boards.board) { selection in
                let myBoard = boards.boards.first(where: {$0.myID == boards.boardID}) ?? Board(Name: "Unknown", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 0, myID: 1)!
                boardname = myBoard.Name
//                boardid = selection
            }
        
    }
    
    private var EntryFields: some View {
        VStack(alignment: .leading) {
            Text("boards.boardID: \(boards.boardID)")
//            myTextField(value: $boardname, title: "Board Name", texttype: .String)
//                .frame(width: 300, height: 25)
            GameSelection
            myTextField(value: $scoreStr, title: "Score", texttype: .Double)
                .frame(width: 300, height: 25)
            myTextField(value: $relation, title: "Relation", texttype: .String)
                .frame(width: 300, height: 25)
            myTextField(value: $msgtext, title: "Message", texttype: .String)
                .frame(width: 300, height: 25)
        }
        .onAppear() {
            restore(message: myMessage)
            returnedMessage = "\(boardmessageNewEntry  ? "Entering New" : "Changing") Message"
            messageEntryShowing = boardmessageNewEntry  ? true : false
        }
    }
    private var EntrySelect: some View {
        HStack {

            myButton(action: {
                delete()
            }, content: {
                Text("Delete")
            }).hiddenConditionally(messageEntryShowing)

            myButton(action: {
                boardmessageNewEntry = false
                messageEntryShowing.toggle()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }
            myButton(action: {
                if boardmessageNewEntry {
                    add()
                } else {
                    change()
                    boardmessageNewEntry = false
                    messageEntryShowing.toggle()
                    presentationMode.wrappedValue.dismiss()
                }

            }) {
                Text("Finish")
            }

        }.uses(alertManager)

    }
    
    func restore(message: BoardMessage) {
        boardname = message.boardName
        let myBoard = boards.boards.first(where: {$0.Name == message.boardName}) ?? Board(Name: "Unknown", GameType: gametype.twoPlayer.rawValue, minScore: 0, maxScore: 0, myID: 1)!
        boards.boardID = myBoard.myID
        score = message.score
        relation = message.relation
        msgtext = message.msgtext
        changeInt64ToSelections()
    }
    func changeSelectionsToInt64() {
        score = Double(scoreStr) ?? 901
    }
    func changeInt64ToSelections() {
        scoreStr = String(format: "%.0f", score)
    }
    
    func add() {
        guard bmm.messages.firstIndex(where: { boardname == $0.boardName && relation == $0.relation }) == nil else {
            alertManager.show(dismiss: .warning(title: "Message and relation already exists"))
            return
        }
        changeSelectionsToInt64()
        bmm.add(boardName: boardname, score: score, relation: relation, msgtext: msgtext) { rtnMessage in
            returnedMessage = rtnMessage
            presentationMode.wrappedValue.dismiss()
        }
    }
    func change() {
        changeSelectionsToInt64()
        guard let changeRec = myMessage.update(boardName: boardname, score: score, relation: relation, msgtext: msgtext) else { return }
        myMessage = changeRec
        bmm.change(boardmessage: changeRec) { rtnMessage in
            returnedMessage = rtnMessage
        }
    }
    func delete() {
        alertManager.show(primarySecondary: .success(title: "Are you sure you want to delete this Message?",
                                                     message: "WARNING: this action cannot be undone",
                                                     primaryButton: Alert.Button.destructive(Text("Delete"),
                                                                                             action: {
            bmm.delete(boardmessage: myMessage) { rtnMessage in
 
                returnedMessage = rtnMessage
                presentationMode.wrappedValue.dismiss()
            }
            }), secondaryButton: .cancel()))
        }
}
struct BoardMessageMaintenanceView_Previews: PreviewProvider {
    static var previews: some View {

        BoardMessageMaintenanceView(myMessage: BoardMessage.example1(), boardmessageNewEntry: false)
                .environmentObject(BoardMessages())
                .environmentObject(Boards())

    }
}
