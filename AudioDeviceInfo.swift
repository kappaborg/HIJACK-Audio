import Foundation
import CoreAudio

// Model for audio device information
struct AudioDeviceInfo: Identifiable, Hashable {
    var id: AudioDeviceID
    var name: String
    var isInput: Bool
    var isOutput: Bool
    
    // Required by Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Required by Equatable (via Hashable)
    static func == (lhs: AudioDeviceInfo, rhs: AudioDeviceInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

// Model for active audio connections
struct AudioConnection: Identifiable {
    var id: String
    var inputDeviceID: AudioDeviceID
    var outputDeviceID: AudioDeviceID
    var inputDeviceName: String
    var outputDeviceName: String
    
    init(inputDeviceID: AudioDeviceID, outputDeviceID: AudioDeviceID, inputDeviceName: String, outputDeviceName: String) {
        self.id = "\(inputDeviceID)-\(outputDeviceID)"
        self.inputDeviceID = inputDeviceID
        self.outputDeviceID = outputDeviceID
        self.inputDeviceName = inputDeviceName
        self.outputDeviceName = outputDeviceName
    }
} 