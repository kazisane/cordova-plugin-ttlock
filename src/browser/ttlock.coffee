ttlockName = 'TTLockPlugin'

exec = (method, params) ->
  new Promise (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, method, params)

Lock = {
  # Universal
  startScan: (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, 'lock_startScan', [])
  stopScan: -> exec 'lock_stopScan', []
  init: (lockMac, lockName, lockVersion) -> exec 'lock_init', [lockMac, lockName, lockVersion]
  reset: (lockData, lockMac) -> exec 'lock_reset', [lockData, lockMac]
  control: (controlAction, lockData, lockMac) -> exec 'lock_control', [controlAction, lockData, lockMac]
  getTime: (lockData, lockMac) -> exec 'lock_getTime', [lockData, lockMac]
  setTime: (lockData, lockMac, time) -> exec 'lock_getTime', [lockData, lockMac, time]

  # Android
  isBLEEnabled: -> exec 'lock_isBLEEnabled', []
  requestBleEnable: -> exec 'lock_requestBleEnable', []
  prepareBTService: -> exec 'lock_prepareBTService', []
  stopBTService: -> exec 'lock_stopBTService', []
  
  getRemoteUnlockSwitchState: (lockData, lockMac) -> exec 'lock_getRemoteUnlockSwitchState', [lockData, lockMac]
  setRemoteUnlockSwitchState: (lockData, lockMac) -> exec 'lock_setRemoteUnlockSwitchState', [lockData, lockMac, enabled]

  # IOS
  setupBluetooth: -> exec 'lock_setupBluetooth', []
}

Gateway = {
  isBLEEnabled: -> exec 'gateway_isBLEEnabled', []
  requestBleEnable: -> exec 'gateway_requestBleEnable', []
  prepareBTService: -> exec 'gateway_prepareBTService', []
  stopBTService: -> exec 'gateway_stopBTService', []

  startScan: (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, 'gateway_startScan', [])
  stopScan: -> exec 'gateway_stopScan', []
  connect: (gatewayMac) -> exec 'gateway_connect', [gatewayMac]
  disconnect: (gatewayMac) -> exec 'gateway_disconnect', [gatewayMac]
  init: (gatewayMac, uid, userPwd, ssid, wifiPwd) -> exec 'gateway_init', [gatewayMac, uid, userPwd, ssid, wifiPwd]
  scanWiFi: (gatewayMac, resolve, reject) -> cordova.exec(resolve, reject, ttlockName, 'gateway_scanWiFi', [gatewayMac])
  upgrade: (gatewayMac) -> exec 'gateway_upgrade', [gatewayMac]
}

TTLock = {
  Lock
  Gateway
}

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

module.exports = TTLock
