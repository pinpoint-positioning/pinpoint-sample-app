// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: tracelet.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: (c) 2023 Ci4Rail GmbH

// Protobuf definitiions for Ci4Rail Tracelet, e.g. SIO02.
// It defines the messages exchanged between the Tracelet and the localization
// system. The messages are transported over TCP, with a little framing
// protocol:
//
// Format of a TCP message:
// - Byte 0: 0xFE
// - Byte 1: 0xED
// - Byte 2..5: Length of marshalled protobuf data (Byte 2=LSB)
// - Byte 6..n: Marshalled Protobuf Data
//
// The Tracelet is the TCP client, the localization system is the TCP server.

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct Tracelet_ServerToTracelet {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// id of the request, will be echoed in StatusResponse
  var id: Int32 = 0

  var type: Tracelet_ServerToTracelet.OneOf_Type? = nil

  /// request the location of the tracelet
  var location: Tracelet_ServerToTracelet.LocationRequest {
    get {
      if case .location(let v)? = type {return v}
      return Tracelet_ServerToTracelet.LocationRequest()
    }
    set {type = .location(newValue)}
  }

  /// request the status of the tracelet
  var status: Tracelet_ServerToTracelet.StatusRequest {
    get {
      if case .status(let v)? = type {return v}
      return Tracelet_ServerToTracelet.StatusRequest()
    }
    set {type = .status(newValue)}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum OneOf_Type: Equatable {
    /// request the location of the tracelet
    case location(Tracelet_ServerToTracelet.LocationRequest)
    /// request the status of the tracelet
    case status(Tracelet_ServerToTracelet.StatusRequest)

  #if !swift(>=4.1)
    static func ==(lhs: Tracelet_ServerToTracelet.OneOf_Type, rhs: Tracelet_ServerToTracelet.OneOf_Type) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.location, .location): return {
        guard case .location(let l) = lhs, case .location(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.status, .status): return {
        guard case .status(let l) = lhs, case .status(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  struct LocationRequest {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
  }

  struct StatusRequest {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
  }

  init() {}
}

struct Tracelet_TraceletToServer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Tracelet will echo the ID of the request here.
  /// For messages sent without a request, the ID is 0
  var id: Int32 = 0

  /// timestamp when the message was sent by the tracelet
  /// If the Tracelet has no valid time, receive_ts is set to 1970-Jan-1 00:00
  /// UTC
  var deliveryTs: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _deliveryTs ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_deliveryTs = newValue}
  }
  /// Returns true if `deliveryTs` has been explicitly set.
  var hasDeliveryTs: Bool {return self._deliveryTs != nil}
  /// Clears the value of `deliveryTs`. Subsequent reads from it will return its default value.
  mutating func clearDeliveryTs() {self._deliveryTs = nil}

  /// tracelet ID as provisioned in tracelet. Could be a vehicle ID
  var traceletID: String = String()

  /// status of the tracelet ignition signal
  var ignition: Bool = false

  var type: Tracelet_TraceletToServer.OneOf_Type? = nil

  /// periodically sent by the tracelet or in
  var location: Tracelet_TraceletToServer.Location {
    get {
      if case .location(let v)? = type {return v}
      return Tracelet_TraceletToServer.Location()
    }
    set {type = .location(newValue)}
  }

  /// response to a location request
  var status: Tracelet_TraceletToServer.StatusResponse {
    get {
      if case .status(let v)? = type {return v}
      return Tracelet_TraceletToServer.StatusResponse()
    }
    set {type = .status(newValue)}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum OneOf_Type: Equatable {
    /// periodically sent by the tracelet or in
    case location(Tracelet_TraceletToServer.Location)
    /// response to a location request
    case status(Tracelet_TraceletToServer.StatusResponse)

  #if !swift(>=4.1)
    static func ==(lhs: Tracelet_TraceletToServer.OneOf_Type, rhs: Tracelet_TraceletToServer.OneOf_Type) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.location, .location): return {
        guard case .location(let l) = lhs, case .location(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.status, .status): return {
        guard case .status(let l) = lhs, case .status(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  /// Sub-message sent in response to a location request OR
  /// periodically sent by the tracelet
  struct Location {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// Data from GNSS subsystem
    var gnss: Tracelet_TraceletToServer.Location.Gnss {
      get {return _storage._gnss ?? Tracelet_TraceletToServer.Location.Gnss()}
      set {_uniqueStorage()._gnss = newValue}
    }
    /// Returns true if `gnss` has been explicitly set.
    var hasGnss: Bool {return _storage._gnss != nil}
    /// Clears the value of `gnss`. Subsequent reads from it will return its default value.
    mutating func clearGnss() {_uniqueStorage()._gnss = nil}

    /// Data from UWB subsystem
    var uwb: Tracelet_TraceletToServer.Location.Uwb {
      get {return _storage._uwb ?? Tracelet_TraceletToServer.Location.Uwb()}
      set {_uniqueStorage()._uwb = newValue}
    }
    /// Returns true if `uwb` has been explicitly set.
    var hasUwb: Bool {return _storage._uwb != nil}
    /// Clears the value of `uwb`. Subsequent reads from it will return its default value.
    mutating func clearUwb() {_uniqueStorage()._uwb = nil}

    /// Driving direction of the vehicle
    var direction: Tracelet_TraceletToServer.Location.Direction {
      get {return _storage._direction}
      set {_uniqueStorage()._direction = newValue}
    }

    /// Vehicle Speed in [m/s]
    var speed: Double {
      get {return _storage._speed}
      set {_uniqueStorage()._speed = newValue}
    }

    /// Vehicle Mileage in [km]
    var mileage: Int32 {
      get {return _storage._mileage}
      set {_uniqueStorage()._mileage = newValue}
    }

    /// Current Tracelet Temperature in [°C]
    var temperature: Double {
      get {return _storage._temperature}
      set {_uniqueStorage()._temperature = newValue}
    }

    var unknownFields = SwiftProtobuf.UnknownStorage()

    enum Direction: SwiftProtobuf.Enum {
      typealias RawValue = Int

      /// Invalid direction
      case noDirection // = 0

      /// CAB A
      case cabADirection // = 1

      /// CAB B
      case cabBDirection // = 2
      case UNRECOGNIZED(Int)

      init() {
        self = .noDirection
      }

      init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .noDirection
        case 1: self = .cabADirection
        case 2: self = .cabBDirection
        default: self = .UNRECOGNIZED(rawValue)
        }
      }

      var rawValue: Int {
        switch self {
        case .noDirection: return 0
        case .cabADirection: return 1
        case .cabBDirection: return 2
        case .UNRECOGNIZED(let i): return i
        }
      }

    }

    struct Gnss {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      /// GNSS location valid. If false, the other fields are not valid
      var valid: Bool = false

      /// WGS84 coordinates
      /// latitude in [deg]
      var latitude: Double = 0

      /// longitude in [deg]
      var longitude: Double = 0

      /// altitude in [m]
      var altitude: Double = 0

      /// horizontal accuracy in [m]
      var eph: Double = 0

      /// vertical accuracy in [m]
      var epv: Double = 0

      /// type of fix 
      /// 0 = invalid, 1 = GPS fix, 2 = DGPS fix, 3 = PPS fix, 4 = Real Time Kinematic, 
      /// 5 = Float RTK, 6 = estimated, 7 = Manual input mode, 8 = Simulation mode
      var fixType: Int32 = 0

      var unknownFields = SwiftProtobuf.UnknownStorage()

      init() {}
    }

    struct Uwb {
      // SwiftProtobuf.Message conformance is added in an extension below. See the
      // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
      // methods supported on all messages.

      /// UWB location valid. If false, the other fields are not valid
      var valid: Bool = false

      /// location of tracelet in space
      /// Units: [m], can be negative. Resolution 0.1m
      var x: Double = 0

      var y: Double = 0

      var z: Double = 0

      /// Site ID
      /// a 16 bit unsigned value
      var siteID: UInt32 = 0

      /// Location signature
      /// can be used to validate the received location
      var locationSignature: UInt64 = 0

      /// horizontal accuracy in [m]
      var eph: Double = 0

      var unknownFields = SwiftProtobuf.UnknownStorage()

      init() {}
    }

    init() {}

    fileprivate var _storage = _StorageClass.defaultInstance
  }

  /// Sub-message sent in response to a status request
  struct StatusResponse {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// number of tracelet power Ups
    var powerUpCount: Int32 = 0

    /// Tracelet has a valid time
    var hasTime_p: Bool = false

    /// Status of the UWB module (0=OK, error code otherwise)
    var uwbModuleStatus: Int32 = 0

    /// Status of the GNSS module (0=OK, error code otherwise)
    var gnssModuleStatus: Int32 = 0

    /// Status of Main processor IMU (0=OK, error code otherwise)
    var imu1Status: Int32 = 0

    /// Status of tachometer signal (0=OK, error code otherwise)
    var tachoStatus: Int32 = 0

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
  }

  init() {}

  fileprivate var _deliveryTs: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

#if swift(>=4.2)

extension Tracelet_TraceletToServer.Location.Direction: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [Tracelet_TraceletToServer.Location.Direction] = [
    .noDirection,
    .cabADirection,
    .cabBDirection,
  ]
}

#endif  // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
extension Tracelet_ServerToTracelet: @unchecked Sendable {}
extension Tracelet_ServerToTracelet.OneOf_Type: @unchecked Sendable {}
extension Tracelet_ServerToTracelet.LocationRequest: @unchecked Sendable {}
extension Tracelet_ServerToTracelet.StatusRequest: @unchecked Sendable {}
extension Tracelet_TraceletToServer: @unchecked Sendable {}
extension Tracelet_TraceletToServer.OneOf_Type: @unchecked Sendable {}
extension Tracelet_TraceletToServer.Location: @unchecked Sendable {}
extension Tracelet_TraceletToServer.Location.Direction: @unchecked Sendable {}
extension Tracelet_TraceletToServer.Location.Gnss: @unchecked Sendable {}
extension Tracelet_TraceletToServer.Location.Uwb: @unchecked Sendable {}
extension Tracelet_TraceletToServer.StatusResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "tracelet"

extension Tracelet_ServerToTracelet: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ServerToTracelet"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "location"),
    3: .same(proto: "status"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.id) }()
      case 2: try {
        var v: Tracelet_ServerToTracelet.LocationRequest?
        var hadOneofValue = false
        if let current = self.type {
          hadOneofValue = true
          if case .location(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.type = .location(v)
        }
      }()
      case 3: try {
        var v: Tracelet_ServerToTracelet.StatusRequest?
        var hadOneofValue = false
        if let current = self.type {
          hadOneofValue = true
          if case .status(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.type = .status(v)
        }
      }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.id != 0 {
      try visitor.visitSingularInt32Field(value: self.id, fieldNumber: 1)
    }
    switch self.type {
    case .location?: try {
      guard case .location(let v)? = self.type else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case .status?: try {
      guard case .status(let v)? = self.type else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Tracelet_ServerToTracelet, rhs: Tracelet_ServerToTracelet) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.type != rhs.type {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Tracelet_ServerToTracelet.LocationRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = Tracelet_ServerToTracelet.protoMessageName + ".LocationRequest"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Tracelet_ServerToTracelet.LocationRequest, rhs: Tracelet_ServerToTracelet.LocationRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Tracelet_ServerToTracelet.StatusRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = Tracelet_ServerToTracelet.protoMessageName + ".StatusRequest"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Tracelet_ServerToTracelet.StatusRequest, rhs: Tracelet_ServerToTracelet.StatusRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Tracelet_TraceletToServer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".TraceletToServer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .standard(proto: "delivery_ts"),
    3: .standard(proto: "tracelet_id"),
    4: .same(proto: "ignition"),
    5: .same(proto: "location"),
    6: .same(proto: "status"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._deliveryTs) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.traceletID) }()
      case 4: try { try decoder.decodeSingularBoolField(value: &self.ignition) }()
      case 5: try {
        var v: Tracelet_TraceletToServer.Location?
        var hadOneofValue = false
        if let current = self.type {
          hadOneofValue = true
          if case .location(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.type = .location(v)
        }
      }()
      case 6: try {
        var v: Tracelet_TraceletToServer.StatusResponse?
        var hadOneofValue = false
        if let current = self.type {
          hadOneofValue = true
          if case .status(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.type = .status(v)
        }
      }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.id != 0 {
      try visitor.visitSingularInt32Field(value: self.id, fieldNumber: 1)
    }
    try { if let v = self._deliveryTs {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !self.traceletID.isEmpty {
      try visitor.visitSingularStringField(value: self.traceletID, fieldNumber: 3)
    }
    if self.ignition != false {
      try visitor.visitSingularBoolField(value: self.ignition, fieldNumber: 4)
    }
    switch self.type {
    case .location?: try {
      guard case .location(let v)? = self.type else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    }()
    case .status?: try {
      guard case .status(let v)? = self.type else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Tracelet_TraceletToServer, rhs: Tracelet_TraceletToServer) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs._deliveryTs != rhs._deliveryTs {return false}
    if lhs.traceletID != rhs.traceletID {return false}
    if lhs.ignition != rhs.ignition {return false}
    if lhs.type != rhs.type {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Tracelet_TraceletToServer.Location: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = Tracelet_TraceletToServer.protoMessageName + ".Location"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "gnss"),
    2: .same(proto: "uwb"),
    3: .same(proto: "direction"),
    4: .same(proto: "speed"),
    5: .same(proto: "mileage"),
    6: .same(proto: "temperature"),
  ]

  fileprivate class _StorageClass {
    var _gnss: Tracelet_TraceletToServer.Location.Gnss? = nil
    var _uwb: Tracelet_TraceletToServer.Location.Uwb? = nil
    var _direction: Tracelet_TraceletToServer.Location.Direction = .noDirection
    var _speed: Double = 0
    var _mileage: Int32 = 0
    var _temperature: Double = 0

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _gnss = source._gnss
      _uwb = source._uwb
      _direction = source._direction
      _speed = source._speed
      _mileage = source._mileage
      _temperature = source._temperature
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try { try decoder.decodeSingularMessageField(value: &_storage._gnss) }()
        case 2: try { try decoder.decodeSingularMessageField(value: &_storage._uwb) }()
        case 3: try { try decoder.decodeSingularEnumField(value: &_storage._direction) }()
        case 4: try { try decoder.decodeSingularDoubleField(value: &_storage._speed) }()
        case 5: try { try decoder.decodeSingularInt32Field(value: &_storage._mileage) }()
        case 6: try { try decoder.decodeSingularDoubleField(value: &_storage._temperature) }()
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every if/case branch local when no optimizations
      // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
      // https://github.com/apple/swift-protobuf/issues/1182
      try { if let v = _storage._gnss {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      } }()
      try { if let v = _storage._uwb {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      } }()
      if _storage._direction != .noDirection {
        try visitor.visitSingularEnumField(value: _storage._direction, fieldNumber: 3)
      }
      if _storage._speed != 0 {
        try visitor.visitSingularDoubleField(value: _storage._speed, fieldNumber: 4)
      }
      if _storage._mileage != 0 {
        try visitor.visitSingularInt32Field(value: _storage._mileage, fieldNumber: 5)
      }
      if _storage._temperature != 0 {
        try visitor.visitSingularDoubleField(value: _storage._temperature, fieldNumber: 6)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Tracelet_TraceletToServer.Location, rhs: Tracelet_TraceletToServer.Location) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._gnss != rhs_storage._gnss {return false}
        if _storage._uwb != rhs_storage._uwb {return false}
        if _storage._direction != rhs_storage._direction {return false}
        if _storage._speed != rhs_storage._speed {return false}
        if _storage._mileage != rhs_storage._mileage {return false}
        if _storage._temperature != rhs_storage._temperature {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Tracelet_TraceletToServer.Location.Direction: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "NO_DIRECTION"),
    1: .same(proto: "CAB_A_DIRECTION"),
    2: .same(proto: "CAB_B_DIRECTION"),
  ]
}

extension Tracelet_TraceletToServer.Location.Gnss: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = Tracelet_TraceletToServer.Location.protoMessageName + ".Gnss"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "valid"),
    2: .same(proto: "latitude"),
    3: .same(proto: "longitude"),
    4: .same(proto: "altitude"),
    5: .same(proto: "eph"),
    6: .same(proto: "epv"),
    7: .standard(proto: "fix_type"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBoolField(value: &self.valid) }()
      case 2: try { try decoder.decodeSingularDoubleField(value: &self.latitude) }()
      case 3: try { try decoder.decodeSingularDoubleField(value: &self.longitude) }()
      case 4: try { try decoder.decodeSingularDoubleField(value: &self.altitude) }()
      case 5: try { try decoder.decodeSingularDoubleField(value: &self.eph) }()
      case 6: try { try decoder.decodeSingularDoubleField(value: &self.epv) }()
      case 7: try { try decoder.decodeSingularInt32Field(value: &self.fixType) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.valid != false {
      try visitor.visitSingularBoolField(value: self.valid, fieldNumber: 1)
    }
    if self.latitude != 0 {
      try visitor.visitSingularDoubleField(value: self.latitude, fieldNumber: 2)
    }
    if self.longitude != 0 {
      try visitor.visitSingularDoubleField(value: self.longitude, fieldNumber: 3)
    }
    if self.altitude != 0 {
      try visitor.visitSingularDoubleField(value: self.altitude, fieldNumber: 4)
    }
    if self.eph != 0 {
      try visitor.visitSingularDoubleField(value: self.eph, fieldNumber: 5)
    }
    if self.epv != 0 {
      try visitor.visitSingularDoubleField(value: self.epv, fieldNumber: 6)
    }
    if self.fixType != 0 {
      try visitor.visitSingularInt32Field(value: self.fixType, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Tracelet_TraceletToServer.Location.Gnss, rhs: Tracelet_TraceletToServer.Location.Gnss) -> Bool {
    if lhs.valid != rhs.valid {return false}
    if lhs.latitude != rhs.latitude {return false}
    if lhs.longitude != rhs.longitude {return false}
    if lhs.altitude != rhs.altitude {return false}
    if lhs.eph != rhs.eph {return false}
    if lhs.epv != rhs.epv {return false}
    if lhs.fixType != rhs.fixType {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Tracelet_TraceletToServer.Location.Uwb: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = Tracelet_TraceletToServer.Location.protoMessageName + ".Uwb"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "valid"),
    2: .same(proto: "x"),
    3: .same(proto: "y"),
    4: .same(proto: "z"),
    5: .standard(proto: "site_id"),
    6: .standard(proto: "location_signature"),
    7: .same(proto: "eph"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBoolField(value: &self.valid) }()
      case 2: try { try decoder.decodeSingularDoubleField(value: &self.x) }()
      case 3: try { try decoder.decodeSingularDoubleField(value: &self.y) }()
      case 4: try { try decoder.decodeSingularDoubleField(value: &self.z) }()
      case 5: try { try decoder.decodeSingularUInt32Field(value: &self.siteID) }()
      case 6: try { try decoder.decodeSingularFixed64Field(value: &self.locationSignature) }()
      case 7: try { try decoder.decodeSingularDoubleField(value: &self.eph) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.valid != false {
      try visitor.visitSingularBoolField(value: self.valid, fieldNumber: 1)
    }
    if self.x != 0 {
      try visitor.visitSingularDoubleField(value: self.x, fieldNumber: 2)
    }
    if self.y != 0 {
      try visitor.visitSingularDoubleField(value: self.y, fieldNumber: 3)
    }
    if self.z != 0 {
      try visitor.visitSingularDoubleField(value: self.z, fieldNumber: 4)
    }
    if self.siteID != 0 {
      try visitor.visitSingularUInt32Field(value: self.siteID, fieldNumber: 5)
    }
    if self.locationSignature != 0 {
      try visitor.visitSingularFixed64Field(value: self.locationSignature, fieldNumber: 6)
    }
    if self.eph != 0 {
      try visitor.visitSingularDoubleField(value: self.eph, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Tracelet_TraceletToServer.Location.Uwb, rhs: Tracelet_TraceletToServer.Location.Uwb) -> Bool {
    if lhs.valid != rhs.valid {return false}
    if lhs.x != rhs.x {return false}
    if lhs.y != rhs.y {return false}
    if lhs.z != rhs.z {return false}
    if lhs.siteID != rhs.siteID {return false}
    if lhs.locationSignature != rhs.locationSignature {return false}
    if lhs.eph != rhs.eph {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Tracelet_TraceletToServer.StatusResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = Tracelet_TraceletToServer.protoMessageName + ".StatusResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "power_up_count"),
    2: .standard(proto: "has_time"),
    3: .standard(proto: "uwb_module_status"),
    4: .standard(proto: "gnss_module_status"),
    5: .standard(proto: "imu1_status"),
    6: .standard(proto: "tacho_status"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.powerUpCount) }()
      case 2: try { try decoder.decodeSingularBoolField(value: &self.hasTime_p) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.uwbModuleStatus) }()
      case 4: try { try decoder.decodeSingularInt32Field(value: &self.gnssModuleStatus) }()
      case 5: try { try decoder.decodeSingularInt32Field(value: &self.imu1Status) }()
      case 6: try { try decoder.decodeSingularInt32Field(value: &self.tachoStatus) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.powerUpCount != 0 {
      try visitor.visitSingularInt32Field(value: self.powerUpCount, fieldNumber: 1)
    }
    if self.hasTime_p != false {
      try visitor.visitSingularBoolField(value: self.hasTime_p, fieldNumber: 2)
    }
    if self.uwbModuleStatus != 0 {
      try visitor.visitSingularInt32Field(value: self.uwbModuleStatus, fieldNumber: 3)
    }
    if self.gnssModuleStatus != 0 {
      try visitor.visitSingularInt32Field(value: self.gnssModuleStatus, fieldNumber: 4)
    }
    if self.imu1Status != 0 {
      try visitor.visitSingularInt32Field(value: self.imu1Status, fieldNumber: 5)
    }
    if self.tachoStatus != 0 {
      try visitor.visitSingularInt32Field(value: self.tachoStatus, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Tracelet_TraceletToServer.StatusResponse, rhs: Tracelet_TraceletToServer.StatusResponse) -> Bool {
    if lhs.powerUpCount != rhs.powerUpCount {return false}
    if lhs.hasTime_p != rhs.hasTime_p {return false}
    if lhs.uwbModuleStatus != rhs.uwbModuleStatus {return false}
    if lhs.gnssModuleStatus != rhs.gnssModuleStatus {return false}
    if lhs.imu1Status != rhs.imu1Status {return false}
    if lhs.tachoStatus != rhs.tachoStatus {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
