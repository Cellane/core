/// Callback for accepting a result.
public typealias FutureResultCallback<T> = (FutureResult<T>) -> ()

/// A future result type.
/// Concretely implemented by `Future<T>`
public protocol FutureType {
    associatedtype Expectation

    /// This future's result type.
    typealias Result = FutureResult<Expectation>

    func addAwaiter(callback: @escaping FutureResultCallback<Expectation>)
}

// Indirect so futures can be nested
public indirect enum FutureResult<T> {
    case error(Error)
    case success(T)

    /// Returns the result error or
    /// nil if the result contains expectation.
    public var error: Error? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }

    /// Returns the result expectation or
    /// nil if the result contains an error.
    public var result: T? {
        switch self {
        case .success(let expectation):
            return expectation
        default:
            return nil
        }
    }

    /// Throws an error if this contains an error, returns the Expectation otherwise
    public func unwrap() throws -> T {
        switch self {
        case .success(let data):
            return data
        case .error(let error):
            throw error
        }
    }
}

public extension Future {
    /// Chains a future to a promise of the same type.
    func chain(to promise: Promise<T>) {
        self.do { result in
            promise.succeed(result: result)
        }.catch { error in
            promise.fail(error: error)
        }
    }
}