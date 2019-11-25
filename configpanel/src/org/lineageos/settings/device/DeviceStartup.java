/*
 * Copyright (C) 2019 The MoKee Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings.device;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import org.lineageos.settings.device.display.FlickerFreeSettingsActivity;
import org.lineageos.settings.device.display.Utils;

public class DeviceStartup extends BroadcastReceiver {

    private static final String TAG = "Kowalski OS";

    @Override
    public void onReceive(final Context context, final Intent intent) {
        Log.i(TAG, "Restoring Settings");
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            if (FlickerFreeSettingsActivity.restoreState(context))
                Utils.restoreNodePrefs(context);
        }
    }

}
