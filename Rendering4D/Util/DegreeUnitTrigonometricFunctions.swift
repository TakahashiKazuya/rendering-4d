import Foundation

func toRadian(_ theta: Double) -> Double {
    theta * .pi / 180
}

func toDegree(_ theta: Double) -> Double {
    theta * 180 / .pi
}

func sin(degree theta: Double) -> Double {
    sin(toRadian(theta))
}

func cos(degree theta: Double) -> Double {
    cos(toRadian(theta))
}

func tan(degree theta: Double) -> Double {
    tan(toRadian(theta))
}

func atanInDegree(_ x: Double) -> Double {
    toDegree(atan(x))
}

func atan2InDegree(_ y: Double, _ x: Double) -> Double {
    toDegree(atan2(y, x))
}
