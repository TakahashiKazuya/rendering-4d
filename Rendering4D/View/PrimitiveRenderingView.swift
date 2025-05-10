import SceneKit
import SwiftUI

struct PrimitiveRenderingView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        // geometry
        let cube = Shape(vertices: [Vector([])], edges: [])
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)
            .extrude(from: -1, to: 1)

        let vertices = cube.vertices.map { vertex in SCNVector3(vertex[0], vertex[1], vertex[2]) }
        let geometrySource = SCNGeometrySource(vertices: vertices)

        let indices: [Int32] = cube.edges.flatMap { edge in [Int32(edge.startVertexIndex), Int32(edge.endVertexIndex)] }
        let data = Data(bytes: indices, count: MemoryLayout<Int32>.size * indices.count)
        let geometryElement = SCNGeometryElement(
            data: data,
            primitiveType: .line,
            primitiveCount: cube.edges.count,
            bytesPerIndex: MemoryLayout<Int32>.size,
        )

        let geometry = SCNGeometry(sources: [geometrySource], elements: [geometryElement])
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        let geometryNode = SCNNode()
        geometryNode.geometry = geometry

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
        scene.rootNode.addChildNode(geometryNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(cameraNode)

        let view = SCNView()
        view.scene = scene
        view.allowsCameraControl = true

        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {}
}

#Preview {
    PrimitiveRenderingView()
}
