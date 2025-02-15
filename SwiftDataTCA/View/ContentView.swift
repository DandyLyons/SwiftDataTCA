//
//  TCAContentView.swift
//  SwiftDataTCA
//
//  Created by Rodrigo Souza on 03/10/23.
//

import SwiftUI
import ComposableArchitecture
import SwiftData
import Dependencies

struct TCAContentView: View {
    let store: StoreOf<Feature>
    
    var body: some View {
        WithViewStore(store, observe: \.movies) { viewStore in
            NavigationStack {
                List(viewStore.state) { movie in
                    VStack(alignment: .leading) {
                        Text(movie.id.uuidString)
                        
                        Text(movie.title)
                            .font(.headline)
                        
                        Text(movie.cast.formatted(.list(type: .and)))
                    }
                    .background(movie.favorite ? .blue : .clear)
                    .onTapGesture {
                        store.send(.delete(movie), animation: .snappy)
                    }
                    .onLongPressGesture {
                        store.send(.favorite(movie), animation: .bouncy)
                    }
                }
                .navigationTitle("SwiftData")
                .toolbar {
                    Button("Add Sample") {
                        store.send(.add)
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

extension TCAContentView {
    struct Feature: Reducer {
        struct State: Equatable {
            var movies: [Movie] = []
        }
        
        enum Action: Equatable {
            case onAppear
            case add
            case delete(Movie)
            case favorite(Movie)
        }
        
        @Dependency(\.swiftData) var context
        
        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .onAppear:
                    do {
                        state.movies = try context.fetch()
                    } catch {
                        
                    }
                    
                    return .none
                case .add:
                    do {
                        try context.add(.init(title: "Lord of The Rings", cast: ["Sam Worthington", "Zoe Saldaña", "Stephen Lang", "Michelle Rodriguez"]))
                    } catch {
                        
                    }
                    
                    return .run { @MainActor send in
                        send(.onAppear, animation: .default)
                    }
                case .delete(let movie):
                    do {
                        try context.delete(movie)
                    } catch {
                        
                    }
                    
                    return .run { @MainActor send in
                        send(.onAppear, animation: .default)
                    }
                case .favorite(let movie):
                    movie.favorite.toggle()
                    
                    return .none
                }
            }
        }
    }
}
