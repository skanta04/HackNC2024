//
//  BluetoothManager.swift
//  RescueApp
//
//  Created by Sruthy Mammen on 11/2/24.
//

import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isBluetoothAvailable = false
    @Published var receivedMessage: String = ""
    @Environment(\.modelContext) private var context // Access SwiftData context
    
    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    private var discoveredPeripherals: [CBPeripheral] = []
    private var characteristic: CBMutableCharacteristic?
    
    private let serviceUUID = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    private let characteristicUUID = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
    
    override init() {
        super.init()
        
        // Initialize both central and peripheral roles
        startAsCentral()
        startAsPeripheral()
    }
    
    func startAsCentral() {
        print("Initializing as Central")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startAsPeripheral() {
        print("Initializing as Peripheral")
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Central (Receiver) Methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothAvailable = central.state == .poweredOn
        if isBluetoothAvailable {
            centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
            print("Central started scanning for peripherals...")
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral.name ?? "Unnamed")")
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name ?? "Unnamed")")
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == characteristicUUID {
                    print("Characteristic found; subscribing to notifications.")
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == characteristicUUID, let value = characteristic.value, let message = String(data: value, encoding: .utf8) {
            DispatchQueue.main.async {
                self.receivedMessage = message
                // Save received message to local SwiftData
                let newMessage = Message(
                    id: UUID(),
                    content: message,
                    latitude: 0.0, // You can set this dynamically if you have location data
                    longitude: 0.0, // Same for longitude
                    timestamp: Date(),
                    status: .synced, // Since it was received from another device
                    category: .other // Assign default or parsed category
            )
            self.context.insert(newMessage)
            try? self.context.save()
            }
            print("Received message from peripheral: \(message)")
        }
    }
    
    // MARK: - Peripheral (Sender) Methods
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let characteristic = CBMutableCharacteristic(
                type: characteristicUUID,
                properties: [.notify, .write],
                value: nil,
                permissions: [.readable, .writeable]
            )
            
            let service = CBMutableService(type: serviceUUID, primary: true)
            service.characteristics = [characteristic]
            peripheralManager?.add(service)
            
            self.characteristic = characteristic
            peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
            print("Peripheral started advertising...")
        } else {
            print("Peripheral Bluetooth is not available.")
        }
    }
    
    func sendMessage(_ message: String) {
        guard let characteristic = characteristic, let data = message.data(using: .utf8) else {
            print("No characteristic available to send message.")
            return
        }
        
        print("Sending message: \(message)")
        peripheralManager?.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
    }
}

