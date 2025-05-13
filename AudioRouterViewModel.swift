import Foundation
import Combine
import CoreAudio
import AVFoundation

class AudioRouterViewModel: ObservableObject {
    @Published var inputDevices: [AudioDeviceInfo] = []
    @Published var outputDevices: [AudioDeviceInfo] = []
    @Published var activeConnections: [AudioConnection] = []
    
    private let audioRouter = AudioRouter()
    private let audioEngine = AudioEngine()
    
    init() {
        loadDevices()
    }
    
    func loadDevices() {
        // Get all devices from AudioRouter
        let allDevices = audioRouter.listAllDevices()
        
        // Separate into input and output devices
        inputDevices = allDevices
            .filter { $0.isInput }
            .map { AudioDeviceInfo(id: $0.id, name: $0.name, isInput: $0.isInput, isOutput: $0.isOutput) }
        
        outputDevices = allDevices
            .filter { $0.isOutput }
            .map { AudioDeviceInfo(id: $0.id, name: $0.name, isInput: $0.isInput, isOutput: $0.isOutput) }
    }
    
    func createConnection(_ inputDeviceID: AudioDeviceID, _ outputDeviceID: AudioDeviceID) -> Bool {
        // Get device names
        guard let inputDeviceName = getDeviceName(inputDeviceID),
              let outputDeviceName = getDeviceName(outputDeviceID) else {
            return false
        }
        
        // Check if this connection already exists
        let connectionID = "\(inputDeviceID)-\(outputDeviceID)"
        if activeConnections.contains(where: { $0.id == connectionID }) {
            return false
        }
        
        // Create the virtual cable
        if audioEngine.createVirtualCable(from: inputDeviceID, to: outputDeviceID) {
            // Add to active connections
            let connection = AudioConnection(
                inputDeviceID: inputDeviceID,
                outputDeviceID: outputDeviceID,
                inputDeviceName: inputDeviceName,
                outputDeviceName: outputDeviceName
            )
            
            DispatchQueue.main.async {
                self.activeConnections.append(connection)
            }
            
            return true
        }
        
        return false
    }
    
    func stopConnection(_ connection: AudioConnection) -> Bool {
        return stopConnection(connection.inputDeviceID, connection.outputDeviceID)
    }
    
    func stopConnection(_ inputDeviceID: AudioDeviceID, _ outputDeviceID: AudioDeviceID) -> Bool {
        // Find the connection
        let connectionID = "\(inputDeviceID)-\(outputDeviceID)"
        guard let index = activeConnections.firstIndex(where: { $0.id == connectionID }) else {
            return false
        }
        
        // Stop the audio engine for this connection
        audioEngine.stop()
        
        // Remove from active connections
        DispatchQueue.main.async {
            self.activeConnections.remove(at: index)
        }
        
        return true
    }
    
    private func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
        // First check input devices
        if let device = inputDevices.first(where: { $0.id == deviceID }) {
            return device.name
        }
        
        // Then check output devices
        if let device = outputDevices.first(where: { $0.id == deviceID }) {
            return device.name
        }
        
        return nil
    }
} 