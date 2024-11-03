# EchoAlert

**EchoAlert** is a disaster response messaging application designed to work over Bluetooth, utilizing Apple's Core Data and Core Bluetooth. It enables users to communicate critical alerts and messages when cellular service is unavailable during natural disasters.


## Project Structure


#### RescueApp (iOS Application)
The RescueApp folder contains the Xcode project for EchoAlert, which is responsible for the app's core functionality. The project integrates several key components to ensure robust functionality in emergency situations:
1. **LocationManager**: Handles location tracking, allowing the app to retrieve and display a user’s current location within a map interface.
2. **BluetoothManager**: Manages connections between devices in close proximity, allowing users to send and receive messages without relying on cellular or Wi-Fi networks.
3.  **Network Monitor**: When the device is online, the app can publish and receive alerts over Wi-Fi or cellular networks. When offline, the app seamlessly switches to Bluetooth-based messaging, ensuring continuous connectivity as long as other EchoAlert devices are nearby.
4. **SwiftData and Message Model**: For local data storage, EchoAlert uses SwiftData. A single Message model represents each message or alert, with an enumeration defining the alert category (e.g., resource, flooding, road blockages).

#### PublicSync (Online Backend Lgic: REST API, AWS RDS Database Set up in Terraform)

This folder contains the core components of the wifi enabled, Cloud-based backend of the EchoAlert project. We set up an AWS RDS instance of a PostgresQL database using Terraform, as well as an AWS EC2 server. We created Pydantic backend modeling for message tables in the database, as well as a RESTful API implemented using FastAPI to interact with the said database in our mobile application. 


## IOS App Files and Logic

### Bluetooth Manager

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

### Cloud Functions
These functions are used to post and get from the local database to the cloud database dynamically so we can update the map based on being online or offline

- `syncMessagedToCloud` function uploads any unsynced (offline) messages to the cloud once the user is online, marking them as `synced` locally after successful upload. This keeps everyone updated with the latest alerts created offline.
```
func syncMessagesToCloud() {
        let pendingMessages = messages.filter { $0.status == .pendingSync }
        for message in pendingMessages {
            postToCloud(message) { success in
                if success {
                    message.status = .synced
                    try? context.save()
                }
            }
        }
```

- `postToCloud` sends each message to the cloud server via a POST request. It ensures messages are correctly formatted and uploaded without errors.
```
private func postToCloud(_ message: Message, completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: "http://98.80.6.198:8000/messages") else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let jsonMessage = try? JSONEncoder().encode(message)
    request.httpBody = jsonMessage

    URLSession.shared.dataTask(with: request) { _, _, error in
        completion(error == nil)
    }.resume()
}
```


- `fetchMessagesFromCloud` retrieves the latest messages from the cloud server when online, ensuring the app has access to all recent updates from other users. Each fetched message is marked as synced.
```
func fetchMessagesFromCloud() {
     guard let url = URL(string: "http://98.80.6.198:8000/messages") else { return }

    URLSession.shared.dataTask(with: url) { data, _, _ in
        if let data = data {
            var cloudMessages = try? JSONDecoder().decode([Message].self, from: data)
            cloudMessages?.forEach { $0.status = .synced } 

        DispatchQueue.main.async {
            self.mergeCloudMessages(cloudMessages ?? [])       
        }
    }
 }.resume()
 }
```


- `mergeCloudMessages` checks for duplicates and merges new cloud messages with local data, ensuring the user has a complete and up-to-date set of alerts.
```
private func mergeCloudMessages(_ cloudMessages: [Message]) {
    for cloudMessage in cloudMessages {
        if messages.allSatisfy({ $0.id != cloudMessage.id }) {
            context.insert(cloudMessage)
            }
        }
        try? context.save()
    }
```
### LocationManager
The LocationManager is built using Apple's CoreLocation framework and integrates with SwiftUI to enable real-time updates of location data in the user interface.

**What does it do?**
When the app initializes, the LocationManager is instantiated and performs several steps:

1. **Requesting Location Permission**: It checks the current location permission status. If permission is not yet determined, it prompts the user to allow location access. This permission is essential for the app to function as it needs to track the user’s location.

       ```
              func requestLocationAccess() {
            if manager.authorizationStatus == .notDetermined {
                manager.requestWhenInUseAuthorization()
            } else {
                checkLocationAuthorization()
            }
        }
       ```
2. **Tracking Authorization Status**: A delegate (CLLocationManagerDelegate) is assigned to LocationManager to continuously monitor changes to the user’s location permission. This delegate listens for any updates to the authorization status, such as when the user grants or revokes permission. The authorization status is stored in a Boolean (hasLocationAccess) to reflect whether the app currently has location access.
       
    ```
    // delegate definition in init
       override init() {
        super.init()
        manager.delegate = self
    }

    // delegate listening for changes
      func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    ```
    
