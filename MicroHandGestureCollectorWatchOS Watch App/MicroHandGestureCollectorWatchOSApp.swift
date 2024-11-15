//
//  MicroHandGestureCollectorWatchOSApp.swift
//  MicroHandGestureCollectorWatchOS Watch App
//
//  Created by wayne on 2024/11/13.
//

import SwiftUI

@main
struct MicroHandGestureCollectorWatchOS_Watch_AppApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
