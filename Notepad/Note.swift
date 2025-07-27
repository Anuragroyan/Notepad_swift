//
//  Note.swift
//  Notepad
//
//  Created by Dungeon_master on 18/07/25.
//

import Foundation
import FirebaseFirestoreSwift

struct Note: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var content: String
    var colorHex: String
    var tags: [String]
    var timestamp: Date
}
