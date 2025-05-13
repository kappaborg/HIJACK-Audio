import SwiftUI
import AVFoundation
import CoreAudio

struct ContentView: View {
    @StateObject private var viewModel = AudioRouterViewModel()
    @State private var selectedInputDevice: AudioDeviceInfo?
    @State private var selectedOutputDevice: AudioDeviceInfo?
    @State private var isStreaming = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ses Yönlendirici")
                .font(.largeTitle)
                .padding()
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Giriş Cihazları")
                        .font(.headline)
                    
                    List(viewModel.inputDevices, id: \.id) { device in
                        HStack {
                            Text(device.name)
                            Spacer()
                            if selectedInputDevice?.id == device.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedInputDevice = device
                        }
                    }
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Çıkış Cihazları")
                        .font(.headline)
                    
                    List(viewModel.outputDevices, id: \.id) { device in
                        HStack {
                            Text(device.name)
                            Spacer()
                            if selectedOutputDevice?.id == device.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedOutputDevice = device
                        }
                    }
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                }
            }
            .padding()
            
            HStack(spacing: 20) {
                Button(action: {
                    refreshDevices()
                }) {
                    Label("Cihazları Yenile", systemImage: "arrow.clockwise")
                        .frame(minWidth: 150)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    toggleStreaming()
                }) {
                    Label(isStreaming ? "Durdur" : "Başlat", systemImage: isStreaming ? "stop.fill" : "play.fill")
                        .frame(minWidth: 150)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedInputDevice == nil || selectedOutputDevice == nil)
            }
            .padding()
            
            // Active connections
            VStack(alignment: .leading, spacing: 10) {
                Text("Aktif Bağlantılar")
                    .font(.headline)
                
                if viewModel.activeConnections.isEmpty {
                    Text("Aktif bağlantı yok")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    List(viewModel.activeConnections, id: \.id) { connection in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Giriş: \(connection.inputDeviceName)")
                                Text("Çıkış: \(connection.outputDeviceName)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.stopConnection(connection)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(height: 150)
                    .border(Color.gray, width: 1)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .onAppear {
            refreshDevices()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Bildirim"),
                message: Text(alertMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
    
    private func refreshDevices() {
        viewModel.loadDevices()
    }
    
    private func toggleStreaming() {
        guard let inputDevice = selectedInputDevice, let outputDevice = selectedOutputDevice else {
            showAlert(message: "Lütfen bir giriş ve çıkış cihazı seçin.")
            return
        }
        
        if isStreaming {
            // Stop streaming
            if viewModel.stopConnection(inputDevice.id, outputDevice.id) {
                isStreaming = false
            } else {
                showAlert(message: "Bağlantı durdurulamadı.")
            }
        } else {
            // Start streaming
            if viewModel.createConnection(inputDevice.id, outputDevice.id) {
                isStreaming = true
            } else {
                showAlert(message: "Bağlantı oluşturulamadı.")
            }
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

// Preview for the ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 