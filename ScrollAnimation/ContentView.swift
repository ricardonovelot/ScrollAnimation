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
    @State private var text = ""
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
                                Text("\(number.value)")
                                Spacer()
                            }
                            .padding(.leading)
                            .id(number.id)
                        }
                    }
                }
                .contentMargins(.vertical, 16)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            let verticalTranslation = value.translation.height
                            if verticalTranslation > 0 {
                                // Detecting downward swipe
                                fieldIsFocused = false
                            } else if verticalTranslation < 0 && fieldIsFocused == false {
                                // Detecting upward swipe
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
                )
                .scrollPosition($position)
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    return geometry.contentSize.height < geometry.visibleRect.maxY - geometry.contentInsets.bottom - 55
                } action: { wasBeyondZero, isBeyondZero in
                    self.isBeyondZero = isBeyondZero
                    print(isBeyondZero)
                }
                .navigationTitle("Keyboard on Drag")
            }
            
            .safeAreaInset(edge: .bottom) {
                VStack{
                    TextField("", text: $text, axis: .vertical)
                        .focused($fieldIsFocused)
                        .padding(.horizontal,16)
                        .padding(.vertical,8)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom)
                        .padding(.horizontal)
                        .onChange(of: text) { newValue in
                            guard newValue.contains("\n") else { return }
                            text = newValue.replacing("\n", with: "")
                            let newItem = StringItem(value: text)
                            items.append(newItem)
                            text = ""
                            withAnimation(.snappy){
                                position.scrollTo(id: items.last?.id, anchor: .bottom)
                            }
//                            if let last = newValue.last, last == "\n" {
//                                text.removeLast()
//                                // do your submit logic here?
//                                // saveContacts(modelContext: modelContext)
//                            } else {
//                                //parseContacts()
//                            }
                            
                        }
                    
                    
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
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
