import SwiftUI

struct Rotation4DView: View {
    @State private var cameraPosition = CameraPosition4D(
        target: Vector([0, 0, 0, 0]),
        distanceFromTarget: 8,
        rotation:
            Matrix.of4DRotationOnZX(byDegree: 30)
            * Matrix.of4DRotationOnYZ(byDegree: -30)
    )
    @State private var rotationType: RotationType? = nil

    var hyperCube: Shape {
        return Shape(vertices: [Vector([])], edges: [])
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
    }

    var rotationTypeText: String {
        switch rotationType {
        case .rotation3D:
            return "3D Rotation"
        case .rotation4D:
            return "4D Rotation"
        case nil:
            return ""
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rotation4DSceneView(
                shape: hyperCube,
                cameraPosition: $cameraPosition,
                rotationType: $rotationType,
                projectionCenter: Vector([0, 0, -8, 2]),
                projectionNear: 1,
                projectionFar: 10,
            )
            Text(rotationTypeText)
                .font(.title)
                .padding()
        }
    }
}

#Preview {
    Rotation4DView()
}
