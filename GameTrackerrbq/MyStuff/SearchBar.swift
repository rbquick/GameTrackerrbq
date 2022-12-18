//
//  SearchBar.swift
//  GameTracker
//
//  Created by Brian Quick on 2022-12-03.
//

import SwiftUI


struct SearchBar : View {
    @Binding var searchTerm : String
    @FocusState private var searchIsFocused: Bool
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("search", text: self.$searchTerm)
                    .foregroundColor(.primary)
                    .focused($searchIsFocused)

                Button(action: {
                    self.searchTerm = ""
                }) {
                    Image(systemName: "xmark.circle.fill").opacity(self.searchTerm == "" ? 0 : 1)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)

            if self.searchIsFocused {
                Button("Cancel") {
                    self.searchTerm = ""
                    self.searchIsFocused = false
                }.myButtonViewStyle(width:90)
            }
        }
        .padding(.horizontal)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchTerm: .constant(""))
    }
}
