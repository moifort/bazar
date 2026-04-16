import SwiftUI

struct ViewfinderOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width * 0.85
            let height = geo.size.height * 0.5
            let x = (geo.size.width - width) / 2
            let y = (geo.size.height - height) / 2

            let cutoutRect = CGRect(x: x, y: y, width: width, height: height)

            Canvas { context, size in
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(.black.opacity(0.3))
                )
                context.blendMode = .clear
                context.fill(
                    Path(roundedRect: cutoutRect, cornerRadius: 24),
                    with: .color(.white)
                )
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()

            CornerBrackets()
                .stroke(.white.opacity(0.9), lineWidth: 3)
                .frame(width: width, height: height)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

private struct CornerBrackets: Shape {
    var armLength: CGFloat = 22

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let l = armLength

        // Top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + l))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + l, y: rect.minY))

        // Top-right
        path.move(to: CGPoint(x: rect.maxX - l, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + l))

        // Bottom-right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - l))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - l, y: rect.maxY))

        // Bottom-left
        path.move(to: CGPoint(x: rect.minX + l, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - l))

        return path
    }
}

#Preview {
    ZStack {
        Color.gray
        ViewfinderOverlay()
    }
}
