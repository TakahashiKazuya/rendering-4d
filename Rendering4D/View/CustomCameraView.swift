import SwiftUI

struct CustomCameraView: View {
    @State private var cameraPosition = CameraPosition3D(
        target: Vector([0, 0, 0]),
        distanceFromTarget: 8,
        rotation:
            Matrix.of3DRotationOnZX(byDegree: 30)
            * Matrix.of3DRotationOnYZ(byDegree: -30)
    )

    var cube: Shape {
        return Shape(vertices: [Vector([])], edges: [])
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
    }

    var body: some View {
        ZStack {
            CustomCameraRealityView(
                shape: cube,
                cameraPosition: cameraPosition
            )
            CustomCameraGestureRecognizerView(cameraPosition: $cameraPosition)
        }
    }
}

#Preview {
    CustomCameraView()
}
