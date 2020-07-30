#import "TTLockPlugin.h"

@implementation TTLockPlugin

- (void)lock_setupBluetooth:(CDVInvokedUrlCommand *)command {
  TTLock.printLog = YES;
  [TTLock setupBluetooth:^(TTBluetoothState state) {
    NSLog(@"##############  TTLock is working, bluetooth state: %ld  ##############", (long)state);

    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:state];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)lock_startScan:(CDVInvokedUrlCommand *)command {
  NSLog(@"##############  TTLockPlugin lock_startScan  ##############");
  [TTLock startScan:^(TTScanModel *scanModel) {
    NSDictionary *device = [NSDictionary dictionaryWithObjectsAndKeys:
      scanModel.lockName, @"name",
      scanModel.lockMac, @"address",
      scanModel.lockVersion, @"version",
      !scanModel.isInited, @"isSettingMode",
      scanModel.electricQuantity, @"electricQuantity",
      scanModel.RSSI, @"rssi",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:device];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)lock_stopScan:(CDVInvokedUrlCommand *)command {
  [TTLock stopScan];
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)lock_init:(CDVInvokedUrlCommand *)command {
  NSString *lockMac = (NSString *)[command argumentAtIndex:0];
  NSString *lockName = (NSString *)[command argumentAtIndex:1];
  NSString *lockVersion = (NSString *)[command argumentAtIndex:2];

  NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
    lockMac, @"lockMac",
    lockName, @"lockName",
    lockVersion, @"lockVersion",
  nil];

  [TTLock initLockWithDict:arguments success:^(NSString *lockData, long long specialValue) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      lockData, @"lockData",
                                [NSNumber numberWithLongLong:specialValue], @"specialValue",
    nil];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithInteger:errorCode], @"errorCode",
      errorMsg, @"errorMessage",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"%@",errorMsg);
  }];
}

- (void)lock_reset:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock resetLockWithLockData:lockData success:^(void) {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithInteger:errorCode], @"errorCode",
      errorMsg, @"errorMessage",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"%@",errorMsg);
  }];
}

- (void)lock_control:(CDVInvokedUrlCommand *)command {
  TTControlAction action = (TTControlAction)[(NSNumber *)[command argumentAtIndex:0] integerValue];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock controlLockWithControlAction:action lockData:lockData success:^(long long lockTime, NSInteger electricQuantity, long long uniqueId) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithLongLong:lockTime], @"lockTime",
      [NSNumber numberWithLongLong:lockTime], @"lockAction",
      [NSNumber numberWithInteger:electricQuantity], @"battery",
      [NSNumber numberWithInteger:electricQuantity], @"electricQuantity",
      [NSNumber numberWithLongLong:uniqueId], @"uniqueId",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithInteger:errorCode], @"errorCode",
      errorMsg, @"errorMessage",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"%@",errorMsg);
  }];
}

- (void)lock_getTime:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock getLockTimeWithLockData:lockData
    success:^(long long timestamp) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithLongLong:timestamp], @"timestamp",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:errorCode], @"errorCode",
        errorMsg, @"errorMessage",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_setTime:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];
  long long timestamp = (long long)[command argumentAtIndex:1];

  [TTLock setLockTimeWithTimestamp:timestamp lockData:lockData
    success:^(void) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:errorCode], @"errorCode",
        errorMsg, @"errorMessage",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

@end
