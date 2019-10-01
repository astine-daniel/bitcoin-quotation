import SwiftUI

struct LineChartView: View {
    private class LineSize {
        var value: CGSize = .zero
    }

    // MARK: - Properties
    @ObservedObject var data: ChartData

    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private var didSelectDataAtIndex: ((Int) -> Void)?

    @State private var touchLocation: CGPoint = .zero
    private let lineSize = LineSize()
    @State private var showIndicatorDot: Bool = false
    @State private var currentValue: Decimal? {
        didSet {
            guard oldValue != currentValue && showIndicatorDot else { return }
            selectionFeedbackGenerator.selectionChanged()
        }
    }

    // MARK: - Initialization
    init(data: [Decimal], didSelectDataAtIndex: ((Int) -> Void)? = nil) {
        self.data = ChartData(points: data)
        self.didSelectDataAtIndex = didSelectDataAtIndex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if data.points.isEmpty == false {
                GeometryReader { (geometry: GeometryProxy) -> LineView in
                    let frame = geometry.frame(in: .local)
                    self.lineSize.value = frame.size

                    return LineView(data: self.data,
                                    frame: .constant(frame),
                                    touchLocation: self.$touchLocation,
                                    showIndicator: self.$showIndicatorDot)
                }
                .frame(minHeight: 150)
                .padding([.leading, .bottom, .trailing], 10)
            }
        }
        .padding(20)
        .background(Color(UIColor(dynamicProvider: {
            switch $0.userInterfaceStyle {
            case .dark: return .black
            default: return .white
            }
        })))
        .gesture(DragGesture()
            .onChanged {
                self.touchLocation = $0.location
                self.showIndicatorDot = true

                self.udpateCurrentValue(to: $0.location)
            }
            .onEnded { _ in
                self.showIndicatorDot = false
            }
        )
    }
}

private extension LineChartView {
    func udpateCurrentValue(to: CGPoint) {
        let size = lineSize.value
        let stepWidth = size.width / CGFloat(data.points.count - 1)

        let index = Int(round(to.x) / stepWidth)
        guard index >= 0 && index < data.points.count else { return }

        didSelectDataAtIndex?(index)
    }
}

extension CGFloat {
    init(_ value: Decimal) {
        self.init(NSDecimalNumber(decimal: value).doubleValue)
    }
}

// MARK: - Line
private struct LineView: View {
    // MARK: - Properties
    @ObservedObject var data: ChartData
    @Binding var frame: CGRect
    @Binding var touchLocation: CGPoint
    @Binding var showIndicator: Bool

    @State private var showFull: Bool = false
    @State var showBackground: Bool = false

    var stepWidth: CGFloat { frame.size.width / CGFloat(data.points.count - 1) }
    var stepHeight: CGFloat { frame.size.height / CGFloat(data.points.max()! + data.points.min()!) }

    var path: Path {
        .quadCurvedPathWithPoints(points: data.points.map(CGFloat.init),
                                  step: CGPoint(x: stepWidth, y: stepHeight))
    }
    var closedPath: Path {
        .quadClosedCurvedPathWithPoints(points: data.points.map(CGFloat.init),
                                        step: CGPoint(x: stepWidth, y: stepHeight))
    }

    var body: some View {
        ZStack {
            if showFull && showBackground {
                closedPath
                    .fill(Color(.systemBlue))
                    .rotationEffect(.degrees(180.0), anchor: .center)
                    .rotation3DEffect(.degrees(180.0), axis: (x: 0.0, y: 1.0, z: 0.0))
                    .transition(.opacity)
                    .animation(.easeIn(duration: 1.6))
            }

            path.stroke(Color(.systemBlue))
                .rotationEffect(.degrees(180.0), anchor: .center)
                .rotation3DEffect(.degrees(180.0), axis: (x: 0.0, y: 1.0, z: 0.0))
                .animation(.easeOut(duration: 1.2))
                .onAppear {
                    self.showFull.toggle()
                }

            if self.showIndicator {
                IndicatorPoint()
                    .position(closestPointOnPath(to: touchLocation))
                    .rotationEffect(.degrees(180.0), anchor: .center)
                    .rotation3DEffect(.degrees(180.0), axis: (x: 0, y: 1, z: 0))
            }
        }
    }
}

private extension LineView {
    func closestPointOnPath(to: CGPoint) -> CGPoint {
        let percentage = min(max(to.x, 0.0) / frame.width, 1)
        let closest = path.percentPoint(percentage)

        return closest
    }
}

private struct IndicatorPoint: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.systemPink))
            Circle()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4.0))
        }
        .frame(width: 14.0, height: 14.0)
        .shadow(color: Color(.systemGray4), radius: 5.0, x: 0.0, y: 2.0)
    }
}

// MARK: - Preview
#if DEBUG
struct LineChartViewPreviews: PreviewProvider {
    static var previews: some View {
        LineChartView(data: [2, 3, 10, 50, 34, 100, 8, 4, 1])
    }
}
#endif
