import Foundation

public protocol Resource: URLConvertible, URLRequestConvertible {
    var baseURL: URLConvertible { get }
    var version: String? { get }
    var endpoint: Endpoint { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: ResourceParameters? { get }

    var parser: ResourceParser { get }
}

// MARK: - Default implementation
public extension Resource {
    var headers: HTTPHeaders? { return nil }
    var parameters: ResourceParameters? { return nil }
    var version: String? { return nil }

    func asURL() throws -> URL {
        let baseURL = try self.baseURL.asURL()
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkingError.invalidURL(url: self)
        }

        components.path = path(with: components.path, version: version, endpointPath: endpoint.path)
        components.queryItems = endpoint.queryItems

        return try components.asURL()
    }

    func asURLRequest() throws -> URLRequest {
        let url = try asURL()

        let request = try URLRequest(url: url, method: method, headers: headers)
        guard let parameters = self.parameters else {
            return request
        }

        return try parameters.encode(on: request)
    }
}

// MARK: - Private extension
private extension Resource {
    func path(with path: String, version: String?, endpointPath: String) -> String {
        var path = path
        path.append(endpointPath)

        let pathComponents: [Substring] = path.split(separator: "/")
        path = "/"

        if let version = version, version.isEmpty == false {
            path.append(version)
            path.append("/")
        }

        let pathJoined = pathComponents.joined(separator: "/")
        path.append(pathJoined)

        return path
    }
}
