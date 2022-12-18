//
//  PopoverLink.swift
//  NavigationMacos
//
//  Created by Brian Quick on 2021-02-21.
//
/*
 Taken from the article here
 https://manuel.weiel.eu/category/swiftui/

 had to add the selective "stuff" for macOS
 */

import SwiftUI

struct PopoverLink<Label, Destination> : View where Label : View, Destination : View {
    @EnvironmentObject var sm: StateManager
#if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    private let destination: Destination
    private let label: Label
    private var isActive: Binding<Bool>?
    private var title: String = ""
    private var subtitle: String? = nil
    private var showBackButton: Bool = true
    @State private var internalIsActive = false
    // Create a complete control for everything
    public init(destination: Destination, title: String = "", subtitle: String? = nil, showBackButton: Bool = true,  @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.title = title
        self.subtitle = subtitle
        self.showBackButton = showBackButton
        self.label = label()
    }
    public init(destination: Destination, title: String = "", subtitle: String? = nil, showBackButton: Bool = true, isActive: Binding<Bool>,  @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.title = title
        self.subtitle = subtitle
        self.showBackButton = showBackButton
        self.isActive = isActive
        self.label = label()
    }
    /// Creates an instance that presents `destination`.
    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }
    /// Creates an instance that presents `destination` when active.
    public init(destination: Destination, isActive: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
        self.isActive = isActive
    }
    private func popoverButton() -> some View {
        Button {
            (isActive ?? _internalIsActive.projectedValue).wrappedValue = true
        } label: {
            label
        }.buttonStyle(StaticButtonStyle())
    }
    
    /// The content and behavior of the view.
    public var body: some View {
#if os(macOS)
        //  this works as I expect for the sheet since the fullScreenCover is not available on macOS
        //  need to do something with the size of the screen ... see the available stuff on the frame below
        popoverButton().sheet(isPresented: (isActive ?? _internalIsActive.projectedValue)) {
            ZStack {
                // This is the background for all views that are given control
                LinearGradient(gradient: sm.gradient, startPoint: .top, endPoint: .bottom)
                VStack {
                    PopoverBarView(isActive: $internalIsActive, title: title, subtitle: subtitle, showBackButton: showBackButton)
                    Spacer()
                    destination
                    Spacer()
                }
            }
//            .frame(width: MyDefaults().appDefaultWidth, height: MyDefaults().appDefaultHeight)
            .frame(width: sm.popoverLinkWidth, height: sm.popoverLinkHeight)
        }
#endif
#if !os(macOS)
        popoverButton()
            .fullScreenCover(isPresented: (isActive ?? _internalIsActive.projectedValue)) {
                ZStack {
                    LinearGradient(gradient: sm.gradient, startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        PopoverBarView(isActive: $internalIsActive, title: title, subtitle: subtitle, showBackButton: showBackButton)
                        Spacer()
                        destination
                        Spacer()
                    }
                }
            }
        /*
         This was the original code that would put up a popover or sheet depending on the orientation.
         I am doing the complete overlay with the fullScreenCover scenario so these are not required.
         Just leaving this here for future reference
         */
        //        if horizontalSizeClass == .compact {
        //            popoverButton().sheet(isPresented: (isActive ?? _internalIsActive.projectedValue)) {
        //                VStack {
        //                Button {
        //                    (isActive ?? _internalIsActive.projectedValue).wrappedValue = false
        //                } label: {
        //                    Text("Done")
        //                }
        //                .padding()
        //                    Spacer()
        //                destination
        //                    Spacer()
        //                }
        //                .frame(width: vm.availableWidth, height: vm.availableHeight)
        //            }
        //        } else {
        //            popoverButton().popover(isPresented: (isActive ?? _internalIsActive.projectedValue)) {
        //                VStack {
        //                Button {
        //                    (isActive ?? _internalIsActive.projectedValue).wrappedValue = false
        //                } label: {
        //                    Text("Done")
        //                }
        //                .padding()
        //                    Spacer()
        //                destination
        //                    Spacer()
        //                }
        //                .frame(width: vm.availableWidth, height: vm.availableHeight)
        //            }
        //        }
#endif
    }
}

struct PopoverLink_Preview: PreviewProvider {
    static var previews: some View {
        PopoverLink(destination: Text("Destination")) {
            Text("Click Me")
        }.myButtonViewStyle()
            .environmentObject(StateManager())

    }
}


