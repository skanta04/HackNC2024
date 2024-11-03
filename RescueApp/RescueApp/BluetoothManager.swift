//
//  BluetoothManager.swift
//  RescueApp
//
//  Created by Sruthy Mammen on 11/2/24.
//
import CoreBluetooth
import SwiftUI
import SwiftData

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    @Published var isBluetoothAvailable = false
    @Published var receivedMessage: String = ""
    
    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    private var discoveredPeripherals: [CBPeripheral] = []
    private var characteristic: CBMutableCharacteristic?
    
    private let serviceUUID = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    private let characteristicUUID = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
    
    var context: ModelContext? // Add context here

    override init() {
        super.init()
        initializeBluetoothManagers()
    }
    
    private func initializeBluetoothManagers() {
        // Reinitialize both central and peripheral managers
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Central (Receiver) Methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isBluetoothAvailable = true
            startScanning()
        } else if central.state == .poweredOff {
            isBluetoothAvailable = false
            centralManager?.stopScan()
            print("Central Bluetooth is powered off.")
        } else {
            print("Central Bluetooth state: \(central.state.rawValue)")
        }
    }
    
    private func startScanning() {
        centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
        print("Central started scanning for peripherals...")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
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
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == characteristicUUID, let value = characteristic.value {
            if var message = try? JSONDecoder().decode(Message.self, from: value) {
                DispatchQueue.main.async {
                    message.status = .pendingSync // Set default status for Bluetooth messages
                    self.receivedMessage = message.content
                    
                    // Save received message to local SwiftData if context is available
                    if let context = self.context {
                        context.insert(message)
                        try? context.save()
                    }
                }
            }
        }
    }
    
    // MARK: - Peripheral (Sender) Methods
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            setupPeripheralCharacteristic()
            startAdvertising()
        } else if peripheral.state == .poweredOff {
            peripheralManager?.stopAdvertising()
            print("Peripheral Bluetooth is powered off.")
        } else {
            print("Peripheral Bluetooth state: \(peripheral.state.rawValue)")
        }
    }
    
    private func setupPeripheralCharacteristic() {
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
    }
    
    private func startAdvertising() {
        peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
        print("Peripheral started advertising...")
    }
    
    func sendMessage(_ message: Message) {
        guard let characteristic = characteristic else { return }
        
        if let data = try? JSONEncoder().encode(message) {
            peripheralManager?.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
        }
    }
}
