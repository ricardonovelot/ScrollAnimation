//
//  ContentView.swift
//  ScrollAnimation
//
//  Created by Ricardo on 29/11/24.
//

import SwiftUI

    struct StringItem: Identifiable {
        let id = UUID()
        let value: String
    }

struct ContentView: View {
    @State private var text = "Hello"
    @State private var position = ScrollPosition()
    @State private var isBeyondZero: Bool = false
    @FocusState private var fieldIsFocused: Bool
    
    @State private var items: [StringItem]
    
    init() {
        _items = State(initialValue: Array(1...50).map { _ in StringItem(value: ContentView.randomString()) })
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(items) { number in
                            HStack {
                                Text("\(number.value)") // Access the `value` property
                                Spacer()
                            }
                            .padding(.leading)
                            .id(number.id)
                        }
                    }
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 5) // Lower minimumDistance for quicker response
                        .onChanged { value in
                            let verticalTranslation = value.translation.height
                            if verticalTranslation > 0 {
                                // Detecting downward swipe
                                //print("Swiping Down")
                                fieldIsFocused = false // Add your logic for swiping down here
                            } else if verticalTranslation < 0 && fieldIsFocused == false {
                                // Detecting upward swipe
                                //print("Swiping Up")
                                // swipe is calculated here now
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    if isBeyondZero {fieldIsFocused = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            if let lastId = items.last?.id {
                                                withAnimation(.easeIn){
                                                    proxy.scrollTo(lastId, anchor: .bottom)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                            // Optionally handle the end of the gesture if needed
                        }
                )
                .scrollPosition($position)
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    return geometry.contentSize.height < geometry.visibleRect.maxY - geometry.contentInsets.bottom - 55
                } action: { wasBeyondZero, isBeyondZero in
                    self.isBeyondZero = isBeyondZero
                    print(isBeyondZero)
                    //swipe was calculated here before
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        print(isBeyondZero)
//                        fieldIsFocused = true
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            if let lastId = items.last?.id {
//                                withAnimation(.snappy){
//                                    proxy.scrollTo(lastId, anchor: .bottom)
//                                }
//                            }
//                        }
//                    }
                }
                
                .navigationTitle(text.isEmpty ? "Test" : text)
            }
            
            .safeAreaInset(edge: .bottom) {
                VStack{
                    TextField("", text: $text, axis: .vertical)
                        .focused($fieldIsFocused)
                        .padding(.horizontal,16)
                        .padding(.vertical,8)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .onChange(of: text){ oldValue, newValue in
//                            if let last = newValue.last, last == "\n" {
//                                text.removeLast()
//                                // do your submit logic here?
//                                // saveContacts(modelContext: modelContext)
//                            } else {
//                                //parseContacts()
//                            }
//                        }
                        .padding(.bottom)
                        .padding(.horizontal)
                        //.submitLabel(.send)
//                        .onSubmit {
//                            let newItem = StringItem(value: text)
//                            items.append(newItem)
//                            text = ""
//                            withAnimation(.snappy){
//                                //position.scrollTo(id: items.last?.id, anchor: .bottom)
//                            }
//                        }
                        .onChange(of: text) { newValue in
                            guard newValue.contains("\n") else { return }
                                text = newValue.replacing("\n", with: "")
                                let newItem = StringItem(value: text)
                                items.append(newItem)
                                text = ""
                                withAnimation(.snappy){
                                    position.scrollTo(id: items.last?.id, anchor: .bottom)
                                }
                            
                        }
                        
                    
                }
            }
        }
        
    }
    
    static func randomString(length: Int = 10) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).compactMap { _ in letters.randomElement() })
    }
}

#Preview {
    ContentView()
}
