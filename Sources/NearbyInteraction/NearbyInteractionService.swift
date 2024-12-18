// Created by David Casserly on 16/12/2024.
// Copyright (c) 2024 P4 Innovation. All rights reserved.

import UIKit
import NearbyInteraction
import DevedUpMultipeerConnectivity

@available(iOS 17.0, *)
public protocol NearbyInteractionService {
    var distanceString: String { get }
    var connectivityState: NearbyInteractionConnectionState { get }
    var proximity: Proximity { get }
    var proximityThresholds: ProximityThresholds { get set }
    func startup()
    func cleanup()
}

@available(iOS 17.0, *)
public enum NearbyInteractionConnectionState {
    case initialising
    case discoveringPeer
    case peerEnded
    case peerTimeout
    case sessionSuspended
    case nearbyInteractionPermissionRequired
}

@available(iOS 17.0, *)
public enum Proximity {
    case veryClose
    case withinRange
    case tooFar
}

// Pass in these values, and then it will expose the Proximity enum
public protocol ProximityThresholds {
    var veryCloseThreshold: Float { get }
    var withinRangeThresholdLow: Float { get }
    var withinRangeThresholdHigh: Float { get }
    var tooFarThreshold: Float { get }
}

public struct DefaultProximityThresholds: ProximityThresholds {
    public let veryCloseThreshold: Float
    public let withinRangeThresholdLow: Float
    public let withinRangeThresholdHigh: Float
    public let tooFarThreshold: Float
    
    public init(veryCloseThreshold: Float, withinRangeThresholdLow: Float, withinRangeThresholdHigh: Float, tooFarThreshold: Float) {
        self.veryCloseThreshold = veryCloseThreshold
        self.withinRangeThresholdLow = withinRangeThresholdLow
        self.withinRangeThresholdHigh = withinRangeThresholdHigh
        self.tooFarThreshold = tooFarThreshold
    }
}

@available(iOS 17.0, *)
@Observable
public final class DefaultNearbyInteractionService: NSObject, NearbyInteractionService {
    
    public var connectivityState: NearbyInteractionConnectionState = .initialising
    public var currentInteractionState: DistanceDirectionState = .unknown
    private var distance: Float? {
        didSet {
            if let dist = distance {
                distanceString = String(format: "%0.1f m", dist)
                switch dist {
                case ..<proximityThresholds.veryCloseThreshold:
                    proximity = .veryClose
                case proximityThresholds.veryCloseThreshold...proximityThresholds.withinRangeThresholdLow:
                    break // no nothing, dead area
                case proximityThresholds.withinRangeThresholdLow...proximityThresholds.withinRangeThresholdHigh:
                    proximity = .withinRange
                case proximityThresholds.withinRangeThresholdHigh...proximityThresholds.tooFarThreshold:
                    break // do nothing, dead area
                case proximityThresholds.tooFarThreshold...:
                    proximity = .tooFar
                default:
                    proximity = .tooFar
                }
            }
        }
    }
    public var distanceString: String = ""
    public var proximity: Proximity = .tooFar
    
    public var proximityThresholds: ProximityThresholds = DefaultProximityThresholds(veryCloseThreshold: 0.1, withinRangeThresholdLow: 0.3, withinRangeThresholdHigh: 0.6, tooFarThreshold: 0.8)
    
    // Nearby Interaction
    private var sharedTokenWithPeer = false
    private var session: NISession?
    private var peerDiscoveryToken: NIDiscoveryToken?
    private var currentDistanceDirectionState: DistanceDirectionState = .unknown
    
    // Multipeer Stuff
    private let serviceName: String
    private let identityName: String
    private var mpc: SinglePeerMultipeerSession?
    
    public enum DistanceDirectionState {
        case closeUpInFOV, notCloseUpInFOV, outOfFOV, unknown
    }
    
    public init(serviceName: String, identityName: String) {
        self.serviceName = serviceName
        self.identityName = identityName
    }
    
    public func cleanup() {
        session?.delegate = nil
        session?.invalidate()
        mpc?.cleanupMPC()
        sharedTokenWithPeer = false
        peerDiscoveryToken = nil
    }
    
