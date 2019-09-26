import CoreGraphics

extension CGPoint {
    func distance(to: CGPoint) -> CGFloat {
        let squaredXDifference = pow(x - to.x, 2)
        let squaredYDifference = pow(y - to.y, 2)

        return sqrt(squaredXDifference + squaredYDifference)
    }

    func mid(to: CGPoint) -> CGPoint {
        let midX = (x + to.x) / 2
        let midY = (y + to.y) / 2

        return CGPoint(x: midX, y: midY)
    }

    func control(to: CGPoint) -> CGPoint {
        var controlPoint = mid(to: to)
        let yDifference = abs(to.y - controlPoint.y)

        if y < to.y {
            controlPoint.y += yDifference
        } else if y > to.y {
            controlPoint.y -= yDifference
        }

        return controlPoint
    }
}
