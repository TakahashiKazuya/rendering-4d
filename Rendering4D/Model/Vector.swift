import Foundation

struct Vector {
    let component: [Double]

    var dim: Int {
        component.count
    }

    init(_ component: [Double]) {
        self.component = component
    }

    subscript(index: Int) -> Double {
        return component[index]
    }
}

// vector operations
extension Vector {
    static func + (v1: Vector, v2: Vector) -> Vector {
        precondition(v1.dim == v2.dim)

        return Vector(zip(v1.component, v2.component).map(+))
    }

    static func * (a: Double, v: Vector) -> Vector {
        return Vector(v.component.map { a * $0 })
    }
}

// extended vector operations
extension Vector {
    static prefix func - (v: Vector) -> Vector {
        return (-1) * v
    }

    static func - (v1: Vector, v2: Vector) -> Vector {
        precondition(v1.dim == v2.dim)

        return v1 + (-v2)
    }

    static func / (v: Vector, a: Double) -> Vector {
        precondition(a != 0)

        return (1 / a) * v
    }
}

extension Vector {
    func normL2() -> Double {
        return sqrt(
            component.reduce(0) { acc, element in
                acc + element * element
            }
        )
    }

    func normalized() -> Vector {
        return self / normL2()
    }

    func cross(_ v: Vector) -> Vector {
        precondition(dim == 3 && v.dim == 3)

        return Vector([
            self[1] * v[2] - self[2] * v[1],
            self[2] * v[0] - self[0] * v[2],
            self[0] * v[1] - self[1] * v[0],
        ])
    }
}

extension Vector {
    func extend(by element: Double) -> Vector {
        return Vector(component + [element])
    }
}

extension Vector {
    func affineTransform(by m: Matrix) -> Vector {
        precondition(m.numRows == dim + 1 && m.numCols == dim + 1)

        let transformedHomVector = m * self.extend(by: 1)
        let dividedComponent = (0..<dim).map { i in
            transformedHomVector[i] / transformedHomVector[dim]
        }

        return Vector(dividedComponent)
    }
}
