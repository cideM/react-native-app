//
//  RESTClient.swift
//  Networking
//
//  Created by CSH on 29.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Foundation
import Domain

internal final class RESTClient: NSObject {

    private lazy var urlSession: URLSession = {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        return session
    }()

    private lazy var backgroundUrlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "RESTClient_backgroundUrlSession")
        config.allowsCellularAccess = false
        config.waitsForConnectivity = false
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    /// The url of the REST server.
    private let baseUrl: URL

    /// The Authorization of the current user if any
    private var authToken: String?

    /// The Authorization header for every request. This can be used to setup basic authorization.
    private var authorizationHeader: String?

    /// The UserAgent that should be sent along with every request.
    private let userAgent: RESTUserAgent

    weak var downloadDelegate: DownloadDelegate?

    private var ignoreErrorsForDataTasks = Set<Int>()

    init(baseUrl: URL, authToken: String?, authorizationHeader: String? = "Basic dGVzdDpnYXVjaG8=", userAgent: RESTUserAgent) {
        self.baseUrl = baseUrl
        self.authToken = authToken
        self.authorizationHeader = authorizationHeader
        self.userAgent = userAgent
        super.init()
    }

    func setAutToken(_ token: String?) {
        urlSession.getAllTasks {
            $0.forEach { $0.cancel() }
        }
        self.authToken = token
    }

    func signup(signupInput: SignupRequestInput, deviceId: String, completion: @escaping Completion<Void, NetworkError<SignupAPIError>>) {
        let completion = DispatchQueue.main.captureAsync(completion)

        let jsonEndoder = JSONEncoder()
        var body: [String: Any]
        do {
            let bodyData = try jsonEndoder.encode(signupInput)
            body = (try JSONSerialization.jsonObject(with: bodyData) as? [String: Any]) ?? [:]

        } catch {
            completion(.failure(.invalidFormat(error.localizedDescription)))
            return
        }

        let headers = ["Miamed-Device-ID": deviceId]

        post(path: "2.2/authentication/register", body: body, headers: headers) { data, response, error in
            if response?.statusCode == 200 || response?.statusCode == 201 {
                completion(.success(()))
            } else if let data = data,
                let string = String(data: data, encoding: .utf8),
                string.contains("EMAIL_ADDRESS_ALREADY_REGISTERED") {
                let networkError = NetworkError<SignupAPIError>.apiResponseError([.emailAlreadyRegistered])
                completion(.failure(networkError))
            } else if let error = error {
                let networkError = NetworkErrorConverter<SignupAPIError>.networkError(from: error)
                completion(.failure(networkError))
            } else if let data = data,
                let string = String(data: data, encoding: .utf8) {
                completion(.failure(.other("Unknown Error. The server responded with: \(string)")))
            } else {
                completion(.failure(.other("Unknown Error")))
            }
        }
    }

    func login(loginInput: LoginRequestInput, deviceId: String, completion: @escaping Completion<LoginResponse.Authentication, NetworkError<LoginAPIError>>) {
        let completion = DispatchQueue.main.captureAsync(completion)

        let jsonEndoder = JSONEncoder()
        var body: [String: Any]
        do {
            let bodyData = try jsonEndoder.encode(loginInput)
            body = (try JSONSerialization.jsonObject(with: bodyData) as? [String: Any]) ?? [:]

        } catch {
            completion(.failure(.invalidFormat(error.localizedDescription)))
            return
        }

        let headers = ["Miamed-Device-ID": deviceId]

        post(path: "2.2/authentications/", body: body, headers: headers) { data, response, error in
            if response?.statusCode == 200 || response?.statusCode == 201, let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let authenticationResponse = try decoder.decode(LoginResponse.self, from: data)
                    completion(.success(authenticationResponse.authentication))
                } catch {
                    completion(.failure(.invalidFormat(error.localizedDescription)))
                }
            } else if let data = data, let loginError = try? JSONDecoder().decode(LoginError.self, from: data) {
                completion(.failure(.apiResponseError([.other(loginError.error.message)])))
            } else if let error = error {
                let networkError = NetworkErrorConverter<LoginAPIError>.networkError(from: error)
                completion(.failure(networkError))
            } else {
                completion(.failure(.other("Unknown Error")))
            }
        }
    }

    func logout(deviceId: String, completion: @escaping Completion<Void, NetworkError<LogoutAPIError>>) {
        let completion = DispatchQueue.main.captureAsync(completion)

        let headers = ["Miamed-Device-ID": deviceId]

        delete(path: "/2.2/authentications/this", headers: headers) { _, response, error in
            if response?.statusCode == 204 {
                completion(.success(()))
            } else if let error = error {
                let networkError = NetworkErrorConverter<LogoutAPIError>.networkError(from: error)
                completion(.failure(networkError))
            } else {
                completion(.failure(.other("Unknown Error")))
            }
        }
    }

    func downloadFile(at url: URL, isUserInitiated: Bool, countOfBytesClientExpectsToReceive: Int64?) {
        assert(downloadDelegate != nil, "Set a download delegate to recieve the download result.")
        backgroundUrlSession.getAllTasks { [weak self] backgroundTasks in
            self?.urlSession.getAllTasks { [weak self] foregroundTasks in
                let tasks = backgroundTasks + foregroundTasks
                let alreadyRunningTask = tasks.first { [$0.currentRequest?.url, $0.originalRequest?.url].contains(url) }
                if let alreadyRunningTask = alreadyRunningTask {
                    // Elevate task above background session in case the user has triggered it again it failed or stalled
                    // This seems the only way to make it run on any network connection (cellular and wifi)
                    // URLSessionConfiguration.allowsCellularAccess = true still stalls the task on LTE (reason unclear)
                    // Hence this approach was not taken
                    if isUserInitiated && backgroundTasks.contains(alreadyRunningTask) {
                        // Only way to inhibit the delegate error callback for the canceled task is to filter it in the delegate
                        // Hence its added to the ignoreErrorsForDataTasks set
                        // The task is still there on the foreground session hence we dont want to report an error
                        self?.ignoreErrorsForDataTasks.insert(alreadyRunningTask.taskIdentifier)
                        alreadyRunningTask.cancel()
                        self?._downloadFile(at: url, isUserInitiated: isUserInitiated, countOfBytesClientExpectsToReceive: countOfBytesClientExpectsToReceive)
                    } else {
                        self?.downloadDelegate?.downloadClientDidMakeProgress(source: url, progress: alreadyRunningTask.progress.fractionCompleted)
                    }

                } else {
                    self?._downloadFile(at: url, isUserInitiated: isUserInitiated, countOfBytesClientExpectsToReceive: countOfBytesClientExpectsToReceive)
                }
            }
        }
    }

    private func _downloadFile(at url: URL, isUserInitiated: Bool, countOfBytesClientExpectsToReceive: Int64?) {
        assert(downloadDelegate != nil, "Set a download delegate to recieve the download result.")
        let urlSession = isUserInitiated ? self.urlSession : backgroundUrlSession
        let task = urlSession.downloadTask(with: url)

        if let countOfBytesClientExpectsToReceive = countOfBytesClientExpectsToReceive {
            task.countOfBytesClientExpectsToSend = 200
            task.countOfBytesClientExpectsToReceive = countOfBytesClientExpectsToReceive
        }

        task.resume()
    }

    func downloadData(at url: URL, completion: @escaping Completion<Data, NetworkError<EmptyAPIError>>) {
        let completion = DispatchQueue.main.captureAsync(completion)
        let task = urlSession.dataTask(with: url) { data, _, error in
            if let error = error {
                let networkError = NetworkErrorConverter<EmptyAPIError>.networkError(from: error)
                completion(.failure(networkError))
            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.other("Unknown Error")))
            }
        }
        task.resume()
    }
}

