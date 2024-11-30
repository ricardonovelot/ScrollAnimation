//
//  ContentView.swift
//  ScrollAnimation
//
//  Created by Ricardo on 29/11/24.
//

import SwiftUI

    struct Number: Identifiable {
        let id = UUID() // Unique identifier for each number
        let value: Int  // The actual number
    }

    struct ContentView: View {
        @State private var text = "Hello"
        @State private var position = ScrollPosition()
        @State private var isBeyondZero: Bool = false
        @FocusState private var fieldIsFocused: Bool

        var numbers: [Number]

        init() {
            numbers = Array(1...100).map { Number(value: $0) }
        }

        var body: some View {
            NavigationStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(numbers) { number in
                                HStack {
                                    Text("\(number.value)") // Access the `value` property
                                    Spacer()
                                }
                                .padding(.leading)
                                .background(.red)
                                .id(number.id)
                            }
                        }
                    }
                    .onScrollGeometryChange(for: Bool.self) { geometry in
                        return geometry.contentSize.height < geometry.visibleRect.maxY - geometry.contentInsets.bottom - 55
                    } action: { wasBeyondZero, isBeyondZero in
                        // Handle the action asynchronously after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.isBeyondZero = isBeyondZero
                            fieldIsFocused = true
                            print(isBeyondZero)
                        }
                    }
                    .navigationTitle(text.isEmpty ? "Test" : text)
                    .onChange(of: fieldIsFocused) { newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Adjust delay as needed
                            if let lastId = numbers.last?.id {
                                withAnimation(.snappy){
                                    proxy.scrollTo(lastId, anchor: .bottom) // Scroll to the last number
                                }
                            }
                        }
                    }
                }
            
            .safeAreaInset(edge: .bottom) {
                VStack{
                    Button("Hide Keyboard") {
                        fieldIsFocused = false
                    }
                    
                    TextField("", text: $text, axis: .vertical)
                        .padding(.horizontal,16)
                        .padding(.vertical,8)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onChange(of: text){ oldValue, newValue in
                            if let last = newValue.last, last == "\n" {
                                text.removeLast()
                                // do your submit logic here?
                                // saveContacts(modelContext: modelContext)
                            } else {
                                //parseContacts()
                            }
                            
                            
                        }
                        .focused($fieldIsFocused)
                        
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
