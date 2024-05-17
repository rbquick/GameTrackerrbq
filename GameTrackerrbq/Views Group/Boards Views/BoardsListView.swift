//
//  BoardsListView.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-12-02.
//


import SwiftUI

struct BoardsListView: View {
    @EnvironmentObject var boards: Boards
    @State var searchTerm = ""
    @State var myBoard: Board = Board(Name: "New", GameType: 1, minScore: 0, maxScore: 10, myID: 1)!
    @State private var returnedMessage = ""

    var body: some View {
        VStack {
            HStack {
                SearchBar(searchTerm: $searchTerm)
                PopoverLink(destination:
                                BoardsMaintenanceView(myBoard: myBoard, BoardEntryNewBoard: true),
                            title: "New Board",
                            subtitle: "New Board"
                ) {
                    Text("\(Image(systemName: "plus.circle.fill")) Board")
                }.myButtonViewStyle(width:90)
            }
            ScrollView {
                ForEach(boards.sectionDictionary.keys.sorted(), id:\.self) { key in
                    if let contacts = boards.sectionDictionary[key]?.filter({ (contact) -> Bool in
                        self.searchTerm.isEmpty ? true :
                        "\(contact)".lowercased().contains(self.searchTerm.lowercased())}), !contacts.isEmpty
                    {
                        Section(header: SectionHeader(key: key).background(Color.red), footer: EmptyView()) {
                            ForEach(contacts){ value in
                                HStack(alignment: .center) {
                                    PopoverLink(destination:
                                                    BoardsMaintenanceView(myBoard: boards.findBoardsRecord(Name: value.Name), BoardEntryNewBoard: false),
                                                title: "Board Change",
                                                subtitle: "Board Change"
                                    ) {
                                        Text("\(value.Name)")
                                        //.myButtonViewStyle()
                                    }.myButtonViewStyle()
                                }
                                //.listRowBackground(myGradientView())
                                //                                    Text("\(value.firstName) \(value.lastName) \(value.telephone)")
                            }.modifier(BackgroundGradientViewModifier())
                        }//.listSectionSeparator(.hidden, edges: .bottom)
                    }
                }
            }.refreshable {
                boards.fetchAll() { rtnMessage in
                    returnedMessage = rtnMessage
                    boards.sectionDictionary = [:]
                    boards.sectionDictionary = boards.getSectionedDictionary()
                }
            }
        }
    }
}
struct BoardsListView_Previews: PreviewProvider {
    static var previews: some View {
        BoardsListView()
            .environmentObject(Boards())
    }
}
extension BoardsListView {

}


