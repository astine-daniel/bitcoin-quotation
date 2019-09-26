import SwiftUI

struct LineChartView: View {
    // MARK: - Properties
    @ObservedObject var data: ChartData

    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    let frameSize = CGSize(width: 180, height: 120)

    var title: String
    var legend: String?

    @State private var touchLocation: CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @State private var currentValue: Decimal? {
        didSet {
            guard oldValue != currentValue && showIndicatorDot else { return }
            selectionFeedbackGenerator.selectionChanged()
        }
    }

    // MARK: - Initialization
    init(data: [Decimal], title: String, legend: String?) {
        self.data = ChartData(points: data)
        self.title = title
        self.legend = legend
    }

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(width: frameSize.width, height: 240.0, alignment: .center)
                .shadow(radius: 8.0)

            VStack(alignment: .leading) {
                if self.showIndicatorDot == false {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.title)
                            .bold()
                            .foregroundColor(.black)

                        if legend != nil {
                            Text(legend!)
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }

                Spacer()

                GeometryReader {
                    LineView(data: self.data,
                             frame: .constant($0.frame(in: .local)),
                             touchLocation: self.$touchLocation,
                             showIndicator: self.$showIndicatorDot)
                }
                .frame(width: frameSize.width, height: frameSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
                .offset(x: 0.0, y: 0.0)
            }
            .frame(width: 180, height: 240)
        }
        .gesture(DragGesture()
        .onChanged {
            self.touchLocation = $0.location
            self.showIndicatorDot = true
        }.onEnded { _ in
            self.showIndicatorDot = false
        })
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
                      title: "LineChart",
                      legend: nil)
    }
}
#endif
