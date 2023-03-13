# iOS-tracelet-reader



## Getting started


# Instantiate BluetoothManager

`btManager = BluetoothManager()`


# UUIDs
- Find/adjust UUIDs in `UUIDs.swift`.


# Get Tracelet Position

```
let xPos = decoder.getTraceletPosition(byteArray: byteArray).0
let yPos = decoder.getTraceletPosition(byteArray: byteArray).1
let zPos = decoder.getTraceletPosition(byteArray: byteArray).2
```
