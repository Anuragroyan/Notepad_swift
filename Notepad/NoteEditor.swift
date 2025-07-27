//
//  NoteEditor.swift
//  Notepad
//
//  Created by Dungeon_master on 18/07/25.
//

import SwiftUI

struct NoteEditor: View {
    @Environment(\.presentationMode) var presentationMode
    @State var note: Note
    var onSave: (Note) -> Void

    init(note: Note?, onSave: @escaping (Note) -> Void) {
        self._note = State(initialValue: note ?? Note(title: "", content: "", colorHex: "#FFD700", tags: [], timestamp: Date()))
        self.onSave = onSave
    }

    @State private var newTag = ""

    let colors = ["#FFD700", "#ADD8E6", "#90EE90", "#FFB6C1", "#D3D3D3"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $note.title)
                }

                Section(header: Text("Content")) {
                    TextEditor(text: $note.content)
                        .frame(height: 120)
                }

                Section(header: Text("Tags")) {
                    HStack {
                        TextField("Add tag", text: $newTag)
                        Button("Add") {
                            if !newTag.isEmpty && !note.tags.contains(newTag) {
                                note.tags.append(newTag)
                                newTag = ""
                            }
                        }
                    }
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(note.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .padding(4)
                                    .background(Color(hex: note.colorHex).opacity(0.2))
                                    .cornerRadius(6)
                                    .onTapGesture {
                                        note.tags.removeAll { $0 == tag }
                                    }
                            }
                        }
                    }
                }

                Section(header: Text("Color")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(colors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle().stroke(note.colorHex == hex ? Color.black : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        note.colorHex = hex
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Note")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        note.timestamp = Date()
                        onSave(note)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
