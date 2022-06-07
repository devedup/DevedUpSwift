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

public class DefaultSocketService: NSObject, SocketService {
    
    private var isConnected = false
    private var socket: URLSessionWebSocketTask?
    private weak var delegate: SocketServiceDelegate?
    private var heartbeatTimer: Timer?
    private var url: URL?
    private var headers: [String: String]?
    
    private func debug(message: String) {
        self.delegate?.debug(message: message)
    }

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
        } else {
            debug(message: "already connected")
        }
    }
            
    public func disconnect() {
        socket?.cancel(with: .goingAway, reason: nil)
        self.heartbeatTimer?.invalidate()
        if isConnected {
            isConnected = false
            self.delegate?.onDisconnect(socket: self, closeCode: .goingAway, error: nil)
        }
    }
    
    private func socketDidConnect() {
        isConnected = true
        listen()
        startHeartbeat()
        self.delegate?.onConnect(socket: self)
    }
    
    private func tryReconnect() {
        if !isConnected {
            if let url = self.url, let delegate = self.delegate, let headers = self.headers {
                connect(url: url, delegate: delegate, headers: headers)
            }
        }
    }
    
    private func socketDidDisconnect(reason: String, closeCode: URLSessionWebSocketTask.CloseCode) {
        if isConnected {
            isConnected = false
            self.delegate?.onDisconnect(socket: self,  closeCode: closeCode, error: FoundationError.SocketError(details: reason, error: nil))
            
//            switch closeCode {
//            case .normalClosure, .goingAway:
//                reconnect()
//            default:
//                break
//            }
        }
        print("URLSessionWebSocketTask is closed: code=\(closeCode), reason=\(reason)")
    }
    
    private func startHeartbeat() {
        let timer = Timer(timeInterval: 5, repeats: true, block: { [weak self] timer in
            self?.heartbeat()
        })
        RunLoop.current.add(timer, forMode: .common) // i.e. have it on something other than main thread so UI doesn't block it
        self.heartbeatTimer = timer
    }
    
    private func heartbeat() {
        print("Sending hearbeat")
        socket?.sendPing(pongReceiveHandler: { error in
                
        })
    }
    
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
    
    public func send(text: String) {
        if !isConnected {
            self.delegate?.onError(connection: self, error: FoundationError.SocketError(details: "not Connected", error: nil))
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
            self.delegate?.onError(connection: self, error: FoundationError.SocketError(details: "not Connected", error: nil))
        } else {
            socket?.send(URLSessionWebSocketTask.Message.data(data)) { error in
                if let error = error {
                    self.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        delegate?.onError(connection: self, error: FoundationError.SocketError(details: nil, error: error))
        let code = (error as NSError).code
        // 57 Socket is not connected
        // 53 Software cuased connection abort
        switch code {
        case 53, 54, 57:
            tryReconnect()
        default:
            break
            
        }
        print(error)
    }
    
}

extension DefaultSocketService: URLSessionWebSocketDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.delegate?.onError(connection: self, error: FoundationError.SocketError(details: nil, error: error))
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            self.socketDidConnect()
        }
    }
    
    public func urlSession(_ session: URLSession,
                           webSocketTask: URLSessionWebSocketTask,
                           didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                           reason: Data?) {
        
        let reasonString: String
        if let reason = reason, let string = String(data: reason, encoding: .utf8) {
            reasonString = string
        } else {
            reasonString = ""
        }
        DispatchQueue.main.async {
            self.socketDidDisconnect(reason: reasonString, closeCode: closeCode)
        }
    }
    
}
