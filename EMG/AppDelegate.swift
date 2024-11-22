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
    
    @AppStorage("hideDock") private var hideDock: Bool = false
    @State private var powerMonitor = PowerMonitor()
    let statusItem = NSStatusBar.system.statusItem(withLength: 275)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(hideDock ? .accessory : .regular)
        let menuBarView = MenuView()
            .environment(powerMonitor)
        let hostingView = NSHostingView(rootView: menuBarView)
        hostingView.frame.size = NSSize(width: 275, height: 22)
        
        if let button = statusItem.button {
            button.addSubview(hostingView)
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            showMenu()
        } else {
//            showPanel()
        }
    }
    
    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: powerMonitor.isRunning ? "Stop monitoring" :"Start monitoring", action: #selector(togglePowerMonitor), keyEquivalent: "s"))
        
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openPreferencesWindow), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    // Sometimes we do things we aren't proud of.
    @objc private func openPreferencesWindow() {
        //        openSettings()
        let kAppMenuInternalIdentifier  = "app"
        let kSettingsLocalizedStringKey = "Settings\\U2026";
        if let internalItemAction = NSApp.mainMenu?.item(
            withInternalIdentifier: kAppMenuInternalIdentifier
        )?.submenu?.item(
            withLocalizedTitle: kSettingsLocalizedStringKey
        )?.internalItemAction {
            internalItemAction();
            return;
        }
    }
    
    @objc private func togglePowerMonitor() {
        if powerMonitor.isRunning {
            powerMonitor.stop()
        } else {
            powerMonitor.start()
        }
    }
}
