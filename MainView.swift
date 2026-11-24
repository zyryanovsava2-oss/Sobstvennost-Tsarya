import SwiftUI
import AVKit

struct RootView: View {
    @EnvironmentObject var store: CatalogStore
    var body: some View {
        TabView {
            CatalogView().tabItem { Label("Каталог", systemImage: "film") }
            FavoritesView().tabItem { Label("Избранное", systemImage: "heart") }
            InfoView().tabItem { Label("О приложении", systemImage: "crown") }
        }.tint(Color(red: 0.88, green: 0.68, blue: 0.28))
    }
}

struct CatalogView: View {
    @EnvironmentObject var store: CatalogStore
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Image(systemName: "crown.fill").foregroundStyle(.yellow)
                        Text("СОБСТВЕННОСТЬ ЦАРЯ").font(.headline).tracking(1.4)
                    }
                    Text("Мир кино в одном месте").font(.title2.bold())
                    LazyVStack(spacing: 12) {
                        ForEach(store.filtered) { item in
                            NavigationLink { DetailView(item: item) } label: { MediaRow(item: item) }
                                .buttonStyle(.plain)
                        }
                    }
                }.padding()
            }
            .searchable(text: $store.query, prompt: "Поиск на русском или оригинальном языке")
            .navigationTitle("Каталог")
        }
    }
}

struct MediaRow: View {
    let item: MediaItem
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.08))
                Image(systemName: item.kind == "Сериал" ? "tv" : "film").font(.largeTitle).foregroundStyle(.yellow)
            }.frame(width: 76, height: 100)
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title).font(.headline).foregroundStyle(.white)
                Text("\(item.originalTitle) · \(item.year)").font(.caption).foregroundStyle(.secondary)
                Text(item.genres.joined(separator: " · ")).font(.caption).foregroundStyle(.yellow)
                Text(item.kind).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }.padding(10).background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct DetailView: View {
    @EnvironmentObject var store: CatalogStore
    let item: MediaItem
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06))
                    .frame(height: 190).overlay(Image(systemName: "play.rectangle.fill").font(.system(size: 54)).foregroundStyle(.yellow))
                Text(item.title).font(.largeTitle.bold())
                Text("\(item.originalTitle) · \(item.year) · \(item.kind)").foregroundStyle(.secondary)
                Text(item.synopsis)
                Text("Жанры: \(item.genres.joined(separator: ", "))").foregroundStyle(.secondary)
                Button {
                    store.toggleFavorite(item)
                } label: {
                    Label(store.favorites.contains(item.id) ? "Убрать из избранного" : "В избранное",
                          systemImage: store.favorites.contains(item.id) ? "heart.fill" : "heart")
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.yellow.opacity(0.16), in: RoundedRectangle(cornerRadius: 12))
                }.tint(.yellow)
                if let url = item.playbackURL {
                    NavigationLink { PlayerView(url: url, title: item.title) } label: {
                        Label("Смотреть в приложении", systemImage: "play.fill")
                            .frame(maxWidth: .infinity).padding().background(.yellow, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.black)
                    }
                } else {
                    Label("Встроенное воспроизведение появится для источников с разрешённым потоком",
                          systemImage: "info.circle")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }.padding()
        }.navigationTitle("О фильме").navigationBarTitleDisplayMode(.inline)
    }
}

struct PlayerView: View {
    let url: URL
    let title: String
    @State private var player: AVPlayer?
    var body: some View {
        Group {
            if let player { VideoPlayer(player: player).onAppear { player.play() }.onDisappear { player.pause() } }
            else { ProgressView("Подготовка видео…") }
        }
        .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
        .onAppear { player = AVPlayer(url: url) }
        .onDisappear { player?.pause() }
    }
}

struct FavoritesView: View {
    @EnvironmentObject var store: CatalogStore
    var body: some View {
        NavigationStack {
            List(store.items.filter { store.favorites.contains($0.id) }) { item in
                NavigationLink(item.title) { DetailView(item: item) }
            }.navigationTitle("Избранное")
        }
    }
}

struct InfoView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Image(systemName: "crown.fill").font(.system(size: 54)).foregroundStyle(.yellow)
                Text("Собственность царя").font(.title.bold())
                Text("Единый каталог фильмов и сериалов. Воспроизведение доступно для источников, которые предоставляют приложению законный видеопоток.")
                    .multilineTextAlignment(.center).foregroundStyle(.secondary)
            }.padding().navigationTitle("О приложении")
        }
    }
}
