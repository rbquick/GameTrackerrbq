//
//  AlphaList.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-30.
//

import SwiftUI

struct PlayersListView: View {
    @EnvironmentObject var players: Players
    @State var searchTerm = ""
    @State var myPlayer: Player = Player(Name: "xxxxxxx", myID: 1)!
    @State private var returnedMessage = ""

    var body: some View {
        //        NavigationView {
        VStack {
            HStack {
                SearchBar(searchTerm: $searchTerm)
                Text("current version  \(versionAndBuildNumber())")
                PopoverLink(destination:
                                PlayersMaintenanceView(myPlayer: Player(Name: "", myID: 0)!, PlayerEntryNewPlayer: true),
                            title: "New Player",
                            subtitle: "New Player"
                ) {
                    Text("\(Image(systemName: "plus.circle.fill")) Player")
                }.myButtonViewStyle(width:90)
            }
            ScrollView {
                ForEach(players.sectionDictionary.keys.sorted(), id:\.self) { key in
                    if let contacts = players.sectionDictionary[key]?.filter({ (contact) -> Bool in
                        self.searchTerm.isEmpty ? true :
                        "\(contact)".lowercased().contains(self.searchTerm.lowercased())}), !contacts.isEmpty
                    {
                        Section(header: SectionHeader(key: key).background(Color.red), footer: EmptyView()) {
                            ForEach(contacts){ value in
                                HStack(alignment: .center) {
                                    PopoverLink(destination:
                                                    PlayersMaintenanceView(myPlayer: players.findPlayersRecord(Name: value.Name), PlayerEntryNewPlayer: false),
                                                title: "Player Change",
                                                subtitle: "Player Change"
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
                players.fetchAll() { rtnMessage in
                    returnedMessage = rtnMessage
                    players.sectionDictionary = [:]
                    players.sectionDictionary = players.getSectionedDictionary()
                }
            }
        }
        //        }
    }
}
struct AlphaList_Previews: PreviewProvider {
    static var previews: some View {
        PlayersListView()
            .environmentObject(Players())
    }
}
extension PlayersListView {


}

