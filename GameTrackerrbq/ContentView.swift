//
//  ContentView.swift
//  GameTrackerrbq
//
//  Created by Brian Quick on 2022-12-16.
//

import SwiftUI

struct ContentView: View {
    @State private var test = "test"
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("\(testing(input: "hello"))")
        }
        .padding()
    }

    func testing(input: String) -> String {
        return input
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
