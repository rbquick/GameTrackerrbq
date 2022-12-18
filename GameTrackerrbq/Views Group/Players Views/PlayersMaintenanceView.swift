//
//  PlayersMaintenanceView.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-11-29.
//

import SwiftUI
import AlertKit

struct PlayersMaintenanceView: View {

    @State var myPlayer: Player
    @State var PlayerEntryNewPlayer: Bool

    @State private var name: String = ""
    @EnvironmentObject var players: Players
    @Environment(\.presentationMode) var presentationMode
    @StateObject var alertManager = AlertManager()

    @State var returnedMessage = ""
    @State private var PlayerEntryShowing: Bool = false

    var body: some View {

        VStack {

            PlayerEntryFields
                .padding()

            Text(returnedMessage)

            PlayerEntrySelect

        }


    }
}

struct PlayersMaintenanceView_Previews: PreviewProvider {
    static var previews: some View {

            PlayersMaintenanceView(myPlayer: Player.example1(), PlayerEntryNewPlayer: false)
                .environmentObject(Players())

    }
}
extension PlayersMaintenanceView {

    private var PlayerEntryFields: some View {

        VStack(alignment: .leading) {
            Text("Player ID:\(myPlayer.myID)")
            myTextField(value: $name, title: "Player Name11", texttype: .String)
                .frame(width: 270, height: 25)
        }
        .onAppear() {
            restore(player: myPlayer)
            returnedMessage = "\(PlayerEntryNewPlayer ? "Entering New" : "Changing") Player"
            PlayerEntryShowing = true
        }

    }
    private var PlayerEntrySelect: some View {

        HStack {

            myButton(action: {
                delete()
            }, content: {
                Text("Delete")
            }).hiddenConditionally(PlayerEntryNewPlayer)

            myButton(action: {
                PlayerEntryNewPlayer = false
                PlayerEntryShowing.toggle()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }
            myButton(action: {
                if PlayerEntryNewPlayer {
                    add()
                } else {
                    change()
                    PlayerEntryNewPlayer = false
                    PlayerEntryShowing.toggle()
                    presentationMode.wrappedValue.dismiss()
                }

            }) {
                Text("Finish")
            }

        }.uses(alertManager)


    }

    func restore(player: Player) {
        name = player.Name
    }

    func add() {
        guard players.players.firstIndex(where: { name == $0.Name }) == nil else {
            alertManager.show(dismiss: .warning(title: "Player already exists"))
            return }
        players.add(Name: name) { rtnMessage in
            players.sectionDictionary = [:]
            players.sectionDictionary = players.getSectionedDictionary()
            returnedMessage = rtnMessage
            presentationMode.wrappedValue.dismiss()
        }
    }
    func change() {
        guard let changeRec = myPlayer.update(Name: name) else { return }
        myPlayer = changeRec
        players.change(player: changeRec) { rtnMessage in
            players.sectionDictionary = [:]
            players.sectionDictionary = players.getSectionedDictionary()
            returnedMessage = rtnMessage
        }
    }
    func delete() {
        alertManager.show(primarySecondary: .success(title: "Are you sure you want to delete this Player?",
                                                     message: "WARNING: not checking for entered games on this player!",
                                                     primaryButton: Alert.Button.destructive(Text("Delete"),
                                                                                             action: {
            players.delete(player: myPlayer) { rtnMessage in
                players.sectionDictionary = [:]
                players.sectionDictionary = players.getSectionedDictionary()
                returnedMessage = rtnMessage
                presentationMode.wrappedValue.dismiss()
            }
            }), secondaryButton: .cancel()))
        }
}
