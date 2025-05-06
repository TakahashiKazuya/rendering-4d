import SwiftUI

struct TopScreen: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ContentView()
                } label: {
                    Text("Content")
                }
            }
        }
    }
}

#Preview {
    TopScreen()
}
