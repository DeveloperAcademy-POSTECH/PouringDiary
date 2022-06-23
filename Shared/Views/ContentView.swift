//
//  ContentView.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello World")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modifier(AppEnvironment(inMemory: true))
    }
}
