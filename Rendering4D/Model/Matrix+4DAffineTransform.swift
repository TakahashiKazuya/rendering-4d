extension Matrix {
    static func of4DAffineTranslation(by v: Vector) -> Matrix {
        precondition(v.dim == 4)

        return Matrix(rows: [
            [1, 0, 0, 0, v[0]],
            [0, 1, 0, 0, v[1]],
            [0, 0, 1, 0, v[2]],
            [0, 0, 0, 1, v[3]],
            [0, 0, 0, 0, 1],
        ])
    }

    static func of4DAffineRotation(by m: Matrix) -> Matrix {
        precondition(m.numRows == 4 && m.numCols == 4)

        return Matrix(rows: [
            [m[0, 0], m[0, 1], m[0, 2], m[0, 3], 0],
            [m[1, 0], m[1, 1], m[1, 2], m[1, 3], 0],
            [m[2, 0], m[2, 1], m[2, 2], m[2, 3], 0],
            [m[3, 0], m[3, 1], m[3, 2], m[3, 3], 0],
            [0, 0, 0, 0, 1],
        ])
    }
}
