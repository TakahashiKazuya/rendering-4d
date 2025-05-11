extension Matrix {
    static func of3DRotationOnXY(byDegree degree: Double) -> Matrix {
        return Matrix(rows: [
            [cos(degree: degree), -sin(degree: degree), 0],
            [sin(degree: degree), cos(degree: degree), 0],
            [0, 0, 1],
        ])
    }

    static func of3DRotationOnYZ(byDegree degree: Double) -> Matrix {
        return Matrix(rows: [
            [1, 0, 0],
            [0, cos(degree: degree), -sin(degree: degree)],
            [0, sin(degree: degree), cos(degree: degree)],
        ])
    }

    static func of3DRotationOnZX(byDegree degree: Double) -> Matrix {
        return Matrix(rows: [
            [cos(degree: degree), 0, sin(degree: degree)],
            [0, 1, 0],
            [-sin(degree: degree), 0, cos(degree: degree)],
        ])
    }
}
