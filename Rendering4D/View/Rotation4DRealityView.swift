import RealityKit
import SwiftUI

struct Rotation4DRealityView: View {
    let shape: Shape
    let cameraPosition: CameraPosition4D
    let projectionCenter: Vector
    let projectionNear: Double
    let projectionFar: Double

    @StateObject private var store = Rotation4DRealityViewStore()

    var body: some View {
        RealityView(
            make: { content in
                // model
                let projectedShape =
                    shape
                    .affineTransform(by: cameraPosition.transformationMatrix)
                    .projection(
                        center: projectionCenter,
                        near: projectionNear,
                        far: projectionFar,
                    )

                store.entities = projectedShape.edges.map { edge in
                    makePrettyEdgeEntities()
                }
                projectedShape.edges.enumerated().forEach { index, edge in
                    updateEdgeEntities(
                        index: index,
                        startVertex: projectedShape.vertices[edge.startVertexIndex],
                        endVertex: projectedShape.vertices[edge.endVertexIndex],
                    )
                }
                for entity in store.entities.joined() {
                    content.add(entity)
                }

                // light
                let lightEntity = DirectionalLight()
                lightEntity.position = [4, 8, 2]
                lightEntity.look(at: [0, 0, 0], from: lightEntity.position, relativeTo: nil)
                content.add(lightEntity)

                // camera
                let cameraEntity = PerspectiveCamera()
                cameraEntity.position = [0, 0, 0]
                cameraEntity.look(at: [0, 0, -1], from: cameraEntity.position, relativeTo: nil)
                content.add(cameraEntity)
            },
            update: { content in
                let projectedShape =
                    shape
                    .affineTransform(by: cameraPosition.transformationMatrix)
                    .projection(
                        center: projectionCenter,
                        near: projectionNear,
                        far: projectionFar,
                    )

                projectedShape.edges.enumerated().forEach { index, edge in
                    updateEdgeEntities(
                        index: index,
                        startVertex: projectedShape.vertices[edge.startVertexIndex],
                        endVertex: projectedShape.vertices[edge.endVertexIndex],
                    )
                }
            }
        )
    }

    func makePrettyEdgeEntities() -> [Entity] {
        let radius = 0.1

        let material = SimpleMaterial(color: .red, roughness: 1.0, isMetallic: false)

        let cylinderMesh = MeshResource.generateCylinder(height: 1.0, radius: Float(radius))
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

        return [cylinderEntity, startSphereEntity, endSphereEntity]
    }

    func updateEdgeEntities(index: Int, startVertex: Vector, endVertex: Vector) {
        let length = (endVertex - startVertex).normL2()
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
            * Matrix.of3DAffineScale(by: Vector([1, length, 1]))

        store.entities[index][0].transform = Transform(
            matrix: float4x4(rows: cylinderTransformMatrix.rows.map { SIMD4($0.map { Float($0) }) })
        )
        store.entities[index][1].position = SIMD3(startVertex.component.map { Float($0) })
        store.entities[index][2].position = SIMD3(endVertex.component.map { Float($0) })
    }
}

class Rotation4DRealityViewStore: ObservableObject {
    var entities: [[Entity]] = []
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

    let hyperCube = Shape(vertices: [Vector([])], edges: [])
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)
        .extrude(from: -1, to: 1)

    Rotation4DRealityView(
        shape: hyperCube,
        cameraPosition: cameraPosition,
        projectionCenter: Vector([0, 0, -4, 2]),
        projectionNear: 1,
        projectionFar: 10,
    )
}
