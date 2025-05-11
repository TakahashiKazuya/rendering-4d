import SceneKit
import SwiftUI

struct PrettyPrimitiveRenderingView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        // geometry
        let cube = Shape(vertices: [Vector([])], edges: [])
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)

        let geometryNodes = cube.edges.map { edge in
            makePrettyEdgeGeometryNode(
                startVertex: cube.vertices[edge.startVertexIndex],
                endVertex: cube.vertices[edge.endVertexIndex],
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
        cameraNode.position = SCNVector3(3, 4, 6)
        cameraNode.look(at: SCNVector3(0, 0, 0))

        let scene = SCNScene()
        for geometryNode in geometryNodes {
            scene.rootNode.addChildNode(geometryNode)
        }
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(cameraNode)

        let view = SCNView()
        view.scene = scene
        view.allowsCameraControl = true
        view.defaultCameraController.automaticTarget = false
        // target が (0, 0, 0) に近いと効かなくなるバグがあるっぽいので少しずらす
        view.defaultCameraController.target = SCNVector3(0, 0, 1e-20)

        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {}

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
    PrettyPrimitiveRenderingView()
}
