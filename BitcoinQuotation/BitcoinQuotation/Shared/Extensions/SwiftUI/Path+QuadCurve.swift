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

    func perpendicularPoint(for point: CGPoint) -> CGPoint {
        // swiftlint:disable:next nesting
        typealias ClosesPoint = (p: CGPoint, distance: CGFloat)

        let elements = calculatePointLookupTable(elements: extractPathElements())

        let closestPoint = elements
            .compactMap({ $0.pointsLookupTable })
            .flatMap({ $0 })
            .reduce(into: ClosesPoint(.zero, .greatestFiniteMagnitude)) {
                let distance = $1.linearLineLength(to: point)
                if distance < $0.distance {
                    $0 = ($1, distance)
                }
            }

        return closestPoint.p
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

    func extractPathElements() -> [PathElement] {
        var pathElements: [PathElement] = []
        var currentPoint: CGPoint = .zero

        cgPath.forEach { element in
            let type = element.type
            let points = Array(UnsafeBufferPointer(start: element.points, count: type.numberOfPoints))

            var endPoint: CGPoint = .zero
            var controlPoints: [CGPoint] = []

            switch type {
            case .moveToPoint, .addLineToPoint:
                endPoint = points[0]
            case .addQuadCurveToPoint:
                endPoint = points[1]
                controlPoints.append(points[0])
            case .addCurveToPoint:
                endPoint = points[2]
                controlPoints.append(contentsOf: points[0...1])
            case .closeSubpath:
                break
            @unknown default:
                break
            }

            if type != .closeSubpath && type != .moveToPoint {
                let pathElement = PathElement(type: type,
                                              startPoint: currentPoint,
                                              endPoint: endPoint,
                                              controlPoints: controlPoints)
                pathElements.append(pathElement)
            }

            currentPoint = endPoint
        }

        return pathElements
    }

    func calculatePointLookupTable(elements: [PathElement]) -> [PathElement] {
        var elements = elements

        let step: CGFloat = 5
        var offset = step

        elements.indices.forEach { index in
            var element = elements[index]
            var points: [CGPoint] = []

            while offset < 1 {
                points.append(element.point(at: offset))
                offset += step
            }

            if index == elements.count - 1 {
                points.append(element.point(at: 1))
            }

            offset -= 1

            if points.isEmpty {
                points.append(element.point(at: 0.5))
            }

            element.pointsLookupTable = points
            elements[index] = element
        }

        return elements
    }
}

// MARK: - Path.Element nested type
private extension Path {
    struct PathElement {
        let type: CGPathElementType

        let startPoint: CGPoint
        let endPoint: CGPoint
        let controlPoints: [CGPoint]

        var pointsLookupTable: [CGPoint]?

        init(type: CGPathElementType, startPoint: CGPoint, endPoint: CGPoint, controlPoints: [CGPoint] = []) {
            self.type = type
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.controlPoints = controlPoints
        }

        // swiftlint:disable:next identifier_name
        func point(at t: CGFloat) -> CGPoint {
            switch type {
            case .addLineToPoint:
                return startPoint.linearBezierPoint(to: endPoint, t: t)
            case .addQuadCurveToPoint:
                return startPoint
                    .quadBezierPoint(to: endPoint, controlPoint: controlPoints[0], t: t)
            case .addCurveToPoint:
                return startPoint
                    .cubicBezierPoint(to: endPoint, controlPoint1: controlPoints[0], controlPoint2: controlPoints[1], t: t)
            default:
                return .zero
            }
        }
    }
}

private extension CGPath {
    typealias Body = @convention (block)(CGPathElement) -> Void
    func forEach(body: @escaping Body) {
        func callback(_ info: UnsafeMutableRawPointer?, _ element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }

        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: callback as CGPathApplierFunction)
    }
}

private extension CGPathElementType {
    var numberOfPoints: Int {
        switch self {
        case .moveToPoint, .addLineToPoint: return 1
        case .addQuadCurveToPoint: return 2
        case .addCurveToPoint: return 3
        case .closeSubpath: return 0
        @unknown default: return 0
        }
    }
}

private extension CGPoint {
    // swiftlint:disable identifier_name
    func linearLineLength(to: CGPoint) -> CGFloat {
        return sqrt(pow(to.x - x, 2) + pow(to.y - y, 2))
    }

    func linearBezierPoint(to: CGPoint, t: CGFloat) -> CGPoint {
        let dx = to.x - x
        let dy = to.y - y

        let px = x + (t * dx)
        let py = y + (t * dy)

        return CGPoint(x: px, y: py)
    }

    func quadBezierPoint(to: CGPoint, controlPoint: CGPoint, t: CGFloat) -> CGPoint {
        let x = quadBezier(start: self.x, end: to.x, t: t, c1: controlPoint.x)
        let y = quadBezier(start: self.y, end: to.y, t: t, c1: controlPoint.y)

        return CGPoint(x: x, y: y)
    }

    func cubicBezierPoint(to: CGPoint, controlPoint1 c1: CGPoint, controlPoint2 c2: CGPoint, t: CGFloat) -> CGPoint {
        let x = cubicBezier(start: self.x, end: to.x, c1: c1.x, c2: c2.x, t: t)
        let y = cubicBezier(start: self.y, end: to.y, c1: c1.y, c2: c2.y, t: t)

        return CGPoint(x: x, y: y)
    }

    private func quadBezier(start: CGFloat, end: CGFloat, t: CGFloat, c1: CGFloat) -> CGFloat {
        let _t = 1 - t
        let _t2 = _t * _t
        let t2 = t * t

        return (_t2 * start) +
            (2 * _t * t * c1) +
            (t2 * end)
    }

    private func cubicBezier(start: CGFloat, end: CGFloat, c1: CGFloat, c2: CGFloat, t: CGFloat) -> CGFloat {
        let _t = 1 - t
        let _t2 = _t * _t
        let _t3 = _t2 * _t
        let t2 = t * t
        let t3 = t2 * t

        return (_t3 + start) +
            (3.0 * _t2 * t * c1) +
            (3.0 * _t * t2 * c2) +
            (t3 * end)
    }

    // swiftlint:enable identifier_name
}
