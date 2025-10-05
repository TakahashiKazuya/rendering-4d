import RealityKit
import SwiftUI

struct PrimitiveRenderingView: View {
    var body: some View {
        RealityView { content in
            // model
            let cube = Shape(vertices: [Vector([])], edges: [])
                .extrude(from: -1, to: 1)
                .extrude(from: -1, to: 1)
                .extrude(from: -1, to: 1)

            let modelEntities = cube.edges.map { edge in
                makePrettyEdgeEntity(
                    startVertex: cube.vertices[edge.startVertexIndex],
                    endVertex: cube.vertices[edge.endVertexIndex],
                )
            }
            for entity in modelEntities {
                content.add(entity)
            }

            // light
            let lightEntity = DirectionalLight()
            lightEntity.position = [4, 8, 2]
            lightEntity.look(at: [0, 0, 0], from: lightEntity.position, relativeTo: nil)
            content.add(lightEntity)

            // camera
            let cameraEntity = PerspectiveCamera()
            cameraEntity.position = [3, 4, 6]
            cameraEntity.look(at: [0, 0, 0], from: cameraEntity.position, relativeTo: nil)
            content.add(cameraEntity)
        }
        .realityViewCameraControls(CameraControls.orbit)
        .background(Color.white)
    }

    func makePrettyEdgeEntity(startVertex: Vector, endVertex: Vector) -> Entity {
        let length = (endVertex - startVertex).normL2()
        let radius = 0.1

        let material = SimpleMaterial(color: .red, roughness: 1.0, isMetallic: false)

        let cylinderMesh = MeshResource.generateCylinder(height: Float(length), radius: Float(radius))
        let cylinderEntity = ModelEntity(
            mesh: cylinderMesh,
            materials: [material],
        )

        let sphereMesh = MeshResource.generateSphere(radius: Float(radius))
        let startSphereEntity = ModelEntity(
            mesh: sphereMesh,
            materials: [material],
        )
        let endSphereEntity = ModelEntity(
            mesh: sphereMesh,
            materials: [material],
        )

        let dirVector = (endVertex - startVertex).normalized()
        let orthVector1 =
            if dirVector[0] != 0 || dirVector[1] != 0 {
                Vector([dirVector[1], -dirVector[0], 0]).normalized()
            } else {
                Vector([dirVector[2], 0, -dirVector[0]]).normalized()
            }
        let orthVector2 = dirVector.cross(orthVector1).normalized()

        let cylinderTransformMatrix =
            Matrix.of3DAffineTranslation(by: startVertex)
            * Matrix.of3DAffineRotation(
                by: Matrix(rows: [
                    [orthVector2[0], dirVector[0], orthVector1[0]],
                    [orthVector2[1], dirVector[1], orthVector1[1]],
                    [orthVector2[2], dirVector[2], orthVector1[2]],
                ])
            )
            * Matrix.of3DAffineTranslation(by: Vector([0, length / 2, 0]))
        cylinderEntity.transform = Transform(
            matrix: float4x4(rows: cylinderTransformMatrix.rows.map { SIMD4($0.map { Float($0) }) })
        )

        startSphereEntity.position = SIMD3(startVertex.component.map { Float($0) })
        endSphereEntity.position = SIMD3(endVertex.component.map { Float($0) })

        let anchorEntity = AnchorEntity()
        anchorEntity.addChild(startSphereEntity)
        anchorEntity.addChild(endSphereEntity)
        anchorEntity.addChild(cylinderEntity)

        return anchorEntity
    }
}

#Preview {
    PrimitiveRenderingView()
}
