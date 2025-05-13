import Foundation
import AVFoundation
import CoreAudio

class AudioEngine {
    private var audioEngine: AVAudioEngine
    private var inputNode: AVAudioInputNode?
    private var mixer: AVAudioMixerNode
    private var playerNodes: [AVAudioPlayerNode] = []
    private var outputNodes: [AVAudioOutputNode] = []
    
    private var isRunning = false
    
    init() {
        audioEngine = AVAudioEngine()
        mixer = AVAudioMixerNode()
        audioEngine.attach(mixer)
    }
    
    // Setup audio session for the app
    func setupAudioSession() -> Bool {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            try session.setActive(true)
            return true
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
            return false
        }
    }
    
    // Create an audio stream from an input device to an output device
    func createStream(inputDeviceID: AudioDeviceID, outputDeviceID: AudioDeviceID) -> Bool {
        do {
            // Stop the engine if it's running
            if isRunning {
                audioEngine.stop()
                isRunning = false
            }
            
            // Configure input
            let inputDescription = createAudioComponentDescription(for: inputDeviceID)
            let inputAU = try AUAudioUnit(componentDescription: inputDescription)
            let inputNode = AVAudioUnit(audioUnit: inputAU)
            audioEngine.attach(inputNode)
            
            // Configure output
            let outputDescription = createAudioComponentDescription(for: outputDeviceID)
            let outputAU = try AUAudioUnit(componentDescription: outputDescription)
            let outputNode = AVAudioUnit(audioUnit: outputAU)
            audioEngine.attach(outputNode)
            
            // Connect nodes
            audioEngine.connect(inputNode, to: mixer, format: nil)
            audioEngine.connect(mixer, to: outputNode, format: nil)
            
            // Keep track of the nodes
            playerNodes.append(AVAudioPlayerNode())
            
            return true
        } catch {
            print("Failed to create audio stream: \(error.localizedDescription)")
            return false
        }
    }
    
    // Create a description for an audio component
    private func createAudioComponentDescription(for deviceID: AudioDeviceID) -> AudioComponentDescription {
        var audioComponentDescription = AudioComponentDescription()
        audioComponentDescription.componentType = kAudioUnitType_Output
        audioComponentDescription.componentSubType = kAudioUnitSubType_HALOutput
        audioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        audioComponentDescription.componentFlags = 0
        audioComponentDescription.componentFlagsMask = 0
        
        return audioComponentDescription
    }
    
    // Start the audio engine
    func start() -> Bool {
        do {
            try audioEngine.start()
            isRunning = true
            return true
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
            return false
        }
    }
    
    // Stop the audio engine
    func stop() {
        audioEngine.stop()
        isRunning = false
    }
    
    // Set the output device for the audio engine
    func setOutputDevice(_ deviceID: AudioDeviceID) -> Bool {
        do {
            let outputUnit = try getOutputAudioUnit()
            var outputDevice: AudioDeviceID = deviceID
            var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
            
            let status = AudioUnitSetProperty(
                outputUnit,
                kAudioOutputUnitProperty_CurrentDevice,
                kAudioUnitScope_Global,
                0,
                &outputDevice,
                propertySize
            )
            
            return status == noErr
        } catch {
            print("Failed to set output device: \(error.localizedDescription)")
            return false
        }
    }
    
    // Get the output audio unit from the engine
    private func getOutputAudioUnit() throws -> AudioUnit {
        guard let outputNode = audioEngine.outputNode.audioUnit else {
            throw NSError(domain: "AudioEngine", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get output audio unit"])
        }
        return outputNode
    }
    
    // Set the input device for the audio engine
    func setInputDevice(_ deviceID: AudioDeviceID) -> Bool {
        do {
            guard let inputNode = audioEngine.inputNode.audioUnit else {
                return false
            }
            
            var inputDevice: AudioDeviceID = deviceID
            var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
            
            let status = AudioUnitSetProperty(
                inputNode,
                kAudioOutputUnitProperty_CurrentDevice,
                kAudioUnitScope_Global,
                0,
                &inputDevice,
                propertySize
            )
            
            return status == noErr
        } catch {
            print("Failed to set input device: \(error.localizedDescription)")
            return false
        }
    }
    
    // Create a virtual cable between input and output devices
    func createVirtualCable(from inputDeviceID: AudioDeviceID, to outputDeviceID: AudioDeviceID) -> Bool {
        do {
            // Configure the audio session
            if !setupAudioSession() {
                return false
            }
            
            // Create the stream
            if !createStream(inputDeviceID: inputDeviceID, outputDeviceID: outputDeviceID) {
                return false
            }
            
            // Start the engine
            return start()
        } catch {
            print("Failed to create virtual cable: \(error.localizedDescription)")
            return false
        }
    }
} 