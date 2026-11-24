import Foundation

struct MediaItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let originalTitle: String
    let year: Int
    let kind: String
    let genres: [String]
    let synopsis: String
    let posterURL: URL?
    let playbackURL: URL? // Только URL потока, разрешённого для воспроизведения в этом приложении.
    let sourceName: String

    init(id: UUID = UUID(), title: String, originalTitle: String, year: Int, kind: String,
         genres: [String], synopsis: String, posterURL: URL? = nil,
         playbackURL: URL? = nil, sourceName: String = "Каталог") {
        self.id = id; self.title = title; self.originalTitle = originalTitle
        self.year = year; self.kind = kind; self.genres = genres
        self.synopsis = synopsis; self.posterURL = posterURL
        self.playbackURL = playbackURL; self.sourceName = sourceName
    }

    var searchableText: String {
        ([title, originalTitle, String(year), kind, sourceName] + genres).joined(separator: " ").lowercased()
    }
}

@MainActor final class CatalogStore: ObservableObject {
    @Published var items: [MediaItem] = [
        MediaItem(title: "Побег из Шоушенка", originalTitle: "The Shawshank Redemption", year: 1994,
                  kind: "Фильм", genres: ["Драма"], synopsis: "История надежды и дружбы в тюрьме."),
        MediaItem(title: "Начало", originalTitle: "Inception", year: 2010,
                  kind: "Фильм", genres: ["Фантастика", "Триллер"], synopsis: "Сложная история о проникновении в сны."),
        MediaItem(title: "Тёмный рыцарь", originalTitle: "The Dark Knight", year: 2008,
                  kind: "Фильм", genres: ["Боевик", "Криминал"], synopsis: "Готэм сталкивается с новым преступником."),
        MediaItem(title: "Очень странные дела", originalTitle: "Stranger Things", year: 2016,
                  kind: "Сериал", genres: ["Фантастика", "Драма"], synopsis: "Тайны небольшого города и исчезновение мальчика.")
    ]
    @Published var favorites: Set<UUID> = []
    @Published var query = ""
    var filtered: [MediaItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return items }
        return items.filter { $0.searchableText.localizedStandardContains(q) }
    }
    func toggleFavorite(_ item: MediaItem) {
        if favorites.contains(item.id) { favorites.remove(item.id) } else { favorites.insert(item.id) }
    }
}
