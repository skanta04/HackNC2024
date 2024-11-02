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
        startAsCentral()
        startAsPeripheral()
    }
    
    func startAsCentral() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startAsPeripheral() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Central (Receiver) Methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothAvailable = central.state == .poweredOn
        if isBluetoothAvailable {
            centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
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
            if let message = try? JSONDecoder().decode(Message.self, from: value) {
                DispatchQueue.main.async {
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
        }
    }
    
    func sendMessage(_ message: Message) {
        guard let characteristic = characteristic else { return }
        
        if let data = try? JSONEncoder().encode(message) {
            peripheralManager?.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
        }
    }
}
