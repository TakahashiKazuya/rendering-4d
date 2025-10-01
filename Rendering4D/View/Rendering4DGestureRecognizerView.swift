import SwiftUI

struct Rendering4DGestureRecognizerView: UIViewRepresentable {
    @Binding var cameraPosition: CameraPosition4D

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

        return view
    }

    func updateUIView(_ view: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(cameraPosition: $cameraPosition)
    }

    class Coordinator {
        static let rotationSensitivity: Double = 0.008

        @Binding var cameraPosition: CameraPosition4D

        init(cameraPosition: Binding<CameraPosition4D>) {
            self._cameraPosition = cameraPosition
        }

        @objc func handleDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
            switch gestureRecognizer.state {
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
            default:
                break
            }
        }
    }
}
