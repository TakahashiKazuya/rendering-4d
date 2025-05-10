struct Shape {
    struct Edge {
        let startVertexIndex: Int
        let endVertexIndex: Int
    }

    let vertices: [Vector]
    let edges: [Edge]
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
}
