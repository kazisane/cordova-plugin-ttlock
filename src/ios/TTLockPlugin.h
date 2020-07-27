#import <Cordova/CDV.h>
#import <TTLock/TTLock.h>

@interface TTLockPlugin : CDVPlugin {

}

- (void)lock_setupBluetooth:(CDVInvokedUrlCommand *)command;
- (void)lock_isScanning:(CDVInvokedUrlCommand *)command;
- (void)lock_startScan:(CDVInvokedUrlCommand *)command;
- (void)lock_stopScan:(CDVInvokedUrlCommand *)command;
- (void)lock_init:(CDVInvokedUrlCommand *)command;
- (void)lock_setTime:(CDVInvokedUrlCommand *)command;
- (void)lock_getTime:(CDVInvokedUrlCommand *)command;
- (void)lock_setRemoteUnlockSwitchState:(CDVInvokedUrlCommand *)command;
- (void)lock_getRemoteUnlockSwitchState:(CDVInvokedUrlCommand *)command;
- (void)lock_control:(CDVInvokedUrlCommand *)command;

@end