import SwiftUI

struct LineChartView: View {
    // MARK: - Properties
    @ObservedObject var data: ChartData

    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    let frameSize = CGSize(width: 180, height: 120)

    var title: String

    @State private var touchLocation: CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @State private var currentValue: Decimal? {
        didSet {
            guard oldValue != currentValue && showIndicatorDot else { return }
            selectionFeedbackGenerator.selectionChanged()
        }
    }

    // MARK: - Initialization
    init(data: [Decimal], title: String) {
        self.data = ChartData(points: data)
        self.title = title
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if self.showIndicatorDot == false {
                Text(title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
            }

            GeometryReader {
                LineView(data: self.data,
                         frame: .constant($0.frame(in: .local)),
                         touchLocation: self.$touchLocation,
                         showIndicator: self.$showIndicatorDot)
            }
            .frame(minHeight: 150)
            .padding([.leading, .bottom, .trailing], 10)
        }
        .padding(20)
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

            path
                .trim(from: 0.0, to: showFull ? 1.0 : 0.0)
                .stroke(Color(.systemBlue))
                .rotationEffect(.degrees(180.0), anchor: .center)
                .rotation3DEffect(.degrees(180.0), axis: (x: 0.0, y: 1.0, z: 0.0))
                .animation(.easeOut(duration: 1.2))
                .onAppear {
                    self.showFull.toggle()
                }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct LineChartViewPreviews: PreviewProvider {
    static var previews: some View {
        LineChartView(data: [2, 3, 10, 50, 34, 100, 8, 4, 1],
                      title: "LineChart")
    }
}
#endif
