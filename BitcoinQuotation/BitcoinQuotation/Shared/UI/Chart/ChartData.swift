import Foundation

final class ChartData: ObservableObject {
    // MARK: - Properties
    @Published var points = [Decimal]()
    @Published var currentPoint: Decimal?

    // MARK: - Initialization
    init(points: [Decimal]) {
        self.points = points
    }
}
