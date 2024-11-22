//
//  EMGApp.swift
//  EMG
//
//  Created by Cyril Zakka on 11/20/24.
//

import SwiftUI

@main
struct EMGApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
