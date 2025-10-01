import SwiftUI

struct Rendering4DView: View {
    @State private var cameraPosition = CameraPosition4D(
        target: Vector([0, 0, 0, 0]),
        distanceFromTarget: 8,
        rotation:
            Matrix.of4DRotationOnZX(byDegree: 30)
            * Matrix.of4DRotationOnYZ(byDegree: -30)
    )

    var hyperCube: Shape {
        return Shape(vertices: [Vector([])], edges: [])
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
    }

    var body: some View {
        ZStack {
            Rendering4DRealityView(
                shape: hyperCube,
                cameraPosition: cameraPosition,
                projectionCenter: Vector([0, 0, -8, 2]),
                projectionNear: 1,
                projectionFar: 10,
            )
            Rendering4DGestureRecognizerView(cameraPosition: $cameraPosition)
        }
    }
}

#Preview {
    Rendering4DView()
}
