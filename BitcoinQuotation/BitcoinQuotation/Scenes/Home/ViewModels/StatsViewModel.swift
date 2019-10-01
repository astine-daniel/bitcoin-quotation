import Combine
import Core
import Dispatch
import Foundation

final class StatsViewModel: ObservableObject {
    // MARK: - Properties
    private let repository: BlockchainRepositoryProtocol
    private var disposable: AnyCancellable?

    @Published private (set) var stats: Model.Stats?
    @Published private (set) var isLoading: Bool = false

    // MARK: - Initialization
    init(repository: BlockchainRepositoryProtocol = BlockchainRepository()) {
        self.repository = repository
    }

    func loadStats() {
        isLoading = true

        disposable = repository
            .fetchStats()
            .receive(on: DispatchQueue.main)
            .replaceError(with: Model.Stats(date: Date(), marketPriceInUSD: 0))
            .sink(receiveValue: {
                self.isLoading = false
                self.stats = $0
            })
    }
}
