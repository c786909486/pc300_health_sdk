class BlueDevice {

  static final int BOND_NONE = 10;
  static final int BOND_BONDING = 11;
  static final int BOND_BONDED = 12;


  /// Bluetooth device type, Classic - BR/EDR devices
  static final int DEVICE_TYPE_CLASSIC = 1;

  /// Bluetooth device type, Low Energy - LE-only
  static final int DEVICE_TYPE_LE = 2;

  /// Bluetooth device type, Dual Mode - BR/EDR/LE
  static final int DEVICE_TYPE_DUAL = 3;

  String name;
  String address;
  int bondState;
  int type;

  BlueDevice({
    this.name,
    this.address,
    this.bondState,
    this.type
  });

  BlueDevice.fromJson(Map data){
    name = data["name"];
    address = data["address"];
    bondState = data["bondState"] = BOND_NONE;
    type = data["type"] = DEVICE_TYPE_CLASSIC;
  }

  @override
  String toString() {
    return 'BlueDevice{name: $name, address: $address, bondState: $bondState, type: $type}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlueDevice &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;
}