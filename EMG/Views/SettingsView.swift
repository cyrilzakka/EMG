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
    @AppStorage("samplingInterval") private var samplingInterval: Double = 1.0
    
    private let intervals = [0.5, 1.0, 2.0, 5.0]
    
    var body: some View {
        Form {
            Section(content: {
                Toggle(isOn: $hideDock) {
                    Text("Hide dock icon")
                }
                Picker("Sampling Interval", selection: $samplingInterval) {
                    ForEach(intervals, id: \.self) { interval in
                        Text("\(interval, specifier: "%.1f") seconds")
                            .tag(interval)
                    }
                }
            }, header: {
                Text("General")
            }, footer: {
                Text("Increasing the sampling interval will improve performance, but will also reduce the accuracy of the measuremenets.")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .foregroundColor(.secondary)
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
