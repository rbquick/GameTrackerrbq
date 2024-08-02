//
//  BoardMessageView.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2024-07-30.
//

import SwiftUI

struct BoardMessageView: View {
    @EnvironmentObject var bmm: BoardMessages
    @State var searchTerm = ""
    var body: some View {
        VStack {
            HStack {
                SearchBar(searchTerm: $searchTerm)

                PopoverLink(destination:
                                BoardMessageMaintenanceView(myMessage: BoardMessage.example1(), boardmessageNewEntry: true),
                            title: "New Message",
                            subtitle: "New Message"
                ) {
                    Text("\(Image(systemName: "plus.circle.fill")) Board")
                }.myButtonViewStyle(width:90)
            }
        }
        ScrollView {
            ForEach(bmm.messages.indices, id: \.self) { ind in
                HStack {
                    PopoverLink(destination:
                                    BoardMessageMaintenanceView(myMessage: bmm.messages[ind], boardmessageNewEntry: false),
                                                title: "New Message",
                                                subtitle: "New Message"
                    ) {
                        Text("\(bmm.messages[ind].boardName) \(bmm.messages[ind].relation) \(Int(bmm.messages[ind].score)) \(bmm.messages[ind].msgtext)")
                    }
                }
            }
        }
    }
}

struct BoardMessageView_Previews: PreviewProvider {
    static var previews: some View {

        BoardMessageView()
                .environmentObject(BoardMessages())

    }
}
extension BoardMessageView {
    func fetchall() {
        bmm.fetchAll { returned in
            print("fetchall \(returned)")
        }
    }
}
