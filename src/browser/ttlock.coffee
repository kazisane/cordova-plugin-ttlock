ttlockName = 'TTLockPlugin'

exec = (method, params) ->
  new Promise (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, method, params)

ttlock = {
  isBLEEnabled: -> exec 'lock_isBLEEnabled', []
  requestBleEnable: -> exec 'lock_requestBleEnable', []
  prepareBTService: -> exec 'lock_prepareBTService', []
  stopBTService: -> exec 'lock_stopBTService', []
  startScanLock: (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, 'lock_startScanLock', [])
  stopScanLock: -> exec 'lock_stopScanLock', []
  initLock: (address) -> exec 'lock_initLock', [address]
  controlLock: (controlAction, lockData, lockMac) -> exec 'lock_controlLock', [controlAction, lockData, lockMac]
  getLockTime: (lockData, lockMac) -> exec 'lock_getLockTime', [lockData, lockMac]

  getRemoteUnlockSwitchState: (lockData, lockMac) -> exec 'lock_getRemoteUnlockSwitchState', [lockData, lockMac]
  setRemoteUnlockSwitchState: (enabled, lockData, lockMac) -> exec 'lock_setRemoteUnlockSwitchState', [enabled, lockData, lockMac]
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

module.exports = {
  Lock: ttlock
  Gateway: gateway
}
