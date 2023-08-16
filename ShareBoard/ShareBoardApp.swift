//
//  ShareBoardApp.swift
//  ShareBoard
//
//  Created by Jefry Gunawan on 10/08/23.
//

import SwiftUI

@main
struct ShareBoardApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var multipeerConn: MultipeerViewModel = MultipeerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(multipeerConn)
        }
    }
}
