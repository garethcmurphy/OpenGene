import SwiftUI
import Foundation

// MARK: - Models
struct GeneSummaryResponse: Decodable {
    let GeneSummaries: GeneSummaries
}

struct GeneSummaries: Decodable {
    let GeneSummary: [Gene]
}

struct Gene: Decodable, Identifiable {
    var id: Int { GeneID }
    let GeneID: Int
    let Symbol: String
    let Name: String
    let TaxonomyID: Int
    let Taxonomy: String
    let Description: String
    let Synonym: [String]
}

// MARK: - Fetcher
class GeneFetcher: ObservableObject {
    @Published var genes: [Gene] = []

    func fetchGenes() {
        guard let url = URL(string: "https://pubchem.ncbi.nlm.nih.gov/rest/pug/gene/geneid/1956,13649/summary/JSON") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(GeneSummaryResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.genes = decodedResponse.GeneSummaries.GeneSummary
                    }
                } catch {
                    print("Decoding failed: \(error)")
                }
            }
        }.resume()
    }
}

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var fetcher = GeneFetcher()

    var body: some View {
        NavigationView {
            List(fetcher.genes) { gene in
                VStack(alignment: .leading) {
                    Text("🧬 \(gene.Symbol) - \(gene.Name)")
                        .font(.headline)
                    Text("Taxonomy: \(gene.Taxonomy)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(gene.Description)
                        .font(.body)
                        .lineLimit(4)
                    Text("Synonyms: \(gene.Synonym.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                .padding(.vertical)
            }
            .navigationTitle("🔬 Gene Summaries 🧫")
            .onAppear {
                fetcher.fetchGenes()
            }
            .toolbar{
            
        // 3 button menu at bottom
        
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        fetcher.fetchGenes()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    Spacer()
                    Button {
                        fetcher.genes.removeAll()
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    Spacer()
                    
                }
            }
            }
            
            
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