    public func startup() {
        // Create the NISession.
        session = NISession()
        
        // Set the delegate.
        session?.delegate = self
        
        // Because the session is new, reset the token-shared flag.
        sharedTokenWithPeer = false
        
        // If `connectedPeer` exists, share the discovery token, if needed.
        if let mpc = self.mpc, mpc.isConnected {
            if let myToken = session?.discoveryToken {
                if !sharedTokenWithPeer {
                    shareMyDiscoveryToken(token: myToken)
                }
                guard let peerToken = peerDiscoveryToken else {
                    return
                }
                let config = NINearbyPeerConfiguration(peerToken: peerToken)
                session?.run(config)
            } else {
                fatalError("Unable to get self discovery token, is this session invalidated?")
            }
        } else {
            connectivityState = .discoveringPeer
            weak var weakSelf = self
            let mpc = SinglePeerMultipeerSession(serviceName: self.serviceName,
                                                 identityName: identityName,
                                                 onConnect: { weakSelf?.onConnect() },
                                                 onDisconnect: { weakSelf?.onDisconnect() },
                                                 onData: { (data) in weakSelf?.onData(data: data)})
            mpc.startupMPC()
            self.mpc = mpc
            
            // Set the display state.
            currentDistanceDirectionState = .unknown
        }
    }
    
    // MARK: Peer Handlers
    
    private func onConnect() {
        guard let myToken = self.session?.discoveryToken else {
            fatalError("Unexpectedly failed to initialize nearby interaction session.")
        }
        if !sharedTokenWithPeer {
            shareMyDiscoveryToken(token: myToken)
        }
    }
    
    private func onDisconnect() {
        sharedTokenWithPeer = false
    }
    
    private func onData(data: Data) {
        // Assuming the data is a discovery token here
        guard let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
            fatalError("Unexpectedly failed to decode discovery token.")
        }
        peerDidShareDiscoveryToken(token: discoveryToken)
    }
    
    
    // MARK: Sharing tokens
    
    private func shareMyDiscoveryToken(token: NIDiscoveryToken) {
        guard let encodedData = try?  NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            fatalError("Unexpectedly failed to encode discovery token.")
        }
        mpc?.sendData(data: encodedData)
        sharedTokenWithPeer = true
    }
    
    private func peerDidShareDiscoveryToken(token: NIDiscoveryToken) {
        // Create a configuration.
        peerDiscoveryToken = token
        
        let config = NINearbyPeerConfiguration(peerToken: token)
        
        // Run the session.
        session?.run(config)
    }
    
    // MARK: Figure out positions etc
    
    private func isNearby(_ distance: Float) -> Bool {
        return distance < proximityThresholds.withinRangeThresholdLow
    }
    
    private func getDistanceDirectionState(from nearbyObject: NINearbyObject) -> DistanceDirectionState {
        if nearbyObject.distance == nil && nearbyObject.direction == nil {
            return .unknown
        }
        
        let isNearby = nearbyObject.distance.map(isNearby(_:)) ?? false
        let directionAvailable = nearbyObject.direction != nil
        
        if isNearby && directionAvailable {
            return .closeUpInFOV
        }
        
        if !isNearby && directionAvailable {
            return .notCloseUpInFOV
        }
        
        return .outOfFOV
    }
    
    private func updateState(from currentState: DistanceDirectionState, to nextState: DistanceDirectionState, with peer: NINearbyObject) {
        //        let azimuth = peer.direction.map(azimuth(from:))
        //        let elevation = peer.direction.map(elevation(from:))
        
        currentInteractionState = nextState
        // If the app transitions from unavailable, present the app's display
        // and hide the user instructions.
        if currentState == .unknown && nextState != .unknown {
            
            // start showing some details...
            
            
        }
        
        //        if nextState == .unknown {
        //            // start hiding stuff
        //
        //        }
        
        //        if nextState == .outOfFOV || nextState == .unknown {
        //            detailAngleInfoView.alpha = 0.0
        //        } else {
        //            detailAngleInfoView.alpha = 1.0
        //        }
        
        // Set the app's display based on peer state.
        //        switch nextState {
        //        case .closeUpInFOV:
        //            monkeyLabel.text = "🙉"
        //        case .notCloseUpInFOV:
        //            monkeyLabel.text = "🙈"
        //        case .outOfFOV:
        //            monkeyLabel.text = "🙊"
        //        case .unknown:
        //            monkeyLabel.text = ""
        //        }
        
        distance = peer.distance
        //
        //        if peer.distance != nil {
        //            detailDistanceLabel.text = String(format: "%0.2f m", peer.distance!)
        //        }
        
        //        monkeyLabel.transform = CGAffineTransform(rotationAngle: CGFloat(azimuth ?? 0.0))
        
        // Don't update visuals if the peer device is unavailable or out of the
        // U1 chip's field of view.
        if nextState == .outOfFOV || nextState == .unknown {
            return
        }
    }
    
}

