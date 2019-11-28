var ttlockName = 'TTLockPlugin';
var ttlock = {
  prepareBTService: function(successCallback) {
    cordova.exec(successCallback, successCallback, ttlockName, 'prepareBTService', []);
  },
  stopBTService: function(successCallback) {
    cordova.exec(successCallback, successCallback, ttlockName, 'stopBTService', []);
  },
  startScanLock: function(successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, ttlockName, 'startScanLock', []);
  }
}
module.exports = ttlock;
