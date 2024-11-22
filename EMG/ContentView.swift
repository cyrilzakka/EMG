//
//  ContentView.swift
//  EMG
//
//  Created by Cyril Zakka on 11/20/24.
//

import SwiftUI

struct ContentView: View {
    
//    @Environment(PowerMonitor.self) private var powerMonitor
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
//        .task {
//            powerMonitor.start()
//        }
    }
}

#Preview {
    ContentView()
}
