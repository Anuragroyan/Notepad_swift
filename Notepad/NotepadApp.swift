//
//  NotepadApp.swift
//  Notepad
//
//  Created by Dungeon_master on 18/07/25.
//

import SwiftUI
import Firebase

@main
struct NotepadApp: App {
    init() {
           FirebaseApp.configure()
       }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