3. **Updating User Location**: When the user’s location is updated, the delegate captures the new location and updates the userLocation property. This ensures that the app always has access to the user’s latest location, which can then be used to update the interface or perform location-based actions in real time.
       
    ```
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          guard let location = locations.last else { return }
          userLocation = location
      }
    ```
    
4. **Error Handling**: If an error occurs (e.g., due to signal issues or restricted permissions), the delegate’s locationManager(_:didFailWithError:) method is triggered. This method logs a message to help with debugging and, if needed, can update the user interface to inform the user that location data is temporarily unavailable.
       
    ```
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    ```

### Network Monitor

Observes connectivity on your phone. The `NWPathMonitor` detects a change in this connectivity. It updates the `IsConnected` property dynamically based on online or offline and publishes this property to the rest of the app, which allows the app to respond to connectivity changes in real time. 

```
class NetworkMonitor: ObservableObject {
    private var monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    
    @Published var isConnected: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                print("NetworkMonitor detected network change: \(self?.isConnected == true ? "Online" : "Offline")")
            }
        }
        monitor.start(queue: queue)
    }
}
```
**Used ChatGPT and a couple of Youtube videos for this logic!**

## PublicSync Backend Logic


### rescueAPI Folder

This folder contains the backend API, built with FastAPI and SQLAlchemy, which powers EchoAlert's data handling and storage. It includes:

- **entities**: Defines the data models and tables used in the backend, like `message.py`. This is the strucutre of our table and what our models are based. 

```

class Message(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    content: str
    latitude: float
    longitude: float
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))  
    status: MessageStatus
    category: MessageCategory


```

- **models**: Pydantic models for request and response schemas, such as `message_create.py` and `message_details.py`
- **services**: Contains logic for handling CRUD (create, read, update, delete) operations with `message_service.py`
- **database.py**: Manages database connection using SQLAlchemy
- **main.py**: The main application file for FastAPI, defining API endpoints for message CRUD operations. Also includes a forced on startup method that was used to help create tables initially. Here is our main methods for messages:   

- read_messages: Get all messages Method
```
@app.get("/messages/", response_model=List[MessageDetails])
def read_messages(db: Session = Depends(get_db_session)):
    try:
        return message_service.get_all_messages(db)
    except Exception as e:
        print(f"Error occurred while fetching messages: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error while fetching messages.")
```
    
- create_message : Creates(posts) messages
```
@app.post("/messages/", response_model=MessageDetails)
def create_message(message_data: MessageCreate, db: Session = Depends(get_db_session)):
    try:
        return message_service.create_message(message_data, db)
    except Exception as e:
        print(f"Error occurred during message creation: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error while creating the message.")
```
- update_message_status: Updates (puts) syncing status of messages
```
@app.put("/messages/{message_id}/status", response_model=MessageDetails)
def update_message_status(message_id: int, status: MessageStatus, db: Session = Depends(get_db_session)):
    try:
        updated_message = message_service.update_message_status(message_id, status, db)
        if not updated_message:
            raise HTTPException(status_code=404, detail="Message not found")
        return updated_message
    except Exception as e:
        db.rollback()
        print(f"Error occurred while updating the status of message with ID {message_id}: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error while updating the message status.")

``` 
- delete_message: Deletes messages by id 
```
@app.delete("/messages/{message_id}")
def delete_message(message_id: int, db: Session = Depends(get_db_session)):
    try:
        if not message_service.delete_message(message_id, db):
            raise HTTPException(status_code=404, detail="Message not found")
        return {"detail": "Message deleted successfully"}
    except Exception as e:
        db.rollback()
        print(f"Error occurred while deleting the message with ID {message_id}: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error while deleting the message.")
```

---

### terraform Folder

This folder contains the configuration files for setting up AWS infrastructure using Terraform. The configurations include provisioning an RDS PostgreSQL instance, EC2 instances, and necessary security configurations for the backend.

- `main.tf`: This file helped define and provision cloud infrastructure on AWS:

    1. AWS Provider Configuration: Defines AWS region for infrastructure deployment

    2.  Virtual Private Cloud (VPC) : Provides a secure, isolated environment for all resources


    3. Internet Gateway and Route Table : Enables internet connectivity for resources within the VPC.

    4. Subnets and Route Table Associations : Creates subnets for resource placement across multiple availability zones

    5. RDS PostgreSQL Database: Sets up a PostgreSQL database with high availability
 

    7. EC2 Instance: Provisions an EC2 instance for backend service hosting

    8. Outputs: Outputs connection details for EC2 and RDS instances


- All other files are initilized when declaring the directory as a terraform directory using `terraform init` command

#### Resouces for PublicSync

- We used Terraform documentation that can be found all throughout Hashicorp's Terraform registry website.
- We utilized ChatGPT for configuration assistance and bug fixes when facing internal server connectivity issues
- Upasana works with AWS 5 days a week at her job and was able to bug fix throughout the management console when needed to tweak TF configs.




