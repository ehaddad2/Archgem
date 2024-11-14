import Foundation
import SwiftUI
import MapKit

struct SearchSheet: View {
    @State private var locationSearch = LocationSearch(completer: .init())
    @State private var search: String = ""
    @Binding var searchResults: [SearchResult]?
    var onLocationSelected: (SearchResult) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName:"magnifyingglass")
                TextField("Search for Location or Gem", text: $search)
                    .onSubmit {
                        Task {
                            searchResults = (try await locationSearch.search(with: search))
                        }
                    }
            }.modifier(TextFieldBG())
            
            List {
                ForEach(locationSearch.completions) {
                    completion in
                    
                    Button(action:{
                        onLocationSelected(completion)
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.title)
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text(completion.subTitle)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        
        .onChange(of: search) {
            locationSearch.update(queryFragment: search)
        }
        .padding(12)
        .presentationDetents([.height(100), .medium])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .interactiveDismissDisabled()
        .presentationBackgroundInteraction(.enabled)
    }
}

struct TextFieldBG: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.gray.opacity(0.1))
            .presentationCornerRadius(20)
            .clipShape(.rect(cornerRadius: 20))
            .foregroundStyle(.primary)
            
    }
}