@available(iOS 17.0, *)
extension DefaultNearbyInteractionService: NISessionDelegate {
    public func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let peerToken = peerDiscoveryToken else {
            fatalError("don't have peer token")
        }
        
        // Find the right peer.
        let peerObj = nearbyObjects.first { (obj) -> Bool in
            return obj.discoveryToken == peerToken
        }
        
        guard let nearbyObjectUpdate = peerObj else {
            return
        }
        
        // Update the the state and visualizations.
        let nextState = getDistanceDirectionState(from: nearbyObjectUpdate)
        updateState(from: currentDistanceDirectionState, to: nextState, with: nearbyObjectUpdate)
        currentDistanceDirectionState = nextState
    }
    
    public func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        guard let peerToken = peerDiscoveryToken else {
            fatalError("don't have peer token")
        }
        // Find the right peer.
        let peerObj = nearbyObjects.first { (obj) -> Bool in
            return obj.discoveryToken == peerToken
        }
        
        if peerObj == nil {
            return
        }
        
        currentDistanceDirectionState = .unknown
        
        switch reason {
        case .peerEnded:
            // The peer token is no longer valid.
            peerDiscoveryToken = nil
            
            // The peer stopped communicating, so invalidate the session because
            // it's finished.
            session.invalidate()
            
            // Restart the sequence to see if the peer comes back.
            //            startup()
            
            // Update the app's display.
            connectivityState = .peerEnded
        case .timeout:
            
            // The peer timed out, but the session is valid.
            // If the configuration is valid, run the session again.
            if let config = session.configuration {
                session.run(config)
            }
            connectivityState = .peerTimeout
        default:
            fatalError("Unknown and unhandled NINearbyObject.RemovalReason")
        }
    }
    
    public func sessionWasSuspended(_ session: NISession) {
        currentDistanceDirectionState = .unknown
        connectivityState = .sessionSuspended
    }
    
    public func sessionSuspensionEnded(_ session: NISession) {
        // Session suspension ended. The session can now be run again.
        if let config = self.session?.configuration {
            session.run(config)
        } else {
            // Create a valid configuration.
            startup()
        }
    }
    
    public func session(_ session: NISession, didInvalidateWith error: Error) {
        currentDistanceDirectionState = .unknown
        
        // If the app lacks user approval for Nearby Interaction, present
        // an option to go to Settings where the user can update the access.
        if case NIError.userDidNotAllow = error {
            //            if #available(iOS 15.0, *) {
            // In iOS 15.0, Settings persists Nearby Interaction access.
            connectivityState = .nearbyInteractionPermissionRequired
            // Create an alert that directs the user to Settings.
            let accessAlert = UIAlertController(title: "Access Required",
                                                message: """
                                                    NIPeekaboo requires access to Nearby Interactions for this sample app.
                                                    Use this string to explain to users which functionality will be enabled if they change
                                                    Nearby Interactions access in Settings.
                                                    """,
                                                preferredStyle: .alert)
            accessAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            accessAlert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: {_ in
                // Send the user to the app's Settings to update Nearby Interactions access.
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
            
            // Display the alert.
            //                present(accessAlert, animated: true, completion: nil)
            //            } else {
            //                // Before iOS 15.0, ask the user to restart the app so the
            //                // framework can ask for Nearby Interaction access again.
            //                connectivityState = .nearbyInteractionPermissionRequired // restart required
            //            }
            
            return
        }
        
        // Recreate a valid session.
        startup()
    }
}

import simd

extension FloatingPoint {
    // Converts degrees to radians.
    var degreesToRadians: Self { self * .pi / 180 }
    // Converts radians to degrees.
    var radiansToDegrees: Self { self * 180 / .pi }
}

// Provides the azimuth from an argument 3D directional.
func azimuth(from direction: simd_float3) -> Float {
    return asin(direction.x)
}

// Provides the elevation from the argument 3D directional.
func elevation(from direction: simd_float3) -> Float {
    return atan2(direction.z, direction.y) + .pi / 2
}
