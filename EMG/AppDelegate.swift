//
//  AppDelegate.swift
//  EMG
//
//  Created by Cyril Zakka on 11/20/24.
//

import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @State private var powerMonitor = PowerMonitor()
    let statusItem = NSStatusBar.system.statusItem(withLength: 275)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menuBarView = MenuView()
            .environment(powerMonitor)
        let hostingView = NSHostingView(rootView: menuBarView)
        hostingView.frame.size = NSSize(width: 275, height: 25)
//        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        if let button = statusItem.button {
            button.addSubview(hostingView)
            button.target = self
        }
    }
}
