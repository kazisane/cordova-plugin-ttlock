ttlockName = 'TTLockPlugin'
ttlock = {
  prepareBTService: (successCallback) ->
    cordova.exec(successCallback, successCallback, ttlockName, 'prepareBTService', [])

  stopBTService: (successCallback) ->
    cordova.exec(successCallback, successCallback, ttlockName, 'stopBTService', [])

  startScanLock: (successCallback, errorCallback) ->
    cordova.exec(successCallback, errorCallback, ttlockName, 'startScanLock', [])

  stopScanLock: (successCallback, errorCallback) ->
    cordova.exec(successCallback, errorCallback, ttlockName, 'stopScanLock', [])

  isBLEEnabled: (successCallback, errorCallback) ->
    cordova.exec(successCallback, errorCallback, ttlockName, 'isBLEEnabled', [])

  requestBleEnable: (successCallback, errorCallback) ->
    cordova.exec(successCallback, errorCallback, ttlockName, 'requestBleEnable', [])

}
module.exports = ttlock
