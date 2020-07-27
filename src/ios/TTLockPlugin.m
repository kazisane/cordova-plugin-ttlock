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
      scanModel.lockName, @"lockName",
      scanModel.lockMac, @"lockMac",
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
  NSDictionary *arguments = [self getArgsObject:command.arguments];

  [TTLock initLockWithDict:arguments success:^(NSString *lockData, long long specialValue) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      lockData, @"lockData",
      specialValue, @"specialValue",
    nil];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithInt:(int)errorCode], @"errorCode",
      errorMsg, @"errorMessage",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"%@",errorMsg);
  }];
}

- (void)lock_control:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];
  NSInteger action = (NSInteger)[command argumentAtIndex:1];

  [TTLock controlLockWithControlAction:acton lockData:lockData success:^(long long lockTime, NSInteger electricQuantity, long long uniqueId) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      lockTime, @"lockTime",
      lockTime, @"lockAction",
      electricQuantity, @"battery",
      electricQuantity, @"electricQuantity",
      uniqueId, @"uniqueId"
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithInt:(int)errorCode], @"errorCode",
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
        timestamp, @"timestamp",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:(int)errorCode], @"errorCode",
        errorMsg, @"errorMessage",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_setTime:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];
  (long long) timestamp = (long long)[command argumentAtIndex:1];

  [TTLock setLockTimeWithTimestamp:timestamp lockData:lockData
    success:^(void) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:(int)errorCode], @"errorCode",
        errorMsg, @"errorMessage",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

//General Helpers
- (NSDictionary*)getArgsObject:(NSArray *)args {
  if (args == nil) {
    return nil;
  }

  if (args.count != 1) {
    return nil;
  }

  NSObject* arg = [args objectAtIndex:0];

  if (![arg isKindOfClass:[NSDictionary class]]) {
    return nil;
  }

  return (NSDictionary *)[args objectAtIndex:0];
}

@end