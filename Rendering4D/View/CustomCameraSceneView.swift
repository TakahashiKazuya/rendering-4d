import SceneKit
import SwiftUI

struct CustomCameraSceneView: UIViewRepresentable {
    let shape: Shape
    @Binding var cameraPosition: CameraPosition3D

    func makeUIView(context: Context) -> SCNView {
        let nodeForCameraTransformation = SCNNode()
        nodeForCameraTransformation.name = "nodeForCameraTransformation"
        nodeForCameraTransformation.transform = SCNMatrix4(
            double4x4(rows: cameraPosition.transformationMatrix.rows.map { SIMD4($0) })
        )

        // geometry
        let geometryNodes = shape.edges.map { edge in
            makePrettyEdgeGeometryNode(
                startVertex: shape.vertices[edge.startVertexIndex],
                endVertex: shape.vertices[edge.endVertexIndex],
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
        scene.rootNode.addChildNode(nodeForCameraTransformation)
        for geometryNode in geometryNodes {
            nodeForCameraTransformation.addChildNode(geometryNode)
        }
        nodeForCameraTransformation.addChildNode(lightNode)
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

        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        view.scene?.rootNode.childNode(withName: "nodeForCameraTransformation", recursively: false)?.transform =
            SCNMatrix4(
                double4x4(rows: cameraPosition.transformationMatrix.rows.map { SIMD4($0) })
            )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(cameraPosition: $cameraPosition)
    }

    class Coordinator {
        static let rotationSensitivity: Double = 0.008

        @Binding var cameraPosition: CameraPosition3D

        init(cameraPosition: Binding<CameraPosition3D>) {
            self._cameraPosition = cameraPosition
        }

        @objc func handleDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
            switch gestureRecognizer.state {
            case .changed:
                let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
                let deltaX = translation.x
                let deltaY = -translation.y
                let axisAngle = atan2InDegree(deltaY, deltaX)
                let rotationAngle = atanInDegree(hypot(deltaX, deltaY) * Self.rotationSensitivity)

                let rotationMatrix =
                    Matrix.of3DRotationOnXY(byDegree: axisAngle)
                    * Matrix.of3DRotationOnZX(byDegree: -rotationAngle)
                    * Matrix.of3DRotationOnXY(byDegree: -axisAngle)

                cameraPosition = cameraPosition.rotate(by: rotationMatrix)
                gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
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
    @Previewable @State var cameraPosition = CameraPosition3D(
        target: Vector([0, 0, 0]),
        distanceFromTarget: 4,
        rotation: Matrix(
            rows: [
                [1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1],
            ]),
    )

    let cube = Shape(vertices: [Vector([])], edges: [])
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)

    CustomCameraSceneView(
        shape: cube,
        cameraPosition: $cameraPosition,
    )
}
