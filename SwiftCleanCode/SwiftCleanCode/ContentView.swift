//
//  ContentView.swift
//  SwiftCleanCode
//
//  Created by Afham on 04/08/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        UserListView(viewModel: DIContainer.shared.makeUserListViewModel())
    }
}

#Preview {
    ContentView()
}
