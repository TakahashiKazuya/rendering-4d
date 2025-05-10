import SwiftUI

struct TopScreen: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    Simple3DView()
                } label: {
                    Text("Simple 3D")
                }
                NavigationLink {
                    PrimitiveRenderingView()
                } label: {
                    Text("Primitive Rendering")
                }
                NavigationLink {
                    PrettyPrimitiveRenderingView()
                } label: {
                    Text("Primitive Rendering (Pretty Edge)")
                }
            }
        }
    }
}

#Preview {
    TopScreen()
}
