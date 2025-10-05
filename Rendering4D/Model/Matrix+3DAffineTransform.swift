extension Matrix {
    static func of3DAffineTranslation(by v: Vector) -> Matrix {
        precondition(v.dim == 3)

        return Matrix(rows: [
            [1, 0, 0, v[0]],
            [0, 1, 0, v[1]],
            [0, 0, 1, v[2]],
            [0, 0, 0, 1],
        ])
    }

    static func of3DAffineScale(by v: Vector) -> Matrix {
        precondition(v.dim == 3)

        return Matrix(rows: [
            [v[0], 0, 0, 0],
            [0, v[1], 0, 0],
            [0, 0, v[2], 0],
            [0, 0, 0, 1],
        ])
    }

    static func of3DAffineRotation(by m: Matrix) -> Matrix {
        precondition(m.numRows == 3 && m.numCols == 3)

        return Matrix(rows: [
            [m[0, 0], m[0, 1], m[0, 2], 0],
            [m[1, 0], m[1, 1], m[1, 2], 0],
            [m[2, 0], m[2, 1], m[2, 2], 0],
            [0, 0, 0, 1],
        ])
    }
}
