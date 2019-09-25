import Foundation

final class ChartData<T>: ObservableObject {
    // MARK: - Properties
    @Published var points = [T]()
    @Published var currentPoint: T?

    // MARK: - Initialization
    init(points: [T]) {
        self.points = points
    }
}
