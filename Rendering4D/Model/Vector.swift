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
}

extension Vector {
    func normL2() -> Double {
        return sqrt(
            component.reduce(0) { acc, element in
                acc + element * element
            }
        )
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
