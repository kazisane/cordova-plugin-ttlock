// (c) 2014-2016 Don Coleman
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
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

import com.ttlock.bl.sdk.api.TTLockClient;
import com.ttlock.bl.sdk.entity.LockError;
import com.ttlock.bl.sdk.callback.ScanLockCallback;
import com.ttlock.bl.sdk.callback.InitLockCallback;
import com.ttlock.bl.sdk.api.ExtendedBluetoothDevice;

public class TTLockPlugin extends CordovaPlugin {
    // actions
    private static final String PREPARE_BT_SERVICE = "prepareBTService";
    private static final String STOP_BT_SERVICE = "stopBTService";
    private static final String START_SCAN_LOCK = "startScanLock";
    private static final String STOP_SCAN_LOCK = "stopScanLock";

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

        if (action.equals(PREPARE_BT_SERVICE)) {

            TTLockClient.getDefault().prepareBTService(cordova.getActivity().getApplicationContext());
            callbackContext.success();

        } else if (action.equals(STOP_BT_SERVICE)) {

          TTLockClient.getDefault().stopBTService();
          callbackContext.success();

        } else if (action.equals(START_SCAN_LOCK)) {

          if (this.mIsScanning) {
            callbackContext.error("Already scanning");
            return true;
          }

          TTLockClient.getDefault().startScanLock(new ScanLockCallback() {
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

        } else if (action.equals(STOP_SCAN_LOCK)) {

          TTLockClient.getDefault().stopScanLock();
          callbackContext.success();

        } else if (action.equals("isBLEEnabled")) {

          TTLockClient.getDefault().isBLEEnabled(cordova.getActivity().getApplicationContext());
          callbackContext.success();

        } else if (action.equals("requestBleEnable")) {

          TTLockClient.getDefault().requestBleEnable(cordova.getActivity());
          callbackContext.success();

        } else if (action.equals("initLock")) {

          Gson gson = new Gson();
          ExtendedBluetoothDevice device = gson.fromJson(args.getString(0), ExtendedBluetoothDevice.class);
          ExtendedBluetoothDevice _device = mDevicesCache.get(device.getAddress());
          TTLockClient.getDefault().initLock(_device, new InitLockCallback() {
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
              callbackContext.error(error.getErrorMsg());
            }
          });

        } else {
            validAction = false;
        }

        return validAction;
    }

}
