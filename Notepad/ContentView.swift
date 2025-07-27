//
//  ContentView.swift
//  Notepad
//
//  Created by Dungeon_master on 18/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firestore = FirestoreService()
    @State private var searchText = ""
    @State private var showingEditor = false
    @State private var selectedNote: Note?

    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return firestore.notes
        } else {
            return firestore.notes.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.tags.contains(where: { $0.lowercased().contains(searchText.lowercased()) })
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)

                if filteredNotes.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No notes found")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredNotes) { note in
                            HStack(alignment: .top) {
                                NoteCardView(note: note)
                                    .onTapGesture {
                                        selectedNote = note
                                        showingEditor = true
                                    }

                                Spacer()

                                Button(action: {
                                    firestore.deleteNote(note)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(Color(.systemGray5))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let noteToDelete = filteredNotes[index]
                                firestore.deleteNote(noteToDelete)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("📝 Notepad")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedNote = nil
                        showingEditor = true
                    } label: {
                        Label("New Note", systemImage: "plus.circle.fill")
                            .labelStyle(IconOnlyLabelStyle())
                            .font(.title2)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingEditor) {
                NoteEditor(note: selectedNote) { note in
                    if let _ = note.id {
                        firestore.updateNote(note)
                    } else {
                        firestore.addNote(note)
                    }
                    showingEditor = false
                }
            }
            .onAppear {
                firestore.fetchNotes()
            }
        }
    }
}


struct NoteCardView: View {
    var note: Note

    var body: some View {
        let tagViews = note.tags.map { tag in
            Text("#\(tag)")
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: note.colorHex).opacity(0.85))
                .cornerRadius(10)
                .foregroundColor(.primary)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            if !tagViews.isEmpty {
                HStack(spacing: 4) {
                    ForEach(0..<tagViews.count, id: \.self) { index in
                        tagViews[index]
                    }
                }
            }

            Text(formattedDate(note.timestamp))
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: note.colorHex).opacity(0.3),
                            Color(hex: note.colorHex).opacity(0.85)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // e.g., Jul 18, 2025
        formatter.timeStyle = .short  // e.g., 9:42 PM
        return formatter.string(from: date)
    }
}



struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search notes or tags", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(.thinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}


extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        // Remove the "#" prefix if present
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        // Default to gray if not a valid 6-digit hex
        guard hexString.count == 6,
              let rgbValue = UInt64(hexString, radix: 16) else {
            self = Color.gray
            return
        }

        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}


#Preview {
    ContentView()
}
