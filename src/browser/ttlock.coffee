ttlockName = 'TTLockPlugin'

exec = (method, params) ->
  new Promise (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, method, params)

ttlock = {
  prepareBTService: -> exec 'prepareBTService', []
  stopBTService: -> exec 'stopBTService', []
  startScanLock: (resolve, reject) -> cordova.exec(resolve, reject, ttlockName, 'startScanLock', [])
  stopScanLock: -> exec 'stopScanLock', []
  isBLEEnabled: -> exec 'isBLEEnabled', []
  requestBleEnable: -> exec 'requestBleEnable', []
  initLock: (address) -> exec 'initLock', [address]

}
module.exports = ttlock
