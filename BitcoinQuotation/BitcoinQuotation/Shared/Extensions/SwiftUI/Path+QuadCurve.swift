import SwiftUI

extension Path {
    static func quadCurvedPathWithPoints(points: [CGFloat], step: CGPoint) -> Path {
        var path = Path()

        var p1 = CGPoint(x: 0, y: points[0] * step.y)
        path.move(to: p1)

        guard points.count >= 2 else {
            path.addLine(to: CGPoint(x: step.x, y: step.y * CGFloat(points[1])))
            return path
        }

        p1 = path.addQuadCurves(from: p1, by: Array(points.dropFirst()), using: step)

        return path
    }

    static func quadClosedCurvedPathWithPoints(points: [CGFloat], step: CGPoint) -> Path {
        var path = Path()
        path.move(to: .zero)

        var p1 = CGPoint(x: 0, y: points[0] * step.y)
        path.addLine(to: p1)

        guard points.count >= 2 else {
            path.addLine(to: CGPoint(x: step.x, y: step.y * CGFloat(points[1])))
            return path
        }

        p1 = path.addQuadCurves(from: p1, by: Array(points.dropFirst()), using: step)

        path.addLine(to: CGPoint(x: p1.x, y: 0))
        path.closeSubpath()

        return path
    }

    func percentPoint(_ value: CGFloat) -> CGPoint {
        let diff: CGFloat = 0.001
        let comp: CGFloat = 1 - diff

        let percent = percentFrom(value: value)

        let from = percent > comp ? comp : percent
        let to = percent > comp ? 1 : (percent + diff)

        let trimmed = trimmedPath(from: from, to: to)

        return CGPoint(x: trimmed.boundingRect.midX, y: trimmed.boundingRect.midY)
    }
}

private extension Path {
    @discardableResult
    mutating func addQuadCurves(from: CGPoint, by points: [CGFloat], using step: CGPoint) -> CGPoint {
        var lastPoint = from
        (0..<points.count).forEach {
            let p2 = CGPoint(x: step.x * CGFloat($0), y: step.y * points[$0])
            let midPoint = lastPoint.mid(to: p2)

            addQuadCurve(to: midPoint, control: midPoint.control(to: lastPoint))
            addQuadCurve(to: p2, control: midPoint.control(to: p2))

            lastPoint = p2
        }

        return lastPoint
    }

    func percentFrom(value: CGFloat) -> CGFloat {
        guard value <= 1 else { return 0 }
        guard value >= 0 else { return 1 }
        return value
    }
}
