import Combine
import Core
import Dispatch
import Foundation

final class ChartDataViewModel: ObservableObject {
    // MARK: - Properties
    private let repository: BlockchainRepositoryProtocol
    private var disposable: AnyCancellable?

    @Published private (set) var values: [Model.ChartData.Value] = []
    @Published private (set) var isLoading: Bool = false

    // MARK: - Initialization
    init(repository: BlockchainRepositoryProtocol = BlockchainRepository()) {
        self.repository = repository
    }

    func loadData() {
        isLoading = true

        disposable = repository
            .fetchMarketPriceChartData(ofLast: 30)
            .receive(on: DispatchQueue.main)
            .replaceError(with: Model.ChartData(unit: "", period: "", values: []))
            .sink(receiveValue: {
                self.isLoading = false
                self.values = $0.values
            })
    }
}
