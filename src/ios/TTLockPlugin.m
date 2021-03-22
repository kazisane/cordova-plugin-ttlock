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

  [TTLock initLockWithDict:arguments success:^(NSString *lockData) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      lockData, @"lockData",
      [NSNumber numberWithLongLong:0], @"specialValue",
      [TTLockPlugin getLockFeaturesWithLockData:lockData], @"features",
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
  TTControlAction action = (TTControlAction)[[command.arguments objectAtIndex:0] integerValue];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  NSLog(@"lock_control action %d",action);

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

- (void)lock_getOperationLog:(CDVInvokedUrlCommand *)command {
  TTOperateLogType logType = (TTOperateLogType)[NSNumber numberWithInteger:[command argumentAtIndex:0]];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock getOperationLogWithType:logType lockData:lockData
    success:^(NSString *logs) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        logs, @"logs",
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

- (void)lock_addFingerprint:(CDVInvokedUrlCommand *)command {
  long long startDate = (long long)[[command.arguments objectAtIndex:0] longValue];
  long long endDate = (long long)[[command.arguments objectAtIndex:1] longValue];
  NSString *lockData = (NSString *)[command argumentAtIndex:2];

  [TTLock addFingerprintStartDate:startDate endDate:endDate lockData:lockData
    progress:^(int currentCount, int totalCount) {
      NSString *status = @"unknown";
      NSDictionary *resultDict;

      if (currentCount == 0) {
        status = @"add";
      } else if (currentCount > 0) {
        status = @"collected";
      }

      resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        status, @"status",
        [NSNumber numberWithInteger:currentCount], @"currentCount",
        [NSNumber numberWithInteger:totalCount], @"totalCount",
      nil];

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

- (void)lock_createCustomPasscode:(CDVInvokedUrlCommand *)command {
  NSString *customPasscode = (NSString *)[command argumentAtIndex:0];
  long long startDate = (long long)[command argumentAtIndex:1];
  long long endDate = (long long)[command argumentAtIndex:2];
  NSString *lockData = (NSString *)[command argumentAtIndex:3];

  [TTLock createCustomPasscode:customPasscode startDate:startDate endDate:endDate lockData:lockData
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

- (void)lock_modifyPasscode:(CDVInvokedUrlCommand *)command {
  NSString *oldPasscode = (NSString *)[command argumentAtIndex:0];
  NSString *newPasscode = (NSString *)[command argumentAtIndex:1];
  long long startDate = (long long)[command argumentAtIndex:2];
  long long endDate = (long long)[command argumentAtIndex:3];
  NSString *lockData = (NSString *)[command argumentAtIndex:4];

  [TTLock modifyPasscode:oldPasscode newPasscode:newPasscode startDate:startDate endDate:endDate lockData:lockData
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

- (void)lock_deletePasscode:(CDVInvokedUrlCommand *)command {
  NSString *passcode = (NSString *)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock deletePasscode:passcode lockData:lockData
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

- (void)lock_resetPasscode:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock resetPasscodesWithLockData:lockData
    success:^(NSString *lockData) {
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





- (void)lock_addICCard:(CDVInvokedUrlCommand *)command {
  long long startDate = (long long)[command argumentAtIndex:0];
  long long endDate = (long long)[command argumentAtIndex:1];
  NSString *lockData = (NSString *)[command argumentAtIndex:2];

  [TTLock addICCardStartDate:startDate endDate:endDate lockData:lockData
    progress:^(TTAddICState state) {

    }
    success:^(NSString *cardNumber) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"finished", @"status",
        cardNumber, @"cardNumber",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

      NSLog(@"lock_addICCard success");
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_modifyICCardValidityPeriod:(CDVInvokedUrlCommand *)command {
  long long startDate = (long long)[command argumentAtIndex:0];
  long long endDate = (long long)[command argumentAtIndex:1];
  NSString *cardNumber = (NSString *)[command argumentAtIndex:2];
  NSString *lockData = (NSString *)[command argumentAtIndex:3];

  [TTLock modifyICCardValidityPeriodWithCardNumber:cardNumber startDate:startDate endDate:endDate lockData:lockData
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

- (void)lock_deleteICCard:(CDVInvokedUrlCommand *)command {
  NSString *cardNumber = (NSString *)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock deleteICCardNumber:cardNumber lockData:lockData
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
  return [NSNumber numberWithBool:[TTUtil lockSpecialValue:specialValue suportFunction:feature]];
}

+ (NSNumber *)hasFeatureValue:(NSString *)lockData feature:(TTLockFeatureValue)feature {
  return [NSNumber numberWithBool:[TTUtil lockFeatureValue:lockData suportFunction:feature]];
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

+ (NSDictionary *)getLockFeaturesWithLockData:(NSString *)lockData {
  NSDictionary *features = [NSDictionary dictionaryWithObjectsAndKeys:
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValuePasscode], @"passcode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueICCard], @"icCard",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueFingerprint], @"fingerprint",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueWristband], @"autolock",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueAutoLock], @"deletePasscode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueDeletePasscode], @"deletePasscode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueManagePasscode], @"managePasscode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueLocking], @"locking",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValuePasscodeVisible], @"passcodeVisible",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueGatewayUnlock], @"gatewayUnlock",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueLockFreeze], @"lockFreeze",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueCyclePassword], @"cyclicPassword",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueDoorSensor], @"doorSensor",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueRemoteUnlockSwicth], @"remoteUnlockSwitch",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueAudioSwitch], @"audioSwitch",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueNBIoT], @"nbIoT",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueGetAdminPasscode], @"getAdminPasscode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueHotelCard], @"hotelCard",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueNoClock], @"noClock",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueNoBroadcastInNormal], @"noBroadcastInNormal",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValuePassageMode], @"passageMode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueTurnOffAutoLock], @"turnOffAutolock",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueWirelessKeypad], @"wirelessKeypad",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueLight], @"light",
  nil];
  return features;
}

@end
