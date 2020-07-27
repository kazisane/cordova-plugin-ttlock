ttlockName = 'TTLockPlugin'

exec = (method, params) ->
  new Promise (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, method, params)

ttlock = {
  # Universal
  startScan: (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, 'lock_startScan', [])
  stopScan: -> exec 'lock_stopScan', []
  init: (address) -> exec 'lock_init', [address]
  controlLock: (controlAction, lockData, lockMac) -> exec 'lock_control', [controlAction, lockData, lockMac]
  getTime: (lockData, lockMac) -> exec 'lock_getTime', [lockData, lockMac]
  setTime: (lockData, lockMac, time) -> exec 'lock_getTime', [lockData, lockMac, time]

  # Android
  isBLEEnabled: -> exec 'lock_isBLEEnabled', []
  requestBleEnable: -> exec 'lock_requestBleEnable', []
  prepareBTService: -> exec 'lock_prepareBTService', []
  stopBTService: -> exec 'lock_stopBTService', []
  
  getRemoteUnlockSwitchState: (lockData, lockMac) -> exec 'lock_getRemoteUnlockSwitchState', [lockData, lockMac]
  setRemoteUnlockSwitchState: (enabled, lockData, lockMac) -> exec 'lock_setRemoteUnlockSwitchState', [enabled, lockData, lockMac]

  # IOS
  setupBluetooth: -> exec 'lock_setupBluetooth', []
}

gateway = {
  isBLEEnabled: -> exec 'gateway_isBLEEnabled', []
  requestBleEnable: -> exec 'gateway_requestBleEnable', []
  prepareBTService: -> exec 'gateway_prepareBTService', []
  stopBTService: -> exec 'gateway_stopBTService', []

  startScanGateway: (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, 'gateway_startScanGateway', [])
  stopScanGateway: -> exec 'gateway_stopScanGateway', []
  
  connectGateway: (gatewayMac) -> exec 'gateway_connectGateway', [gatewayMac]
  initGateway: (gatewayMac, uid, userPwd, ssid, wifiPwd) -> exec 'gateway_initGateway', [gatewayMac, uid, userPwd, ssid, wifiPwd]

  scanWiFiByGateway: (gatewayMac, resolve, reject) -> cordova.exec(resolve, reject, ttlockName, 'gateway_scanWiFiByGateway', [gatewayMac])
}

ttlock.ControlAction = {
  Unlock: 3
  Lock: 6
}

ttlock.BluetoothState = {
  Unknown: 0
  Resetting: 1
  Unsupported: 2
  Unauthorized: 3
  PoweredOff: 4
  PoweredOn: 5
}

module.exports = {
  Lock: ttlock
  Gateway: gateway
}
