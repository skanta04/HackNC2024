//
//  BluetoothManager.swift
//  RescueApp
//
//  Created by Sruthy Mammen on 11/2/24.
//

import Foundation
import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isBluetoothAvailable = false
    @Published var receivedMessage: String = ""
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var discoveredPeripheral: CBPeripheral?
    var characteristic: CBMutableCharacteristic?
    
    let serviceUUID = CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    let characteristicUUID = CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // Central Manager Delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothAvailable = central.state == .poweredOn
        if isBluetoothAvailable {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        discoveredPeripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral")
    }
    
    // Peripheral Manager Delegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.notify, .read, .write], value: nil, permissions: [.readable, .writeable])
            let service = CBMutableService(type: serviceUUID, primary: true)
            service.characteristics = [characteristic]
            peripheralManager.add(service)
            self.characteristic = characteristic
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
        } else {
            print("Peripheral is not available.")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid == characteristicUUID {
                if let value = request.value, let message = String(data: value, encoding: .utf8) {
                    receivedMessage = message  // Update the published property
                    print("Received message: \(message)")
                }
                peripheralManager.respond(to: request, withResult: .success)
            }
        }
    }
    
    // Peripheral Delegate
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
        if characteristic.uuid == characteristicUUID {
            if let value = characteristic.value, let message = String(data: value, encoding: .utf8) {
                receivedMessage = message
                print("Received message: \(message)")
            }
        }
    }
    
    // Function to Send Messages
    func sendMessage(_ message: String) {
        guard let discoveredPeripheral = discoveredPeripheral, let characteristic = characteristic else {
            print("No peripheral or characteristic found to send message")
            return
        }
        
        if let data = message.data(using: .utf8) {
            discoveredPeripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}
