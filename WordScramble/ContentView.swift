//
//  ContentView.swift
//  WordScramble
//
//  Created by Jiaming Guo on 2022-07-28.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords: [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    func startGame() {
        // Find the url for start.txt in app bundle
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordURL) {
                // Split the string up into an array of strings
                let allWords = startWords.components(separatedBy: "\n")
                // Pick one random word
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        // validation
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You cannot spell that word from \(rootWord)")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You cannot just make them up, you know")
            return
        }
        guard isShort(word: answer) else {
            wordError(title: "Word too short", message: "Words are at least 3 characters")
            return
        }
        guard isSame(word: answer) else {
            wordError(title: "Word is identical", message: "You should come up with something new")
            return
        }
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        return word.sorted() == rootWord.sorted()
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isShort(word: String) -> Bool {
        return word.count > 3
    }
    
    func isSame(word: String) -> Bool {
        return word != rootWord
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text(rootWord)
                            .font(.largeTitle.bold())
                            .foregroundColor(.green)
                        Spacer()
                        Button(action: {
                            startGame()
                            usedWords = []
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        })
                    }
                    .padding(.vertical)
                }
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                } header: {
                    Text("Previous guesses")
                }
            }
            .navigationTitle("WordScramble")
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
