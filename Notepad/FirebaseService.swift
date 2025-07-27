//
//  FirebaseService.swift
//  Notepad
//
//  Created by Dungeon_master on 18/07/25.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    private let collection = "notes"

    @Published var notes: [Note] = []

    func fetchNotes() {
        db.collection(collection)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.notes = documents.compactMap { try? $0.data(as: Note.self) }
            }
    }

    func addNote(_ note: Note) {
        do {
            _ = try db.collection(collection).addDocument(from: note)
        } catch {
            print("Error adding note: \(error)")
        }
    }

    func updateNote(_ note: Note) {
        guard let id = note.id else { return }
        do {
            try db.collection(collection).document(id).setData(from: note)
        } catch {
            print("Error updating note: \(error)")
        }
    }

    func deleteNote(_ note: Note) {
        guard let id = note.id else { return }
        db.collection(collection).document(id).delete()
    }
}
