import SwiftUI

@main
struct SobstvennostTsaryaApp: App {
    @StateObject private var store = CatalogStore()
    var body: some Scene {
        WindowGroup { RootView().environmentObject(store).preferredColorScheme(.dark) }
    }
}
