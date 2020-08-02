#import "TTLockPlugin.h"

@implementation TTLockPlugin

- (void)lock_isScanning:(CDVInvokedUrlCommand *)command {
  CDVPluginResult* pluginResult = nil;
  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TTLock.isScanning];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

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
      [NSNumber numberWithBool:!scanModel.isInited], @"isSettingMode",
      [NSNumber numberWithInteger:scanModel.electricQuantity], @"electricQuantity",
      [NSNumber numberWithInteger:scanModel.RSSI], @"rssi",
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
      [TTLockPlugin getLockFeatures:specialValue], @"features",
    nil];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"lock_init %@",errorMsg);
  }];
}

- (void)lock_reset:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock resetLockWithLockData:lockData success:^(void) {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"lock_reset %@",errorMsg);
  }];
}

- (void)lock_control:(CDVInvokedUrlCommand *)command {
  TTControlAction action = (TTControlAction)[(NSNumber *)[command argumentAtIndex:0] integerValue];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  NSLog(@"lock_control %@",action);

  [TTLock controlLockWithControlAction:action lockData:lockData success:^(long long lockTime, NSInteger electricQuantity, long long uniqueId) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithLongLong:lockTime], @"lockTime",
      [NSNumber numberWithInteger:electricQuantity], @"electricQuantity",
      [NSNumber numberWithLongLong:uniqueId], @"uniqueId",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"lock_control %@",errorMsg);
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
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_setTime:(CDVInvokedUrlCommand *)command {
  long long timestamp = (long long)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock setLockTimeWithTimestamp:timestamp lockData:lockData
    success:^(void) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_addFingerprint:(CDVInvokedUrlCommand *)command {
  long long startDate = (long long)[command argumentAtIndex:0];
  long long endDate = (long long)[command argumentAtIndex:1];
  NSString *lockData = (NSString *)[command argumentAtIndex:2];
  __block NSInteger currentCount = 0;
  __block NSInteger totalCount = 0;

  [TTLock addFingerprintStartDate:startDate endDate:endDate lockData:lockData
    progress:^(TTAddFingerprintState state, NSInteger remanentPressTimes) {
      NSString *status = @"unknown";
      NSDictionary *resultDict;

      switch (state) {
        case TTAddFingerprintCollectSuccess:
          
          break;
        case TTAddFingerprintCanCollect:
          status = @"can_collect";
          totalCount = remanentPressTimes;
          resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
            @"add", @"status",
            [NSNumber numberWithInteger:totalCount], @"totalCount",
          nil];
          
          break;
        case TTAddFingerprintCanCollectAgain:
          currentCount = totalCount - remanentPressTimes;
          resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
            @"collected", @"status",
            [NSNumber numberWithInteger:currentCount], @"currentCount",
          nil];
          break;
      }
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [pluginResult setKeepCallbackAsBool:true];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

      NSLog(@"lock_addFingerprint progress");
    }
    success:^(NSString *fingerprintNumber) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"finished", @"status",
        fingerprintNumber, @"fingerprintNumber",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

      NSLog(@"lock_addFingerprint success");
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"error", @"status",
        [NSNumber numberWithInteger:errorCode], @"error",
        errorMsg, @"message",
      nil];
      // NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

      NSLog(@"lock_addFingerprint failure %@",errorMsg);
    }
  ];
}

- (void)lock_deleteFingerprint:(CDVInvokedUrlCommand *)command {
  NSString *fingerprintNumber = (NSString *)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock deleteFingerprintNumber:fingerprintNumber lockData:lockData
    success:^(void) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_getAllValidFingerprints:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock getAllValidFingerprintsWithLockData:lockData
    success:^(NSString *allFingerprintsJsonString) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:allFingerprintsJsonString];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_clearAllFingerprints:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock clearAllFingerprintsWithLockData:lockData
    success:^() {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_modifyFingerprintValidityPeriod:(CDVInvokedUrlCommand *)command {
  long long startDate = (long long)[command argumentAtIndex:0];
  long long endDate = (long long)[command argumentAtIndex:1];
  NSString *fingerprintNumber = (NSString *)[command argumentAtIndex:2];
  NSString *lockData = (NSString *)[command argumentAtIndex:3];

  [TTLock modifyFingerprintValidityPeriodWithFingerprintNumber:fingerprintNumber startDate:startDate endDate:endDate lockData:lockData
    success:^() {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

// Helpers

+ (NSDictionary *)makeError:(TTError) errorCode errorMessage:(NSString *)errorMessage {
  NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithInteger:errorCode], @"error",
    errorMessage, @"message",
  nil];
  return resultDict;
}

+ (NSNumber *)hasFeature:(long long)specialValue feature:(TTLockSpecialFunction)feature {
  return [NSNumber numberWithBool:[TTUtil lockSpecialValue:specialValue suportFunction:TTLockSpecialFunctionICCard]];
}

+ (NSDictionary *)getLockFeatures:(long long)specialValue {
  NSDictionary *features = [NSDictionary dictionaryWithObjectsAndKeys:
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionPasscode], @"passcode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionICCard], @"icCard",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionFingerprint], @"fingerprint",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionWristband], @"autolock",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionAutoLock], @"deletePasscode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionDeletePasscode], @"deletePasscode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionManagePasscode], @"managePasscode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionLocking], @"locking",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionPasscodeVisible], @"passcodeVisible",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionGatewayUnlock], @"gatewayUnlock",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionLockFreeze], @"lockFreeze",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionCyclePassword], @"cyclicPassword",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionDoorSensor], @"doorSensor",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionRemoteUnlockSwicth], @"remoteUnlockSwitch",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionAudioSwitch], @"audioSwitch",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionNBIoT], @"nbIoT",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionGetAdminPasscode], @"getAdminPasscode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionHotelCard], @"hotelCard",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionNoClock], @"noClock",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionNoBroadcastInNormal], @"noBroadcastInNormal",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionPassageMode], @"passageMode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionTurnOffAutoLock], @"turnOffAutolock",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionWirelessKeypad], @"wirelessKeypad",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionLight], @"light",
  nil];
  return features;
}

@end
