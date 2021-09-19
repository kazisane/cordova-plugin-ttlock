pluginName = 'TTLockPlugin'

exec = (method, params) ->
  new Promise (resolve, reject) -> cordova.exec(resolve, reject, pluginName, method, params)

Lock = {
  # Universal
  isScanning: -> exec 'lock_isScanning', []
  startScan: (resolve, reject) -> cordova.exec(resolve, reject, pluginName, 'lock_startScan', [])
  stopScan: -> exec 'lock_stopScan', []
  init: (lockMac, lockName, lockVersion) -> exec 'lock_init', [lockMac, lockName, lockVersion]
  reset: (lockData, lockMac) -> exec 'lock_reset', [lockData, lockMac]
  control: (controlAction, lockData, lockMac) -> exec 'lock_control', [controlAction, lockData, lockMac]
  getTime: (lockData, lockMac) -> exec 'lock_getTime', [lockData, lockMac]
  setTime: (time, lockData, lockMac) -> exec 'lock_getTime', [time, lockData, lockMac]
  getRemoteUnlockSwitchState: (lockData, lockMac) -> exec 'lock_getRemoteUnlockSwitchState', [lockData, lockMac]
  setRemoteUnlockSwitchState: (enabled, lockData, lockMac) -> exec 'lock_setRemoteUnlockSwitchState', [enabled, lockData, lockMac]
  getOperationLog: (logType, lockData, lockMac) -> exec 'lock_getOperationLog', [logType, lockData, lockMac]

  addFingerprint: (startDate, endDate, lockData, lockMac, cb) ->
    if not cb and typeof lockMac is 'function'
      cb = lockMac
    cordova.exec(cb, cb, pluginName, 'lock_addFingerprint', [startDate, endDate, lockData, lockMac])
  getAllValidFingerprints: (lockData, lockMac) -> exec 'lock_getAllValidFingerprints', [lockData, lockMac]
  deleteFingerprint: (fingerprintNum, lockData, lockMac) -> exec 'lock_deleteFingerprint', [fingerprintNum, lockData, lockMac]
  clearAllFingerprints: (lockData, lockMac) -> exec 'lock_clearAllFingerprints', [lockData, lockMac]
  modifyFingerprintValidityPeriod: (startDate, endDate, fingerprintNum, lockData, lockMac) -> exec 'lock_modifyFingerprintValidityPeriod', [startDate, endDate, fingerprintNum, lockData, lockMac]

  # Android
  isBLEEnabled: -> exec 'lock_isBLEEnabled', []
  requestBleEnable: -> exec 'lock_requestBleEnable', []
  prepareBTService: -> exec 'lock_prepareBTService', []
  stopBTService: -> exec 'lock_stopBTService', []

  # IOS
  setupBluetooth: -> exec 'lock_setupBluetooth', []
}

Gateway = {
  isBLEEnabled: -> exec 'gateway_isBLEEnabled', []
  requestBleEnable: -> exec 'gateway_requestBleEnable', []
  prepareBTService: -> exec 'gateway_prepareBTService', []
  stopBTService: -> exec 'gateway_stopBTService', []

  startScan: (resolve, reject) -> cordova.exec(resolve, reject, pluginName, 'gateway_startScan', [])
  stopScan: -> exec 'gateway_stopScan', []
  connect: (gatewayMac) -> exec 'gateway_connect', [gatewayMac]
  disconnect: (gatewayMac) -> exec 'gateway_disconnect', [gatewayMac]
  init: (gatewayMac, uid, userPwd, ssid, wifiPwd) -> exec 'gateway_init', [gatewayMac, uid, userPwd, ssid, wifiPwd]
  scanWiFi: (gatewayMac, resolve, reject) -> cordova.exec(resolve, reject, pluginName, 'gateway_scanWiFi', [gatewayMac])
  upgrade: (gatewayMac) -> exec 'gateway_upgrade', [gatewayMac]
}

TTLock = {
  Lock
  Gateway
}

if navigator.platform == 'iPhone'
  TTLock.ControlAction = {
    Unlock: 1
    Lock: 2
  }
else
  TTLock.ControlAction = {
    Unlock: 3
    Lock: 6
  }

TTLock.BluetoothState = {
  Unknown: 0
  Resetting: 1
  Unsupported: 2
  Unauthorized: 3
  PoweredOff: 4
  PoweredOn: 5
}

if navigator.platform == 'iPhone'
  TTLock.LogType = {
    All: 2
    New: 1
  }
else
  TTLock.LogType = {
    All: 11
    New: 12
  }

TTLock.LogRecordType = {
    MobileUnlock: 1
    ServerUnlock: 3
    KeyboardPasswordUnlock: 4
    KeyboardModifyPassword: 5
    KeyboardRemoveSinglePassword: 6
    ErrorPasswordUnlock: 7
    KeyboardRemoveAllPasswords: 8
    KeyboardPasswordKicked: 9
    UseDeleteCode: 10
    PasscodeExpired: 11
    SpaceInsufficient: 12
    PasscodeInBlacklist: 13
    DoorReboot: 14
    AddIC: 15
    ClearIC: 16
    ICUnlock: 17
    DeleteIC: 18
    ICUnlockFailed: 25
    BleLock: 26
    KeyUnlock: 27
    GatewayUnlock: 28
    IllegalUnlock: 29
    DoorSensorLock: 30
    DoorSensorUnlock: 31
    DoorGoOut: 32
  }

module.exports = TTLock
