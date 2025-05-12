extension Matrix {
    static func of4DRotationOnXY(byDegree degree: Double) -> Matrix {
        return Matrix(rows: [
            [cos(degree: degree), -sin(degree: degree), 0, 0],
            [sin(degree: degree), cos(degree: degree), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1],
        ])
    }

    static func of4DRotationOnYZ(byDegree degree: Double) -> Matrix {
        return Matrix(rows: [
            [1, 0, 0, 0],
            [0, cos(degree: degree), -sin(degree: degree), 0],
            [0, sin(degree: degree), cos(degree: degree), 0],
            [0, 0, 0, 1],
        ])
    }

    static func of4DRotationOnZX(byDegree degree: Double) -> Matrix {
        return Matrix(rows: [
            [cos(degree: degree), 0, sin(degree: degree), 0],
            [0, 1, 0, 0],
            [-sin(degree: degree), 0, cos(degree: degree), 0],
            [0, 0, 0, 1],
        ])
    }

    static func of4DRotationOnWX(byDegree degree: Double) -> Matrix {
        return Matrix(rows: [
            [cos(degree: degree), 0, 0, sin(degree: degree)],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [-sin(degree: degree), 0, 0, cos(degree: degree)],
        ])
    }

    static func of4DRotationOnWY(byDegree degree: Double) -> Matrix {
        return Matrix(rows: [
            [1, 0, 0, 0],
            [0, cos(degree: degree), 0, sin(degree: degree)],
            [0, 0, 1, 0],
            [0, -sin(degree: degree), 0, cos(degree: degree)],
        ])
    }

    static func of4DRotationOnZW(byDegree degree: Double) -> Matrix {
        return Matrix(rows: [
            [1, 0, 0, 0],
            [0, 1, 0, 0],
            [0, 0, cos(degree: degree), -sin(degree: degree)],
            [0, 0, sin(degree: degree), cos(degree: degree)],
        ])
    }
}
