import Common
import Foundation

struct BlockchainResource {
    // MARK: - Initialization
    private init(baseURL: URLConvertible,
                 version: String? = nil,
                 method: HTTPMethod = .get,
                 endpoint: Endpoint,
                 parser: ResourceParser) {
        self.baseURL = baseURL
        self.version = version
        self.method = method
        self.endpoint = endpoint
        self.parser = parser
    }

    // MARK: - Properties
    private (set) var baseURL: URLConvertible
    private (set) var version: String?
    private (set) var method: HTTPMethod
    private (set) var endpoint: Endpoint
    private (set) var parser: ResourceParser
}

// MARK: - Resource extension
extension BlockchainResource: Resource { }

// MARK: - Methods
extension BlockchainResource {
    static func marketPriceChartData(ofLast days: Int,
                                     serviceInfo: APIServiceInfoProtocol = APIServiceInfo.default) -> BlockchainResource {
        let queryItems: [URLQueryItem] = [
            .resultFormat(value: serviceInfo.resultFormat),
            .timespan(days: days)
        ]

        let endpoint = Endpoint(path: "charts/market-price", queryItems: queryItems)
        let parser = ClosureResourceParser(Self.parser)

        return BlockchainResource(baseURL: serviceInfo.baseURL,
                                  endpoint: endpoint,
                                  parser: parser)
    }
}

private extension BlockchainResource {
    typealias ChartData = ResponseModel.ChartData

    // MARK: - Parser
    static func parser(data: Data?) throws -> ChartData {
        guard let data = data else { return ChartData(unit: "USD", period: "day", values: []) }

        let decoder = JSONDecoder()
        return try decoder.decode(ChartData.self, from: data)
    }
}

private extension URLQueryItem {
    static func timespan(days: Int) -> URLQueryItem {
        func timespan(from value: Int) -> String {
            guard value >= 0 else { return "0days" }
            return "\(value)days"
        }

        return URLQueryItem(name: "timespan", value: timespan(from: days))
    }
}