extension RESTClient {

    // unused:ignore get
    private func get(path: String, parameters: [String: String], completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent(path).setting(query: parameters)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = defaultHTTPHeaderFields()
        let task = urlSession.dataTask(with: request) { data, response, error in
            completionHandler(data, response as? HTTPURLResponse, RESTError(data) ?? error)
        }
        task.resume()
    }

    private func post(path: String, body: [String: Any], headers: [String: String] = [:], completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let data = try? JSONSerialization.data(withJSONObject: body, options: [])
        post(path: path, body: data, headers: headers, completionHandler: completionHandler)
    }

    private func post(path: String, body: Data?, headers: [String: String] = [:], completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        var request = URLRequest(url: baseUrl.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.httpBody = body
        request.allHTTPHeaderFields = defaultHTTPHeaderFields().merging(headers) { $1 }
        let task = urlSession.dataTask(with: request) { data, response, error in
            completionHandler(data, response as? HTTPURLResponse, RESTError(data) ?? error)
        }
        task.resume()
    }

    private func delete(path: String, headers: [String: String] = [:], completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        var request = URLRequest(url: baseUrl.appendingPathComponent(path))
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = defaultHTTPHeaderFields().merging(headers) { $1 }
        let task = urlSession.dataTask(with: request) { data, response, error in
            completionHandler(data, response as? HTTPURLResponse, RESTError(data) ?? error)
        }
        task.resume()
    }

    private func defaultHTTPHeaderFields() -> [String: String] {
        var headers: [String: String] = [
            "Accept": "application/miamed.api+json",
            "Content-Type": "application/json",
            "Date": DateFormatter.rfc1123.string(from: Date()),
            "User-Agent": userAgent.asString,
            "Accept-Language": Bundle.main.preferredLocalizations.first! // swiftlint:disable:this force_unwrapping
        ]

        if let token = authToken {
            headers["Miamed-Auth-Token"] = token
        }

        if let authorizationHeader = authorizationHeader {
            headers["Authorization"] = authorizationHeader
        }

        return headers
    }
}

extension RESTClient: URLSessionDownloadDelegate, URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let requestedUrl = downloadTask.originalRequest?.url else {
            assertionFailure("Could not read the url from the URLSessionDownloadTask. This is not expected to ever happen.")
            return
        }
        guard totalBytesWritten > 0 else { return }

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        downloadDelegate?.downloadClientDidMakeProgress(source: requestedUrl, progress: progress)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let requestedUrl = downloadTask.originalRequest?.url else {
            assertionFailure("Could not read the url from the URLSessionDownloadTask. This is not expected to ever happen.")
            return
        }
        downloadDelegate?.downloadClientDidFinish(source: requestedUrl, destination: location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if ignoreErrorsForDataTasks.remove(task.taskIdentifier) != nil {
            return
        }

        guard let error = error else { return }
        guard let requestedUrl = task.originalRequest?.url else {
            assertionFailure("Could not read the url from the URLSessionDownloadTask. This is not expected to ever happen.")
            return
        }
        downloadDelegate?.downloadClientDidFail(source: requestedUrl, error: error)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        downloadDelegate?.downloadClientDidFinishEventsForBackgroundURLSession()
    }
}
