//
//  SocketService.swift
//  WebSocketTest
//
//  Created by David Casserly on 06/06/2022.
//

import Foundation
import DevedUpSwiftFoundation

public protocol SocketServiceDelegate: AnyObject {
    func onConnect(socket: SocketService)
    func onDisconnect(socket: SocketService, closeCode: URLSessionWebSocketTask.CloseCode, error: ErrorType?)
    func onError(connection: SocketService, error: ErrorType)
    func onMessage(connection: SocketService, text: String)
    func onMessage(connection: SocketService, data: Data)
    func onHeartBeat(connection: SocketService)
}

public protocol SocketService {
    var isConnected: Bool { get }
    func connect(url: URL, delegate: SocketServiceDelegate, headers: [String: String])
    func disconnect()
    func send(text: String)
    func send(data: Data)
}

public class DefaultSocketService: NSObject, SocketService, URLSessionWebSocketDelegate {
    
    private let serialSocketQueue = DispatchQueue(label: "devedup.socket.service") // Serial is default
    
    public private (set) var isConnected = false
    private var socket: URLSessionWebSocketTask?
    private weak var delegate: SocketServiceDelegate?
    private var heartbeatTimer: Timer?
    private var url: URL?
    private var headers: [String: String]?
    private let keepaliveInterval: Int
    
    public init(keepaliveInterval: Int = 30) {
        self.keepaliveInterval = keepaliveInterval
    }

    // MARK: Connecting
    
    /// Connect to the socket
    ///
    /// - Parameters:
    ///   - url: the endpoint url
    ///   - delegate: callback url
    ///   - headers: any headers such as auth headers you might want to add on
    public func connect(url: URL, delegate: SocketServiceDelegate, headers: [String: String]) {
        serialSocketQueue.async {
            self.delegate = delegate
            self.url = url
            self.headers = headers
            if !self.isConnected {
                var request = URLRequest(url: url)
                headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
                
                // 10 minutes is the AWS timeout
                // I can't seem to set 600 on the configuration.. it ignores it
                let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
                let webSocket = session.webSocketTask(with: request)
                webSocket.resume()
                self.socket = webSocket
                self.isConnected = true
                // On connection, the URLSessionWebSocketDelegate.didOpen will be called
            } else {
                print("Already connected")
            }
        }
    }
    
    // This is called on some errors
    // Probably cases that this doesn't cover
//    private func reconnect() {
//        if let url = self.url, let delegate = self.delegate, let headers = self.headers {
//            print("Going to connect from forceReconnect")
//            connect(url: url, delegate: delegate, headers: headers)
//        }
//    }
    
    // URLSessionWebSocketDelegate
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Socket open \(Date())")
        DispatchQueue.main.async {
            self.startHeartbeat()
            self.listen()
            self.delegate?.onConnect(socket: self)
        }
    }
    
    // MARK: Heartbeat
    
    private func startHeartbeat() {
        self.heartbeatTimer?.invalidate()
        self.heartbeatTimer = nil
        let interval = Double(keepaliveInterval)
        let timer = Timer(timeInterval: interval, repeats: true, block: { [weak self] timer in
            self?.heartbeat()
        })
        // i.e. have it on something other than main thread so UI doesn't block it
        RunLoop.current.add(timer, forMode: .common)
        self.heartbeatTimer = timer
    }
    
    private func heartbeat() {
        print("Sending socket hearbeat \(Date())")
        self.delegate?.onHeartBeat(connection: self)
        socket?.sendPing(pongReceiveHandler: { [weak self] error in
            if let error = error {
                guard let self = self else { return }
                self.handleError(error)
            }
        })
    }
    
    // MARK: Incoming Listener
    
    private func listen() {
        socket?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.handleError(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.delegate?.onMessage(connection: self, text: text)
                case .data(let data):
                    self.delegate?.onMessage(connection: self, data: data)
                @unknown default:
                    fatalError()
                }
                
                self.listen()
            }
        }
    }
    
    // MARK: Disconnecting
    
    /// Force a disconnect
    public func disconnect() {
        serialSocketQueue.async {
            // if internet offline, the cancel call won't work
            self.socket?.cancel(with: .goingAway, reason: nil)
            self.heartbeatTimer?.invalidate()
            self.isConnected = false
            // On closing socket, the URLSessionWebSocketDelegate.didCloseWith will be called
        }
        
    }
    
    // URLSessionWebSocketDelegate
    public func urlSession(_ session: URLSession,
                           webSocketTask: URLSessionWebSocketTask,
                           didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                           reason: Data?) {
        
        print("Socket closed \(Date())")
        let reasonString: String
        if let reason = reason, let string = String(data: reason, encoding: .utf8) {
            reasonString = string
        } else {
            reasonString = ""
        }
        //            switch closeCode {
        //            case .normalClosure, .goingAway:
        //                reconnect()
        //            default:
        //                break
        //            }
        DispatchQueue.main.async {
            self.delegate?.onDisconnect(socket: self,  closeCode: closeCode, error: FoundationError.SocketError(details: reasonString, error: nil))
        }
    }
    
    // MARK: Sending Data
    
    public func send(text: String) {
        if !isConnected {
            let error = FoundationError.SocketNotConnectedError(details: "Tried to send text when not connected")
            self.delegate?.onError(connection: self, error: error)
        } else {
            socket?.send(URLSessionWebSocketTask.Message.string(text)) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.handleError(error)
                }
            }
        }
    }
    
    public func send(data: Data) {
        if !isConnected {
            let error = FoundationError.SocketNotConnectedError(details: "Tried to send data when not connected")
            self.delegate?.onError(connection: self, error: error)
        } else {
            socket?.send(URLSessionWebSocketTask.Message.data(data)) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.handleError(error)
                }
            }
        }
    }
    
    // MARK: Error handling
    
    // Send and listen errors
    private func handleError(_ error: Error) {
        delegate?.onError(connection: self, error: FoundationError.SocketError(details: nil, error: error))
        let code = (error as NSError).code
        // 57 Socket is not connected
        // 53 Software cuased connection abort
        switch code {
        case 53, 54, 57, 60:
            // if you call disconnect() here and there is no internet, it gets itself into an endless loop
            // of try, callback fail, try, callback fail...
            self.disconnect()
            self.delegate?.onDisconnect(socket: self, closeCode: .abnormalClosure, error: nil)
        default:
            break
        }
    }
    
    // General socket closing errors
    // URLSessionWebSocketDelegate
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Socket ended \(Date())")
        guard let error = error as? URLError else { return }
            
        switch error.errorCode {
        // offline, timedOut
        case -1009, -1001:
            self.disconnect()
            self.delegate?.onDisconnect(socket: self, closeCode: .abnormalClosure, error: FoundationError.SocketEndedError(details: "Socket completed", error: error))
        default:
            self.delegate?.onError(connection: self, error: FoundationError.SocketEndedError(details: "Socket completed", error: error))
        }
    }
    
}
