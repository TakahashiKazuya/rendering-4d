struct Vector {
    let dim: Int
    let component: [Double]

    init(_ component: [Double]) {
        self.dim = component.count
        self.component = component
    }

    subscript(index: Int) -> Double {
        return component[index]
    }
}

extension Vector {
    func extend(by element: Double) -> Vector {
        return Vector(component + [element])
    }
}
