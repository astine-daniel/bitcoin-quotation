import Common
import Foundation

struct MarketPriceResource {
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
extension MarketPriceResource: Resource { }

// MARK: - Methods
extension MarketPriceResource {
    static func marketPrice(ofLast days: Int = 2,
                            serviceInfo: APIServiceInfoProtocol = APIServiceInfo.default) -> MarketPriceResource {
        let queryItems: [URLQueryItem] = [
            .resultFormat(value: serviceInfo.resultFormat),
            .timespan(days: days)
        ]

        let endpoint = Endpoint(path: "charts/market-price", queryItems: queryItems)
        let parser = ClosureResourceParser(Self.parser)

        return MarketPriceResource(baseURL: serviceInfo.baseURL,
                                   endpoint: endpoint,
                                   parser: parser)
    }
}

private extension MarketPriceResource {
    typealias MarketPrice = ResponseModel.MarketPrice

    // MARK: - Parser
    static func parser(data: Data?) throws -> MarketPrice {
        guard let data = data else { return MarketPrice(unit: "USD", period: "day", values: []) }

        let decoder = JSONDecoder()
        return try decoder.decode(MarketPrice.self, from: data)
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
