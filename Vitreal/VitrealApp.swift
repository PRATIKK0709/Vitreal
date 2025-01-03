//
//  VitrealApp.swift
//  Vitreal
//
//  Created by Pratik Ray on 03/01/25.
//

//import SwiftUI
//

import SwiftUI

@main
struct ScreenshotUtilityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
    
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
        if let window = NSApplication.shared.windows.first {
            window.backgroundColor = .white
            window.isMovableByWindowBackground = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.level = .normal
            window.hasShadow = true
            window.isOpaque = true
            
            if !hasScreenCapturePermission() {
                requestScreenCapturePermission()
            }
        }
    }
}
