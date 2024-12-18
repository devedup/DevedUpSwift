//
//  SinglePeerMultipeerSession.swift
//  DevedUpSwift
//
//  Created by David Casserly on 18/12/2024.
//


import Foundation
import MultipeerConnectivity

// Another abstraction above MultipeerConnectivity class
public class SinglePeerMultipeerSession {
    
    private var mpc: MultipeerConnectivity?
    private var connectedPeer: MCPeerID?
    
    public var isConnected: Bool {
        connectedPeer != nil
    }
    
    private let onConnect: () -> Void
    private let onDisconnect: () -> Void
    private let onData: (Data) -> Void
    private let serviceName: String
    private let identityName: String
    
    deinit {
        print("removeing peer session")
    }
    
    /// - Parameters:
    ///   - serviceName: you need to add this to Bounjour info.plist item _nisample._tcp
    ///   - identityName: How to identify this session
    ///   - onConnect:
    ///   - onDisconnect:
    ///   - onData:
    public init(serviceName: String, identityName: String, onConnect: @escaping () -> Void, onDisconnect: @escaping () -> Void, onData: @escaping (Data) -> Void) {
        self.serviceName = serviceName
        self.identityName = identityName
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.onData = onData
    }
    
    public func cleanupMPC() {
        mpc?.peerDataHandler = nil
        mpc?.peerConnectedHandler = nil
        mpc?.peerDisconnectedHandler = nil
        mpc?.invalidate()
    }
    
    public func startupMPC() {
        if mpc == nil {
            // Prevent Simulator from finding devices.
#if targetEnvironment(simulator)
            mpc = MultipeerConnectivity(service: serviceName, identity: identityName, maxPeers: 0)
#endif
            mpc = MultipeerConnectivity(service: serviceName, identity: identityName, maxPeers: 1)
            mpc?.peerConnectedHandler = connectedToPeer
            mpc?.peerDataHandler = dataReceivedHandler
            mpc?.peerDisconnectedHandler = disconnectedFromPeer
        }
        mpc?.invalidate()
        mpc?.startBrowsingAndAdvertising()
    }
    
    // MARK: Data Handling
    
    public func sendData(data: Data) {
        mpc?.sendDataToAllPeers(data: data)
    }
    
    // MARK: Handler Methods
    
    private func connectedToPeer(peer: MCPeerID) {
        guard connectedPeer == nil else {
            fatalError("Already connected to a peer.")
        }
        onConnect()
        connectedPeer = peer
    }
    
    private func disconnectedFromPeer(peer: MCPeerID) {
        if connectedPeer == peer {
            connectedPeer = nil
            onDisconnect()            
        }
    }
    
    private func dataReceivedHandler(data: Data, peer: MCPeerID) {
        guard connectedPeer == peer else {
            fatalError("Received token from unexpected peer.")
        }
        onData(data)
    }
}
