// (c) 2014-2016 Don Coleman
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.apartx.ttlock;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Build;

import android.provider.Settings;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

// import android.support.v4.content.ContextCompat;
import com.google.gson.Gson;

import java.util.*;
import java.lang.*;

import com.ttlock.bl.sdk.api.TTLockClient;
import com.ttlock.bl.sdk.entity.LockError;
import com.ttlock.bl.sdk.callback.ScanLockCallback;
import com.ttlock.bl.sdk.callback.InitLockCallback;
import com.ttlock.bl.sdk.callback.ControlLockCallback;
import com.ttlock.bl.sdk.callback.GetLockTimeCallback;
import com.ttlock.bl.sdk.callback.SetRemoteUnlockSwitchCallback;
import com.ttlock.bl.sdk.callback.GetRemoteUnlockStateCallback;
import com.ttlock.bl.sdk.api.ExtendedBluetoothDevice;
import com.ttlock.bl.sdk.constant.ControlAction;

import com.ttlock.bl.sdk.gateway.api.GatewayClient;
import com.ttlock.bl.sdk.gateway.callback.InitGatewayCallback;
import com.ttlock.bl.sdk.gateway.callback.ScanWiFiByGatewayCallback;
import com.ttlock.bl.sdk.gateway.model.ConfigureGatewayInfo;
import com.ttlock.bl.sdk.gateway.model.DeviceInfo;
import com.ttlock.bl.sdk.gateway.model.GatewayError;
import com.ttlock.bl.sdk.gateway.model.WiFi;

public class TTLockPlugin extends CordovaPlugin {
	private TTLockClient ttlockClient = TTLockClient.getDefault();
  private GatewayClient gatewayClient = GatewayClient.getDefault();

	// callbacks
	CallbackContext discoverCallback;
	private CallbackContext enableBluetoothCallback;

	private static final String TAG = "TTLockPlugin";

	// Android 23 requires new permissions for BluetoothLeScanner.startScan()
	private CallbackContext permissionCallback;

	private Boolean mIsScanning = false;

	private Map<String, ExtendedBluetoothDevice> mDevicesCache = new HashMap<String, ExtendedBluetoothDevice>();

	public void onDestroy() {

	}

	public void onReset() {

	}

	@Override
	public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
		LOG.d(TAG, "action = %s", action);

		boolean validAction = true;
    java.lang.reflect.Method method;

    try {
      // method = this.getClass().getMethod(action);
      method = TTLockPlugin.class.getMethod(action, CordovaArgs.class, CallbackContext.class);
    } catch (java.lang.SecurityException e) {
      LOG.d(TAG, "getMethod SecurityException = %s", e.toString());
      return false;

    } catch (java.lang.NoSuchMethodException e) {
      LOG.d(TAG, "getMethod NoSuchMethodException = %s", e.toString());
      return false;
    }

