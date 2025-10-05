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
            Rotation4DRealityView(
                shape: hyperCube,
                cameraPosition: cameraPosition,
                projectionCenter: Vector([0, 0, -8, 2]),
                projectionNear: 1,
                projectionFar: 10,
            )
            Rotation4DGestureRecognizerView(cameraPosition: $cameraPosition, rotationType: $rotationType)

            VStack(alignment: .leading) {
                Text(rotationTypeText)
                    .font(.title)
                Spacer()
                Text("one-finger drag: 3D Rotation")
                Text("two-finger drag: 4D Rotation")
            }
            .colorScheme(.light)
            .padding()
        }
        .background(Color.white)
    }
}

#Preview {
    Rotation4DView()
}
