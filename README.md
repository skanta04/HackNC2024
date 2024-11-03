# EchoAlert

**EchoAlert** is a disaster response messaging application designed to work over Bluetooth, utilizing Apple's Core Data and Core Bluetooth. It enables users to communicate critical alerts and messages when cellular service is unavailable during natural disasters.


## Project Structure


#### RescueApp (Mobile Application)
Blah Blah Insert general description here 


#### PublicSync (Online Backend Lgic: REST API, AWS RDS Database Set up in Terraform)

This folder contains the core components of the wifi enabled, Cloud-based backend of the EchoAlert project. We set up an AWS RDS instance of a PostgresQL database using Terraform, as well as an AWS EC2 server. We created Pydantic backend modeling for message tables in the database, as well as a RESTful API implemented using FastAPI to interact with the said database in our mobile application. 


## IOS App Files and Logic

***Bluetooth Manager***

Using Apple's Framework "CoreBluetooth," we created a function called Bluetooth Manager that creates Bluetooth communication between devices using both central and peripheral modes. This can scan for nearby devices, send messages, and receive messages. Additionally, received messages are saved using SwiftData. 

**What does it do?**

1. Finds Other Devices Nearby: It acts like a radar, sending for other Bluetooth devices around you. After testing, we saw that the minimum range of distance is 30 feet and the maximum is 75 feet for a Bluetooth connection.

2. Connects to other Devices: Once it finds a device that is connected to Bluetooth, it connects to it and either receives messages and sends messages to it.

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

Peripheral Mode (Sender)
In Peripheral Mode, BluetoothManager broadcasts a message so other devices can receive it. 
```
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
    } else if peripheral.state == .poweredOff {
        peripheralManager?.stopAdvertising()
    }
}
```

peripheralManagerDidUpdateState() sets up a characteristic with read and write permissions and starts advertising the service. This is how we are able to use both Perpherial and Central Managers on  This allows other devices to connect and receive messages from this device.

**Sending Messages**

```
func sendMessage(_ message: Message) {
    guard let characteristic = characteristic else { return }

    if let data = try? JSONEncoder().encode(message) {
        peripheralManager?.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
    }
}
```

sendMessage encodes a message and updates the characteristic’s value, broadcasting it to subscribed devices. This broadcasts the message to all devices connected to this characteristic.

Credits: 
https://medium.com/@kalidoss.shanmugam/send-and-receive-data-between-two-iphone-devices-via-ble-in-swift-8ccbf941ce47

ChatGPT for debugging! 



## PublicSync Backend Logic



