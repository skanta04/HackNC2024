

***Bluetooth Manager***

Using Apple's Framework "CoreBluetooth", we created a function called Bluetooth Manager that creates Bluetooth communcaton between devices using both central and peripheral modes. This can scan for nearby devices, send messages, and receive messages. Additionally, received messsages are saved using SwiftData. 

**What does it do?**

1. Finds other Devices Nearby: It acts like a radar, sending for other Bluetooth devices around you. After testing, we saw that mininum range of distance is 30 feet and maximum is 75 feet for a Bluetooth connecction.

2. Connects to other Devices: Once it finds a device that is connected to Bluetooth, it connects to it and either receives messages and send messages to it.

3. Saves Messages: It can save messages that you receive, so you can check them when you're connected to Wifi and when you're not connected.

**How does it work?**

First, we created an instance of Bluetooth Manager, where it looks for other devices (Central Mode) and broadcastings to itself (Peripheral Mode):

```
let bluetoothManager = BluetoothManager()
```
Now, it's searching for nearby signals and is ready to broadcast a message! Our startAsCentral() function finds other devices around to start this process. startAsPeripheral() helps connect other devices to start this process.

```
    func startAsCentral() {
        print("Initializing as Central")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startAsPeripheral() {
        print("Initializing as Peripheral")
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
}
```
Central Mode (Receiver)

In Central Mode, BluetoothManager acts as a receiver, scanning for nearby devices and connecting to them.

```
func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
        isBluetoothAvailable = true
        centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
        print("Central started scanning for peripherals...")
    } else if central.state == .poweredOff {
        isBluetoothAvailable = false
        centralManager?.stopScan()
    }
}
```
centralManagerDidUpdateState checks if Bluetooth is on. If it’s on, it starts scanning for devices with a specific serviceUUID.

```
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
```

didDiscover is triggered when a nearby device is found. It adds the device to discoveredPeripherals and connects to it.

```
func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let services = peripheral.services {
        for service in services {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
}
```

After discovering services, didDiscoverServices checks for characteristics (specific data fields). It searches for the characteristicUUID to enable message reception.

```
func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if characteristic.uuid == characteristicUUID, let value = characteristic.value {
        if let message = try? JSONDecoder().decode(Message.self, from: value) {
            DispatchQueue.main.async {
                message.status = .pendingSync
                self.receivedMessage = message.content

                if message.category == .sos {
                    self.showSOSReceivedAlert = true
                }

                if let context = self.context {
                    context.insert(message)
                    try? context.save()
                }
            }
        }
    }
}

```
didUpdateValueFor is called when a message is received from another device. It decodes the message and updates receivedMessage.

