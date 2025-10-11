import RealityKit
import SwiftUI

struct Simple3DView: View {
    var body: some View {
        RealityView { content in
            // model
            let boxEntity = ModelEntity(
                mesh: .generateBox(size: 2),
                materials: [SimpleMaterial(color: .red, roughness: 1.0, isMetallic: false)],
            )
            boxEntity.setPosition([0, 0, 0], relativeTo: nil)
            content.add(boxEntity)

            // light
            let lightEntity = DirectionalLight()
            lightEntity.setPosition([4, 8, 2], relativeTo: nil)
            lightEntity.look(at: [0, 0, 0], from: lightEntity.position, relativeTo: nil)
            content.add(lightEntity)

            // camera
            let cameraEntity = PerspectiveCamera()
            cameraEntity.setPosition([3, 4, 6], relativeTo: nil)
            cameraEntity.look(at: [0, 0, 0], from: cameraEntity.position, relativeTo: nil)
            content.add(cameraEntity)
        }
        .realityViewCameraControls(CameraControls.orbit)
        .background(Color.white)
    }
}

#Preview {
    Simple3DView()
}
