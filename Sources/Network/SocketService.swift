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
    func debug(message: String)
}

public protocol SocketService {
    func connect(url: URL, delegate: SocketServiceDelegate, headers: [String: String])
    func disconnect()
    func send(text: String)
    func send(data: Data)
}

public class DefaultSocketService: NSObject, SocketService, URLSessionWebSocketDelegate {
    
    private var isConnected = false
    private var socket: URLSessionWebSocketTask?
    private weak var delegate: SocketServiceDelegate?
    private var heartbeatTimer: Timer?
    private var url: URL?
    private var headers: [String: String]?
    private let keepaliveInterval: Int
    
    public init(keepaliveInterval: Int = 60) {
        self.keepaliveInterval = keepaliveInterval
    }
    
    private func debug(message: String) {
        self.delegate?.debug(message: message)
    }

    // MARK: Connecting
    
    /// Connect to the socket
    ///
    /// - Parameters:
    ///   - url: the endpoint url
    ///   - delegate: callback url
    ///   - headers: any headers such as auth headers you might want to add on
    public func connect(url: URL, delegate: SocketServiceDelegate, headers: [String: String]) {
        self.delegate = delegate
        self.url = url
        self.headers = headers
        if !isConnected {
            var request = URLRequest(url: url)
            headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key)}
            
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let webSocket = session.webSocketTask(with: request)
            webSocket.resume()
            self.socket = webSocket
            
            // On connection, the URLSessionWebSocketDelegate.didOpen will be called
        } else {
            debug(message: "Already connected")
        }
    }
    
    // This is called on some errors
    // Probably cases that this doesn't cover
    private func forceReconnect() {
        if(isConnected) {
            disconnect(closeCode: .goingAway)
        }
        if let url = self.url, let delegate = self.delegate, let headers = self.headers {
            print("Going to connect from forceReconnect")
            connect(url: url, delegate: delegate, headers: headers)
        }
    }
    
    // URLSessionWebSocketDelegate
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Socket open \(Date())")
        DispatchQueue.main.async {
            self.isConnected = true
            //self.startHeartbeat()
            self.listen()
            self.delegate?.onConnect(socket: self)
        }
    }
    
    // MARK: Heartbeat
    
    private func startHeartbeat() {
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
        socket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                // This is untested - 8 June 2022
                self.delegate?.onError(connection: self, error: FoundationError.SocketError(details: "Heartbeat Error", error: error))
            }
        })
    }
    
    // MARK: Incoming Listener
    
    private func listen() {
        socket?.receive { result in
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
    
    public func disconnect() {
        disconnect(closeCode: .normalClosure)
    }
    
    /// Force a disconnect
    private func disconnect(closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure) {
        socket?.cancel(with: closeCode, reason: nil)
        self.heartbeatTimer?.invalidate()
        isConnected = false
        // On closing socket, the URLSessionWebSocketDelegate.didCloseWith will be called
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
            self.isConnected = false
            self.delegate?.onDisconnect(socket: self,  closeCode: closeCode, error: FoundationError.SocketError(details: reasonString, error: nil))
        }
    }
    
    // MARK: Sending Data
    
    public func send(text: String) {
        if !isConnected {
            let error = FoundationError.SocketNotConnectedError(details: "Tried to send text when not connected")
            self.delegate?.onError(connection: self, error: error)
        } else {
            socket?.send(URLSessionWebSocketTask.Message.string(text)) { error in
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
            socket?.send(URLSessionWebSocketTask.Message.data(data)) { error in
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
        case 53, 54, 57:
            forceReconnect() // <-- timing won't let this work
        default:
            break
            
        }
    }
    
    // General socket closing errors
    // URLSessionWebSocketDelegate
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Socket ended \(Date())")
        if let error = error {
            self.delegate?.onError(connection: self, error: FoundationError.SocketEndedError(details: "Socket completed", error: error))
        }
    }
    
}
