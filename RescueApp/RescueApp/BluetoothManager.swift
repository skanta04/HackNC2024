//
//  BluetoothManager.swift
//  RescueApp
//
//  Created by Sruthy Mammen on 11/2/24.
//

import Foundation
import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject, CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    @Published var isBroadcasting = false
    @Published var discoveredMessage: String? // Ensure this is @Published so it updates the view

    private var peripheralManager: CBPeripheralManager?
    private var centralManager: CBCentralManager?

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Bluetooth Broadcasting
    func startBroadcastingMessage(_ message: String) {
        guard let peripheralManager = peripheralManager else { return }
        let messageData = [CBAdvertisementDataLocalNameKey: message]
        peripheralManager.startAdvertising(messageData)
        isBroadcasting = true
    }
    
    func stopBroadcastingMessage() {
        peripheralManager?.stopAdvertising()
        isBroadcasting = false
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Bluetooth is on. Ready to broadcast.")
        } else {
            print("Bluetooth not available for broadcasting.")
        }
    }
    
    // MARK: - Bluetooth Scanning
    func startScanning() {
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is on. Ready to scan.")
        } else {
            print("Bluetooth not available for scanning.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let message = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            DispatchQueue.main.async {
                self.discoveredMessage = message // Update the detected message
            }
        }
    }
}
