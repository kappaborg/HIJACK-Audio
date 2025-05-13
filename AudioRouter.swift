import Foundation
import AVFoundation
import CoreAudio

class AudioRouter {
    // Store input and output devices
    var inputDevices: [AudioDeviceID] = []
    var outputDevices: [AudioDeviceID] = []
    
    // Store active audio streams
    var audioStreams: [AudioStream] = []
    
    init() {
        // Find audio devices on initialization
        discoverAudioDevices()
    }
    
    func discoverAudioDevices() {
        // Find all audio devices in the system using CoreAudio
        var propertySize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject),
                                                   &AudioObjectPropertyAddress(
                                                       mSelector: kAudioHardwarePropertyDevices,
                                                       mScope: kAudioObjectPropertyScopeGlobal,
                                                       mElement: kAudioObjectPropertyElementMaster),
                                                   0,
                                                   nil,
                                                   &propertySize)
        
        let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        var allDevices = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        // Get the device list
        status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                           &AudioObjectPropertyAddress(
                                               mSelector: kAudioHardwarePropertyDevices,
                                               mScope: kAudioObjectPropertyScopeGlobal,
                                               mElement: kAudioObjectPropertyElementMaster),
                                           0,
                                           nil,
                                           &propertySize,
                                           &allDevices)
        
        // Separate devices into input and output
        for device in allDevices {
            if isInputDevice(device) {
                inputDevices.append(device)
            }
            if isOutputDevice(device) {
                outputDevices.append(device)
            }
        }
    }
    
    func isInputDevice(_ device: AudioDeviceID) -> Bool {
        // Check if a device is an input device
        var propertySize: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMaster)
        
        let status = AudioObjectGetPropertyDataSize(device, &address, 0, nil, &propertySize)
        if status != 0 {
            return false
        }
        
        let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(propertySize))
        defer {
            bufferList.deallocate()
        }
        
        let status2 = AudioObjectGetPropertyData(device, &address, 0, nil, &propertySize, bufferList)
        if status2 != 0 {
            return false
        }
        
        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        return buffers.count > 0
    }
    
    func isOutputDevice(_ device: AudioDeviceID) -> Bool {
        // Similarly check for output device
        var propertySize: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster)
        
        // Check output channels
        let status = AudioObjectGetPropertyDataSize(device, &address, 0, nil, &propertySize)
        if status != 0 {
            return false
        }
        
        let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(propertySize))
        defer {
            bufferList.deallocate()
        }
        
        let status2 = AudioObjectGetPropertyData(device, &address, 0, nil, &propertySize, bufferList)
        if status2 != 0 {
            return false
        }
        
        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        return buffers.count > 0
    }
    
    func getDeviceName(_ device: AudioDeviceID) -> String {
        var propertySize: UInt32 = 0
        var name: CFString = "" as CFString
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster)
        
        let status = AudioObjectGetPropertyDataSize(device, &address, 0, nil, &propertySize)
        if status != 0 {
            return "Unknown Device"
        }
        
        let status2 = AudioObjectGetPropertyData(device, &address, 0, nil, &propertySize, &name)
        if status2 != 0 {
            return "Unknown Device"
        }
        
        return name as String
    }
    
    func listAllDevices() -> [(id: AudioDeviceID, name: String, isInput: Bool, isOutput: Bool)] {
        var deviceList: [(id: AudioDeviceID, name: String, isInput: Bool, isOutput: Bool)] = []
        
        var propertySize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject),
                                                   &AudioObjectPropertyAddress(
                                                       mSelector: kAudioHardwarePropertyDevices,
                                                       mScope: kAudioObjectPropertyScopeGlobal,
                                                       mElement: kAudioObjectPropertyElementMaster),
                                                   0,
                                                   nil,
                                                   &propertySize)
        
        let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        var allDevices = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                           &AudioObjectPropertyAddress(
                                               mSelector: kAudioHardwarePropertyDevices,
                                               mScope: kAudioObjectPropertyScopeGlobal,
                                               mElement: kAudioObjectPropertyElementMaster),
                                           0,
                                           nil,
                                           &propertySize,
                                           &allDevices)
        
        for device in allDevices {
            let name = getDeviceName(device)
            let isInput = isInputDevice(device)
            let isOutput = isOutputDevice(device)
            deviceList.append((id: device, name: name, isInput: isInput, isOutput: isOutput))
        }
        
        return deviceList
    }
    
    // Setup audio routing between devices
    func createAudioStream(from inputDevice: AudioDeviceID, to outputDevice: AudioDeviceID) -> Bool {
        // This is where we would implement the actual audio routing
        // This is a complex task that involves:
        // 1. Setting up an audio processing graph
        // 2. Creating audio units for input and output
        // 3. Connecting them together
        // 4. Starting the audio flow
        
        // For now, we'll create a placeholder stream
        let stream = AudioStream(sourceDevice: inputDevice, destinationDevice: outputDevice, isActive: false)
        audioStreams.append(stream)
        
        return true
    }
    
    func startAudioStream(sourceDeviceID: AudioDeviceID, destinationDeviceID: AudioDeviceID) -> Bool {
        // Find the stream
        guard let index = audioStreams.firstIndex(where: { 
            $0.sourceDevice == sourceDeviceID && $0.destinationDevice == destinationDeviceID 
        }) else {
            return false
        }
        
        // Implement actual stream starting here
        // For demonstration purposes, we'll just mark it as active
        audioStreams[index].isActive = true
        
        return true
    }
    
    func stopAudioStream(sourceDeviceID: AudioDeviceID, destinationDeviceID: AudioDeviceID) -> Bool {
        // Find the stream
        guard let index = audioStreams.firstIndex(where: { 
            $0.sourceDevice == sourceDeviceID && $0.destinationDevice == destinationDeviceID 
        }) else {
            return false
        }
        
        // Implement actual stream stopping here
        audioStreams[index].isActive = false
        
        return true
    }
}

// Structure representing an audio stream
struct AudioStream {
    var sourceDevice: AudioDeviceID
    var destinationDevice: AudioDeviceID
    var isActive: Bool
} 