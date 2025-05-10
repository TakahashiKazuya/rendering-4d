import SceneKit
import SwiftUI

struct Simple3DView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        // geometry
        let boxNode = SCNNode(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0))
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        boxNode.position = SCNVector3(0, 0, 0)

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
        scene.rootNode.addChildNode(boxNode)
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
}

#Preview {
    Simple3DView()
}
