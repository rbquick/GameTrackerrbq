//
//  MenuDriver.swift
//  icloudIOS
//
//  Created by Brian Quick on 2021-09-26.
//
// the statemanager.isLoading idea of the progress screen came from
// https://youtu.be/2Jk58S6FiZw

// distribution testflight
// youtube video explaining the process
//      https://youtu.be/DLvdZtTAJrE


import SwiftUI

struct MenuDriver: View {
    @EnvironmentObject var sm: StateManager
    @EnvironmentObject var players: Players
    @EnvironmentObject var boards: Boards
    @EnvironmentObject var bmm: BoardMessages
    @EnvironmentObject var games: Games
    // 2022-02-04 deleted?
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var userName: String = "UnKnown"
    @State private var threshold: CGFloat = MyDefaults().thresholdWidth
    @State private var width: CGFloat = 0
    @State private var height: CGFloat = 0
    @State private var returnedMessage = ""
    @State private var connectionMessage = "connectionMessage"
    @State var hasBeenStarted: Bool = false
    @State var isShowingLogin = false
    var body: some View {
        ZStack {
            LinearGradient(gradient: sm.gradient, startPoint: .top, endPoint: .bottom)
            VStack(spacing: 0) {
                PopoverBarView(isActive: .constant(true), title: "Game Tracker \(returnedMessage)", showBackButton: false)
                Text(sm.containerEnvironment)
                if !sm.isLoading {
                    VStack {
                        switch sm.openingTabNumber {
                        case 1:
                            GameEntryView().tabItem { Text("New Game") }.tag(1)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .modifier(BackgroundGradientViewModifier())

                        case 2:
                            PlayersGamesView().tabItem  { Text("Reporting") }.tag(2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .modifier(BackgroundGradientViewModifier())
                        case 3:
                            // MaintenanceView

                            MaintenanceView().tabItem  { Text("Maintenance") }.tag(3)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .modifier(BackgroundGradientViewModifier())
                        case 4:
                            csvExportImport()
                        default:
                            LoginView()
                        }


                    }
                }

            Spacer()
            HStack {
                Spacer()
                Text("New Game")
                    .onTapGesture {
                        sm.openingTabNumber = 1
                        MyDefaults().openingTabNumber = 1
                    }
                Spacer()
                Text("Reporting")
                    .onTapGesture {
                        sm.openingTabNumber = 2
                        MyDefaults().openingTabNumber = 2
                    }
                Spacer()
                Text("Maintenance")
                    .onTapGesture {
                        sm.openingTabNumber = 3
                        MyDefaults().openingTabNumber = 3
                    }
                Spacer()
            }
            .modifier(BackgroundGradientViewModifier())
            .hidden(sm.openingTabNumber == 0)
        }
#if !os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
#if os(macOS)
      //  .frame(width: 800, height: 800)
#endif
            if games.rubbersPlayer1Today > 0 || games.rubbersPlayer2Today > 0 {
                FireworkParticlesContentView()
            }
            if games.boardmessagemsgtext != "" {
                TextSpinner(msgText: $games.boardmessagemsgtext, visibleDuration: 5)
            }
                
            if sm.isLoading  {

                        ProgressView("Connecting")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(3)

            }
//            if userName == "UnKnown" {
//                LoginView()
//            }
        }
        .readSize { size in
            sm.popoverLinkWidth = size.width
            sm.popoverLinkHeight = size.height
        }
        .onAppear() {
            //isShowingLogin = statemanager.openingTabNumber > 2
            getInitialData()
        }
    }
}
extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
// Previews OK
struct MenuDriver_Previews: PreviewProvider {
    static var previews: some View {
        MenuDriver()
            .environmentObject(StateManager())
            .environmentObject(Players())
            .environmentObject(Boards())
            .environmentObject(Games())
            .environmentObject(BoardMessages())
    }
}
extension MenuDriver {

    func getInitialData() {
        if !hasBeenStarted {
            Logger.log("Startup ~+~+~+~+~+~+~+~+~")
//            myenvironment.myenvironmentsGet() { msg in
//                statemanager.containerEnvironment = myenvironment.myenvironments[0].myenvironment
//            }

            sm.isLoading = true
            bmm.fetchAll { rtnMessage in
                returnedMessage = rtnMessage
            }
            players.fetchAll() { rtnMessage in
                returnedMessage = rtnMessage
                players.sectionDictionary = [:]
                players.sectionDictionary = players.getSectionedDictionary()

                boards.fetchAll() { rtnMessage in
                    returnedMessage = rtnMessage
                    boards.sectionDictionary = [:]
                    boards.sectionDictionary = boards.getSectionedDictionary()
                    games.fetchSelective(board: MyDefaults().BoardID, player1ID: MyDefaults().Player1ID, player2ID: MyDefaults().Player2ID) {
                        rtnMessage in
                        returnedMessage = rtnMessage
                        games.sectionDictionary = [:]
                        games.sectionDictionary = games.getSectionedDictionary()
                        sm.isLoading = false
                    }
                }
            }
            hasBeenStarted.toggle()
            // TODO this is not yet turned off somewhere else
        }
    }
}

