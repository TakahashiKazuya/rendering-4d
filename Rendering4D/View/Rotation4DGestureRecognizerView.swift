import SwiftUI

enum RotationType {
    case rotation3D
    case rotation4D
}

struct Rotation4DGestureRecognizerView: UIViewRepresentable {
    @Binding var cameraPosition: CameraPosition4D
    @Binding var rotationType: RotationType?

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // custom camera control
        let dragGestureRecognizer = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDrag(_:)),
        )
        dragGestureRecognizer.minimumNumberOfTouches = 1
        dragGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(dragGestureRecognizer)

        let doubleFingerDragGestureRecognizer = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleFingerDrag(_:)),
        )
        doubleFingerDragGestureRecognizer.minimumNumberOfTouches = 2
        doubleFingerDragGestureRecognizer.maximumNumberOfTouches = 2
        view.addGestureRecognizer(doubleFingerDragGestureRecognizer)

        return view
    }

    func updateUIView(_ view: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(cameraPosition: $cameraPosition, rotationType: $rotationType)
    }

    class Coordinator {
        static let rotationSensitivity: Double = 0.008

        @Binding var cameraPosition: CameraPosition4D
        @Binding var rotationType: RotationType?

        init(cameraPosition: Binding<CameraPosition4D>, rotationType: Binding<RotationType?>) {
            self._cameraPosition = cameraPosition
            self._rotationType = rotationType
        }

        @objc func handleDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
            switch gestureRecognizer.state {
            case .began:
                rotationType = .rotation3D
            case .changed:
                let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
                let deltaX = translation.x
                let deltaY = -translation.y
                let axisAngle = atan2InDegree(deltaY, deltaX)
                let rotationAngle = atanInDegree(hypot(deltaX, deltaY) * Self.rotationSensitivity)

                let rotationMatrix =
                    Matrix.of4DRotationOnXY(byDegree: axisAngle)
                    * Matrix.of4DRotationOnZX(byDegree: -rotationAngle)
                    * Matrix.of4DRotationOnXY(byDegree: -axisAngle)

                cameraPosition = cameraPosition.rotate(by: rotationMatrix)
                gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
            case .ended:
                rotationType = nil
            default:
                break
            }
        }

        @objc func handleDoubleFingerDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
            switch gestureRecognizer.state {
            case .began:
                rotationType = .rotation4D
            case .changed:
                let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
                let deltaX = translation.x
                let deltaY = -translation.y
                let axisAngle = atan2InDegree(deltaY, deltaX)
                let rotationAngle = atanInDegree(hypot(deltaX, deltaY) * Self.rotationSensitivity)

                let rotationMatrix =
                    Matrix.of4DRotationOnXY(byDegree: axisAngle)
                    * Matrix.of4DRotationOnWX(byDegree: -rotationAngle)
                    * Matrix.of4DRotationOnXY(byDegree: -axisAngle)

                cameraPosition = cameraPosition.rotate(by: rotationMatrix)
                gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
            case .ended:
                rotationType = nil
            default:
                break
            }
        }
    }
}
