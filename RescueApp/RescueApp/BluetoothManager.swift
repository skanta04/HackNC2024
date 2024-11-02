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
    //Protocols for managing Bluetooth events related to the device acting as both a peripheral (broadcaster) and a central (scanner).
    @Published var isBroadcasting = false
    @Published var discoveredMessage: String? // Ensure this is @Published so it updates the view

    private var peripheralManager: CBPeripheralManager?
    private var centralManager: CBCentralManager?
    
    // peripheralManager: An instance of CBPeripheralManager, responsible for handling Bluetooth peripheral (broadcasting) activities.
    // centralManager: An instance of CBCentralManager, responsible for handling Bluetooth central (scanning) activities.

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    // initalizing it
    
    // MARK: - Bluetooth Broadcasting
    func startBroadcastingMessage(_ message: String) {
        guard let peripheralManager = peripheralManager else { return }
        let messageData = [CBAdvertisementDataLocalNameKey: message]
        peripheralManager.startAdvertising(messageData)
        isBroadcasting = true
    }
    
    // startBroadcastingMessage(_:) takes a String message and starts broadcasting it as a BLE advertisement.
    // CBAdvertisementDataLocalNameKey: Sets the advertisement data with a “local name,” which other devices can detect during scanning.
    // peripheralManager.startAdvertising(messageData): Initiates advertising the message.
    // isBroadcasting = true: Sets the isBroadcasting flag to true to indicate that broadcasting is active.
    
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
