struct CameraPosition3D {
    let target: Vector
    let distanceFromTarget: Double
    let rotation: Matrix

    init(target: Vector, distanceFromTarget: Double, rotation: Matrix) {
        precondition(target.dim == 3)
        precondition(rotation.numRows == 3 && rotation.numCols == 3)

        self.target = target
        self.distanceFromTarget = distanceFromTarget
        self.rotation = rotation
    }

    var transformationMatrix: Matrix {
        let invRotation = rotation.transposed()
        let transformedTarget = Vector([0, 0, -distanceFromTarget])

        return Matrix.of3DAffineRotation(by: invRotation)
            * Matrix.of3DAffineTranslation(by: rotation * transformedTarget)
            * Matrix.of3DAffineTranslation(by: -target)
    }

    func rotate(by matrix: Matrix) -> CameraPosition3D {
        CameraPosition3D(
            target: target,
            distanceFromTarget: distanceFromTarget,
            rotation: rotation * matrix,
        )
    }
}
