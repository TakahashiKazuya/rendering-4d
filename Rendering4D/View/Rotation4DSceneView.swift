import SceneKit
import SwiftUI

enum RotationType {
    case rotation3D
    case rotation4D
}

struct Rotation4DSceneView: UIViewRepresentable {
    let shape: Shape
    @Binding var cameraPosition: CameraPosition4D
    @Binding var rotationType: RotationType?
    let projectionCenter: Vector
    let projectionNear: Double
    let projectionFar: Double

    func makeUIView(context: Context) -> SCNView {
        let geometryParentNode = SCNNode()
        geometryParentNode.name = "geometryParentNode"

        // geometry
        let projectedShape =
            shape
            .affineTransform(by: cameraPosition.transformationMatrix)
            .projection(
                center: projectionCenter,
                near: projectionNear,
                far: projectionFar,
            )

        let geometryNodes = projectedShape.edges.map { edge in
            makePrettyEdgeGeometryNode(
                startVertex: projectedShape.vertices[edge.startVertexIndex],
                endVertex: projectedShape.vertices[edge.endVertexIndex],
            )
        }

        // light
        let directionalLight = SCNLight()
        directionalLight.type = .directional

        let lightNode = SCNNode()
        lightNode.light = directionalLight
        lightNode.position = SCNVector3(4, 8, 2)
        lightNode.look(at: SCNVector3(0, 0, 0))

        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 200

        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight

        // camera
        let camera = SCNCamera()

        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 0)
        cameraNode.look(at: SCNVector3(0, 0, -1))

        let scene = SCNScene()
        scene.rootNode.addChildNode(geometryParentNode)
        for geometryNode in geometryNodes {
            geometryParentNode.addChildNode(geometryNode)
        }
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(cameraNode)

        let view = SCNView()
        view.scene = scene

        // custom camera control
        let dragGestureRecognizer = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDrag(_:)),
        )
        dragGestureRecognizer.minimumNumberOfTouches = 1
        dragGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(dragGestureRecognizer)

        let doubleFingerDragGestureRecognizer = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleFingerDrag(_:)),
        )
        doubleFingerDragGestureRecognizer.minimumNumberOfTouches = 2
        doubleFingerDragGestureRecognizer.maximumNumberOfTouches = 2
        view.addGestureRecognizer(doubleFingerDragGestureRecognizer)

        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        let projectedShape =
            shape
            .affineTransform(by: cameraPosition.transformationMatrix)
            .projection(
                center: projectionCenter,
                near: projectionNear,
                far: projectionFar,
            )

        let geometryNodes = projectedShape.edges.map { edge in
            makePrettyEdgeGeometryNode(
                startVertex: projectedShape.vertices[edge.startVertexIndex],
                endVertex: projectedShape.vertices[edge.endVertexIndex],
            )
        }

        let geometryParentNode = view.scene!.rootNode.childNode(
            withName: "geometryParentNode",
            recursively: false,
        )!

        // delete old geometries
        geometryParentNode.childNodes
            .filter { $0.geometry != nil }
            .forEach { $0.removeFromParentNode() }

        for geometryNode in geometryNodes {
            geometryParentNode.addChildNode(geometryNode)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(cameraPosition: $cameraPosition, rotationType: $rotationType)
    }

    class Coordinator {
        static let rotationSensitivity: Double = 0.008

        @Binding var cameraPosition: CameraPosition4D
        @Binding var rotationType: RotationType?

        init(cameraPosition: Binding<CameraPosition4D>, rotationType: Binding<RotationType?>) {
            self._cameraPosition = cameraPosition
            self._rotationType = rotationType
        }

        @objc func handleDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
            switch gestureRecognizer.state {
            case .began:
                rotationType = .rotation3D
            case .changed:
                let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
                let deltaX = translation.x
                let deltaY = -translation.y
                let axisAngle = atan2InDegree(deltaY, deltaX)
                let rotationAngle = atanInDegree(hypot(deltaX, deltaY) * Self.rotationSensitivity)

                let rotationMatrix =
                    Matrix.of4DRotationOnXY(byDegree: axisAngle)
                    * Matrix.of4DRotationOnZX(byDegree: -rotationAngle)
                    * Matrix.of4DRotationOnXY(byDegree: -axisAngle)

                cameraPosition = cameraPosition.rotate(by: rotationMatrix)
                gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
            case .ended:
                rotationType = nil
            default:
                break
            }
        }

        @objc func handleDoubleFingerDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
            switch gestureRecognizer.state {
            case .began:
                rotationType = .rotation4D
            case .changed:
                let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
                let deltaX = translation.x
                let deltaY = -translation.y
                let axisAngle = atan2InDegree(deltaY, deltaX)
                let rotationAngle = atanInDegree(hypot(deltaX, deltaY) * Self.rotationSensitivity)

                let rotationMatrix =
                    Matrix.of4DRotationOnXY(byDegree: axisAngle)
                    * Matrix.of4DRotationOnWX(byDegree: -rotationAngle)
                    * Matrix.of4DRotationOnXY(byDegree: -axisAngle)

                cameraPosition = cameraPosition.rotate(by: rotationMatrix)
                gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
            case .ended:
                rotationType = nil
            default:
                break
            }
        }
    }

    func makePrettyEdgeGeometryNode(startVertex: Vector, endVertex: Vector) -> SCNNode {
        let length = (endVertex - startVertex).normL2()
        let capRadius = 0.1
        let cupsule = SCNCapsule(capRadius: capRadius, height: length + 2 * capRadius)
        cupsule.firstMaterial?.diffuse.contents = UIColor.red

        let geometryNode = SCNNode()
        geometryNode.geometry = cupsule
        geometryNode.localTranslate(by: SCNVector3(startVertex[0], startVertex[1], startVertex[2]))
        geometryNode.look(
            at: SCNVector3(endVertex[0], endVertex[1], endVertex[2]),
            up: geometryNode.worldUp,
            localFront: SCNVector3(0, 1, 0),
        )
        geometryNode.localTranslate(by: SCNVector3(0, length / 2, 0))

        return geometryNode
    }
}

#Preview {
    @Previewable @State var cameraPosition = CameraPosition4D(
        target: Vector([0, 0, 0, 0]),
        distanceFromTarget: 4,
        rotation: Matrix(
            rows: [
                [1, 0, 0, 0, 0],
                [0, 1, 0, 0, 0],
                [0, 0, 1, 0, 0],
                [0, 0, 0, 1, 0],
                [0, 0, 0, 0, 1],
            ]),
    )
    @Previewable @State var rotationType: RotationType? = nil

    let hyperCube = Shape(vertices: [Vector([])], edges: [])
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)

    Rotation4DSceneView(
        shape: hyperCube,
        cameraPosition: $cameraPosition,
        rotationType: $rotationType,
        projectionCenter: Vector([0, 0, -4, 2]),
        projectionNear: 1,
        projectionFar: 10,
    )
}
