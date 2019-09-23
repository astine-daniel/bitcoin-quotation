import Combine
import Dispatch
import Foundation

struct APIService {
    // MARK: Type alias
    typealias Completion<T> = (Result<T, Error>) -> Void

    // MARK: - Properties
    private let session: URLSessionProtocol
    private let queue: DispatchQueue?

    // MARK: - Initialization
    init(session: URLSessionProtocol = URLSession.shared,
         queue: DispatchQueue? = nil) {
        self.session = session
        self.queue = queue
    }
}

// MARK: - APIServiceProtocol extension
extension APIService: APIServiceProtocol {
    @discardableResult
    public func request<T>(_ resource: Resource) -> AnyPublisher<T, NetworkingError> where T: Decodable {
        do {
            let urlRequest = try resource.asURLRequest()
            return session.dataTaskPublisher(for: urlRequest)
                .tryMap { (data: Data, response: URLResponse) in
                    try self.handle(resource: resource, data: data, response: response)
                }
                .mapError {
                    guard let error = $0 as? NetworkingError else {
                        return NetworkingError.unexpected(error: $0)
                    }

                    return error
                }
                .receive(on: queue ?? .main)
                .eraseToAnyPublisher()
        } catch let error as NetworkingError {
            return Future { (subscriber: @escaping (Result<T, NetworkingError>) -> Void) in
                subscriber(.failure(error))
            }.receive(on: queue ?? .main).eraseToAnyPublisher()
        } catch {
            return Future { (subscriber: @escaping (Result<T, NetworkingError>) -> Void) in
                subscriber(.failure(.unexpected(error: error)))
            }.receive(on: queue ?? .main).eraseToAnyPublisher()
        }
    }
}

// MARK: - Private extension
private extension APIService {
    func handle<T>(resource: Resource, data: Data?, response: URLResponse?) throws -> T where T: Decodable {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkingError.unknown
        }

        return try handle(resource: resource, data: data, response: response)
    }

    func handle<T>(resource: Resource, data: Data?, response: HTTPURLResponse) throws -> T where T: Decodable {
        guard let error = NetworkingError.error(from: response.statusCode) else {
            return try handle(resource: resource, data: data)
        }

        throw error
    }

    func handle<T>(resource: Resource, data: Data?) throws -> T where T: Decodable {
        do {
            let response: T = try resource.parser.parse(data)
            return response
        } catch {
            throw error
        }
    }

    func handle<T>(
        resource: Resource,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        _ completion: @escaping Completion<T>) where T: Decodable {
        guard error == nil else {
            handle(error: error!, response: response, completion)
            return
        }

        guard let response = response as? HTTPURLResponse else {
            completion(.failure(NetworkingError.unknown))
            return
        }

        handle(resource: resource, response: response, data: data, completion)
    }

    func handle<T>(
        error: Error,
        response: URLResponse?,
        _ completion: @escaping Completion<T>) where T: Decodable {
        guard response == nil else {
            completion(.failure(error))
            return
        }

        completion(.failure(error))
    }

    func handle<T>(
        resource: Resource,
        response: HTTPURLResponse,
        data: Data?,
        _ completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        guard let error = NetworkingError.error(from: response.statusCode) else {
            handle(resource: resource, data: data, completion)
            return
        }

        completion(.failure(error))
    }

    func handle<T>(
        resource: Resource,
        data: Data?,
        _ completion: @escaping Completion<T>) where T: Decodable {
        do {
            let response: T = try resource.parser.parse(data)
            completion(.success(response))
        } catch {
            completion(.failure(error))
        }
    }
}
