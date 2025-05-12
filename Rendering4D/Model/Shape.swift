struct Shape {
    struct Edge {
        let startVertexIndex: Int
        let endVertexIndex: Int
    }

    let vertices: [Vector]
    let edges: [Edge]
}

extension Shape {
    func affineTransform(by matrix: Matrix) -> Shape {
        let transformedVertices = vertices.map { $0.affineTransform(by: matrix) }

        return Shape(vertices: transformedVertices, edges: edges)
    }
}

extension Shape {
    func extrude(from startOfNewDim: Double, to endOfNewDim: Double) -> Shape {
        let newVerticesInStartOfNewDim = vertices.map { $0.extend(by: startOfNewDim) }
        let newVerticesInEndOfNewDim = vertices.map { $0.extend(by: endOfNewDim) }

        let newEdgesInStartOfNewDim = edges
        let newEdgesInEndOfNewDim = edges.map { edge in
            Edge(
                startVertexIndex: edge.startVertexIndex + vertices.count,
                endVertexIndex: edge.endVertexIndex + vertices.count,
            )
        }
        let newEdgesBetweenStartAndEndOfNewDim = (0..<vertices.count).map { index in
            Edge(
                startVertexIndex: index,
                endVertexIndex: index + vertices.count,
            )
        }

        return Shape(
            vertices: newVerticesInStartOfNewDim + newVerticesInEndOfNewDim,
            edges: newEdgesInStartOfNewDim + newEdgesInEndOfNewDim + newEdgesBetweenStartAndEndOfNewDim,
        )
    }

    func projection(center: Vector, near: Double, far: Double) -> Shape {
        precondition(near > 0)
        precondition(near < far)

        let depthInv = 1 / (far - near)
        let projectionMatrix = Matrix(rows: [
            [near, 0, 0, 0, 0],
            [0, near, 0, 0, 0],
            [0, 0, near, 0, 0],
            [0, 0, 0, -far * depthInv, -near * far * depthInv],
            [0, 0, 0, -1, 0],
        ])

        let projectedVertices =
            vertices
            .map { $0 - center }
            .map { $0.affineTransform(by: projectionMatrix) }
            .map { $0 + center }
            .map { Vector($0.component.dropLast()) }

        return Shape(vertices: projectedVertices, edges: edges)
    }
}
