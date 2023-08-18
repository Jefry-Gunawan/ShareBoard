//
//  MultipeerViewModel.swift
//  ShareBoard
//
//  Created by Jefry Gunawan on 10/08/23.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerViewModelDelegate: AnyObject {
    func didUpdateConnectedPeers(_ peers: [MCPeerID])
}

class MultipeerViewModel: NSObject, ObservableObject {
    
    let serviceType = "board-conn"
    
    var peerId: MCPeerID
    var session: MCSession
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    
    @Published var binaryDataOut: Data = Data()
    
    var binaryDataFirstSend: Data = Data()
    
    override init() {
        peerId = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }
    
    func advertise(boardCode: String) {
        session.delegate = nil
        session.disconnect()
        
        peerId = MCPeerID(displayName: boardCode)
        
        session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceAdvertiser?.delegate = self
        nearbyServiceAdvertiser?.startAdvertisingPeer()
    }
    
    func invite() {
        let browser = MCBrowserViewController(serviceType: serviceType, session: session)
        browser.delegate = self
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(browser, animated: true)
    }
    
    func disconnectAndStopAdvertising() {
        session.disconnect()
        nearbyServiceAdvertiser?.stopAdvertisingPeer()
        nearbyServiceAdvertiser = nil
    }
    
    func sendBinaryData(_ data: Data) {
        if session.connectedPeers.isEmpty {
            print("No connected peers.")
            return
        }
        
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            DispatchQueue.main.async {
                self.binaryDataFirstSend = data
            }
            print("Binary data sent: \(data.count) bytes")
        } catch {
            print("Error sending binary data: \(error.localizedDescription)")
        }
    }
    
    func getBinaryData() -> Data {
        return binaryDataOut
    }
    
    deinit {
        disconnectAndStopAdvertising()
    }
}

extension MultipeerViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer PeerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:
            print("\(peerId) state: connecting")
        case .connected:
            print("\(peerId) state: connected")
            sendBinaryData(binaryDataFirstSend)
        case .notConnected:
            print("\(peerId) state: not connected")
        @unknown default:
            print("\(peerId) staet: unknown")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received binary data from \(peerID.displayName): \(data.count) bytes")
        DispatchQueue.main.async {
            self.binaryDataOut = data
        }
        print("Binary Data Out \(binaryDataOut)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension MultipeerViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension MultipeerViewModel: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}

public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}

