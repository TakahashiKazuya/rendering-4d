struct Matrix {
    let rows: [[Double]]

    var numRows: Int {
        rows.count
    }
    var numCols: Int {
        rows.first?.count ?? 0
    }

    init(rows: [[Double]]) {
        precondition(rows.isEmpty || rows.map(\.count).allSatisfy { $0 == rows.first!.count })

        self.rows = rows
    }

    subscript(row: Int, col: Int) -> Double {
        return rows[row][col]
    }
}

// matrix operations
extension Matrix {
    static func * (m1: Matrix, m2: Matrix) -> Matrix {
        precondition(m1.numCols == m2.numRows)

        let rows = (0..<m1.numRows).map { i in
            (0..<m2.numCols).map { j in
                (0..<m2.numRows).map { k in
                    m1[i, k] * m2[k, j]
                }.reduce(0, +)
            }
        }

        return Matrix(rows: rows)
    }

    static func * (m: Matrix, v: Vector) -> Vector {
        precondition(m.numCols == v.dim)

        let component = (0..<m.numRows).map { i in
            (0..<m.numCols).map { j in
                m[i, j] * v[j]
            }.reduce(0, +)
        }

        return Vector(component)
    }
}

extension Matrix {
    func transposed() -> Matrix {
        return Matrix(
            rows: (0..<numCols).map { i in
                (0..<numRows).map { j in
                    self[j, i]
                }
            }
        )
    }
}
