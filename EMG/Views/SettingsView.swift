//
//  SettingsView.swift
//  EMG
//
//  Created by Cyril Zakka on 11/21/24.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("hideDock") private var hideDock: Bool = false
    
    var body: some View {
        TabView {
            Tab("General", systemImage: "gearshape") {
                GeneralSettingsView()
            }

        }
        .frame(maxWidth: 500, maxHeight: .infinity)
        .onAppear {
            // Show dock icon when settings view is shown
            NSApp.setActivationPolicy(.regular)
        }
        .onDisappear {
            // For better UX experience, trigger hide dock after exiting Settings
            if hideDock {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
}

struct GeneralSettingsView: View {
    @AppStorage("hideDock") private var hideDock: Bool = false
    
    var body: some View {
        Form {
            Section(content: {
                Toggle(isOn: $hideDock) {
                    Text("Hide dock icon")
                }
            }, header: {
                Text("Appearance")
            })
        }
        .formStyle(.grouped)
        .onChange(of: hideDock) { oldValue, newValue in
            if newValue == false {
                NSApp.setActivationPolicy(.regular)
            }
        }
    }
}

#Preview {
    SettingsView()
}
