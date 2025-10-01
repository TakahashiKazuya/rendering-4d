import RealityKit
import SwiftUI

struct CustomCameraRealityView: View {
    let shape: Shape
    let cameraPosition: CameraPosition3D

    var body: some View {
        RealityView(
            make: { content in
                let anchorEntity = AnchorEntity()
                anchorEntity.name = "anchorForCameraTransformation"
                content.add(anchorEntity)
                anchorEntity.transform = Transform(
                    matrix: float4x4(rows: cameraPosition.transformationMatrix.rows.map { SIMD4($0.map { Float($0) }) })
                )

                // model
                let modelEntities = shape.edges.flatMap { edge in
                    makePrettyEdgeEntities(
                        startVertex: shape.vertices[edge.startVertexIndex],
                        endVertex: shape.vertices[edge.endVertexIndex],
                    )
                }
                for entity in modelEntities {
                    anchorEntity.addChild(entity)
                }

                // light
                let lightEntity = DirectionalLight()
                lightEntity.position = [4, 8, 2]
                lightEntity.look(at: [0, 0, 0], from: lightEntity.position, relativeTo: nil)
                anchorEntity.addChild(lightEntity)

                // camera
                let cameraEntity = PerspectiveCamera()
                cameraEntity.position = [0, 0, 0]
                cameraEntity.look(at: [0, 0, -1], from: cameraEntity.position, relativeTo: nil)
                content.add(cameraEntity)
            },
            update: { content in
                guard
                    let anchorEntity = content.entities.first(where: { $0.name == "anchorForCameraTransformation" })
                        as? AnchorEntity
                else {
                    return
                }

                anchorEntity.transform = Transform(
                    matrix: float4x4(
                        rows: cameraPosition.transformationMatrix.rows.map { SIMD4($0.map { Float($0) }) }
                    )
                )
            }
        )
    }

    func makePrettyEdgeEntities(startVertex: Vector, endVertex: Vector) -> [Entity] {
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

        return [cylinderEntity, startSphereEntity, endSphereEntity]
    }
}

#Preview {
    let cube = Shape(vertices: [Vector([])], edges: [])
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)

    let cameraPosition = CameraPosition3D(
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

    CustomCameraRealityView(
        shape: cube,
        cameraPosition: cameraPosition,
    )
}