    try {
      method.invoke(this, args, callbackContext);
    } catch (java.lang.IllegalArgumentException e) {
      callbackContext.error(e.toString());
    } catch (java.lang.IllegalAccessException e) {
      callbackContext.error(e.toString());
    } catch (java.lang.reflect.InvocationTargetException e) {
      callbackContext.error(e.toString());
    }
    return true;
	}

  public void lock_isBLEEnabled(CordovaArgs args, CallbackContext callbackContext) {
    ttlockClient.isBLEEnabled(cordova.getActivity().getApplicationContext());
		callbackContext.success();
  }

  public void lock_requestBleEnable(CordovaArgs args, CallbackContext callbackContext) {
    ttlockClient.requestBleEnable(cordova.getActivity());
		callbackContext.success();
  }

  public void lock_prepareBTService(CordovaArgs args, CallbackContext callbackContext) {
    ttlockClient.prepareBTService(cordova.getActivity().getApplicationContext());
		callbackContext.success();
  }

  public void lock_stopBTService(CordovaArgs args, CallbackContext callbackContext) {
    ttlockClient.stopBTService();
		callbackContext.success();
  }

  public void lock_startScan(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    if (this.mIsScanning) {
      callbackContext.error("Already scanning");
      return;
    }

    ttlockClient.startScan(new ScanLockCallback() {
      @Override
      public void onScanLockSuccess(ExtendedBluetoothDevice device) {
        LOG.d(TAG, "ScanLockCallback device found = %s", device.getName());

        // Save device in cache
        mDevicesCache.put(device.getAddress(), device);

        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("address", device.getAddress());
          deviceObj.put("name", device.getName());
        } catch (Exception e) {
          LOG.d(TAG, "startScanLock error = %s", e.toString());
        }
        Gson gson = new Gson();
        String json = gson.toJson(device);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, json);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
      }
      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "ScanLockCallback device found error = %s", error.getErrorMsg());
        callbackContext.error(error.getErrorMsg());
      }
    });
  }

  public void lock_stopScan(CordovaArgs args, CallbackContext callbackContext) {
    ttlockClient.stopScanLock();
    callbackContext.success();
  }

  public void lock_init(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    Gson gson = new Gson();
    ExtendedBluetoothDevice device = gson.fromJson(args.getString(0), ExtendedBluetoothDevice.class);
    ExtendedBluetoothDevice _device = mDevicesCache.get(device.getAddress());
    LOG.d(TAG, "initLock = %s", _device.toString());
    ttlockClient.initLock(_device, new InitLockCallback() {
      @Override
      public void onInitLockSuccess(String lockData,int specialValue) {
        //init success
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("lockData", lockData);
          deviceObj.put("specialValue", specialValue);
        } catch (Exception e) {
          LOG.d(TAG, "initLock error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        //failed
        LOG.d(TAG, "initLock onFail = %s", error.getErrorMsg());
        callbackContext.error(error.getErrorMsg());
      }
    });
  }

  public void lock_control(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    int controlAction = args.getInt(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    ttlockClient.controlLock(controlAction, lockData, lockMac, new ControlLockCallback() {
      @Override
      public void onControlLockSuccess(int lockAction, int battery, int uniqueId) {
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("lockAction", lockAction);
          deviceObj.put("battery", battery);
          deviceObj.put("uniqueId", uniqueId);
        } catch (Exception e) {
          LOG.d(TAG, "controlLock error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "controlLock onFail = %s", error.getErrorMsg());
        callbackContext.error(error.getErrorMsg());
      }
    });
  }

  public void lock_getTime(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    ttlockClient.getLockTime(lockData, lockMac, new GetLockTimeCallback() {
      @Override
      public void onGetLockTimeSuccess(long lockTimestamp) {
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("lockTimestamp", lockTimestamp);
        } catch (Exception e) {
          LOG.d(TAG, "getLockTime error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "getLockTime onFail = %s", error.getErrorMsg());
        callbackContext.error(error.getErrorMsg());
      }
    });
  }

  public void lock_setRemoteUnlockSwitchState(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    Boolean enabled = args.getBoolean(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    ttlockClient.setRemoteUnlockSwitchState(enabled, lockData, lockMac, new SetRemoteUnlockSwitchCallback() {
      @Override
      public void onSetRemoteUnlockSwitchSuccess(int specialValue) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("specialValue", specialValue);
        } catch (Exception e) {
          LOG.d(TAG, "setRemoteUnlockSwitchState error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "setRemoteUnlockSwitchState onFail = %s", error.getErrorMsg());
        callbackContext.error(error.getErrorMsg());
      }
    });
  }

  public void lock_getRemoteUnlockSwitchState(CordovaArgs args, CallbackContext callbackContext) {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    ttlockClient.getRemoteUnlockSwitchState(enabled, lockData, lockMac, new GetRemoteUnlockSwitchCallback() {
      @Override
      public void onGetRemoteUnlockSwitchSuccess(boolean enabled) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("enabled", enabled);
        } catch (Exception e) {
          LOG.d(TAG, "getRemoteUnlockSwitchState error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "getRemoteUnlockSwitchState onFail = %s", error.getErrorMsg());
        callbackContext.error(error.getErrorMsg());
      }
    });
  }

  /*
  * Gateway API section
  */

  public void gateway_isBLEEnabled(CordovaArgs args, CallbackContext callbackContext) {
    gatewayClient.isBLEEnabled(cordova.getActivity().getApplicationContext());
		callbackContext.success();
  }

  public void gateway_requestBleEnable(CordovaArgs args, CallbackContext callbackContext) {
    gatewayClient.requestBleEnable(cordova.getActivity());
		callbackContext.success();
  }

  public void gateway_prepareBTService(CordovaArgs args, CallbackContext callbackContext) {
    gatewayClient.prepareBTService(cordova.getActivity().getApplicationContext());
		callbackContext.success();
  }

  public void gateway_stopBTService(CordovaArgs args, CallbackContext callbackContext) {
    gatewayClient.stopBTService();
		callbackContext.success();
  }

  public void gateway_startScan(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    if (this.mIsScanning) {
      callbackContext.error("Already scanning");
      return;
    }

    gatewayClient.startScanGateway(new ScanGatewayCallback() {
      @Override
      public void onScanGatewaySuccess(ExtendedBluetoothDevice device) {
        LOG.d(TAG, "ScanGatewayCallback device found = %s", device.getName());

        // Save device in cache
        mDevicesCache.put(device.getAddress(), device);

        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("address", device.getAddress());
          deviceObj.put("name", device.getName());
        } catch (Exception e) {
          LOG.d(TAG, "startScanGateway error = %s", e.toString());
        }
        Gson gson = new Gson();
        String json = gson.toJson(device);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, json);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
      }
      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "ScanGatewayCallback device found error = %s", error.getErrorMsg());
        callbackContext.error(error.getErrorMsg());
      }
    });
  }

  public void gateway_stopScan(CordovaArgs args, CallbackContext callbackContext) {
    gatewayClient.stopScanGateway();
    callbackContext.success();
  }

  public void gateway_connect(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String gatewayMac = args.getString(0);
    // LOG.d(TAG, "connectGateway = %s", _device.toString());
    gatewayClient.connectGateway(gatewayMac, new ConnectCallback() {
      @Override
      public void onConnectSuccess(ExtendedBluetoothDevice device) {
        //init success
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("status", "connected");
        } catch (Exception e) {
          LOG.d(TAG, "connectGateway error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onDisconnected() {
        //failed
        LOG.d(TAG, "connectGateway onDisconnected");
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("status", "disconnected");
        } catch (Exception e) {
          LOG.d(TAG, "connectGateway error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }
    });
  }

  public void gateway_init(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    ConfigureGatewayInfo configureGatewayInfo;
    configureGatewayInfo.plugName = args.getString(0);
    configureGatewayInfo.uid = args.getString(1);
    configureGatewayInfo.userPwd = args.getString(2);
    configureGatewayInfo.ssid = args.getString(3);
    configureGatewayInfo.wifiPwd = args.getString(4);
    
    LOG.d(TAG, "initGateway = %s", configureGatewayInfo.plugName);
    ttlockClient.initGateway(configureGatewayInfo, new InitGatewayCallback() {
      @Override
      public void onInitGatewaySuccess(DeviceInfo deviceInfo) {
        //init success
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("modelNum", deviceInfo.getModelNum());
          deviceObj.put("hardwareRevision", deviceInfo.getHardwareRevision());
          deviceObj.put("firmwareRevision", deviceInfo.getFirmwareRevision());
        } catch (Exception e) {
          LOG.d(TAG, "initGateway error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        //failed
        LOG.d(TAG, "initGateway onFail = %s", error.getErrorMsg());
        callbackContext.error(error.getErrorMsg());
      }
    });
  }

  public void gateway_scanWiFi(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String gatewayMac = args.getString(0);
    
    LOG.d(TAG, "scanWiFiByGateway = %s", configureGatewayInfo.plugName);
    ttlockClient.scanWiFiByGateway(gatewayMac, new ScanWiFiByGatewayCallback() {
      @Override
      public void onScanWiFiByGateway(List<WiFi> wifis) {
        JSONArray resultAr = new JSONArray();
        for (WiFi wifi : wifis) {
          JSONObject resultObj = new JSONObject();
          try {
            resultObj.put("ssid", wifi.getSsid());
            resultObj.put("rssi", wifi.getRssi());
            resultAr.put(resultObj);
          } catch (Exception e) {
            LOG.d(TAG, "scanWiFiByGateway error = %s", e.toString());
          }
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultAr);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onScanWiFiByGatewaySuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(GatewayError error) {
        LOG.d(TAG, "scanWiFiByGateway onFail = %s", error.getErrorMsg());
        callbackContext.error(error.getErrorMsg());
      }
    });
  }
}
