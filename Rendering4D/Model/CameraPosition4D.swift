struct CameraPosition4D {
    let target: Vector
    let distanceFromTarget: Double
    let rotation: Matrix

    init(target: Vector, distanceFromTarget: Double, rotation: Matrix) {
        precondition(target.dim == 4)
        precondition(rotation.numRows == 4 && rotation.numCols == 4)

        self.target = target
        self.distanceFromTarget = distanceFromTarget
        self.rotation = rotation
    }

    var transformationMatrix: Matrix {
        let invRotation = rotation.transposed()
        let transformedTarget = Vector([0, 0, -distanceFromTarget, 0])

        return Matrix.of4DAffineRotation(by: invRotation)
            * Matrix.of4DAffineTranslation(by: rotation * transformedTarget)
            * Matrix.of4DAffineTranslation(by: -target)
    }

    func rotate(by matrix: Matrix) -> CameraPosition4D {
        CameraPosition4D(
            target: target,
            distanceFromTarget: distanceFromTarget,
            rotation: rotation * matrix,
        )
    }
}
