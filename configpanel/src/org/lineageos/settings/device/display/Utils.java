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

package org.lineageos.settings.device.display;

import android.content.ComponentName;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.preference.PreferenceManager;
import android.util.Log;

import org.lineageos.settings.device.utils.FileUtils;

public class Utils {

    private static final String TAG = "Kowalski OS";

    protected static void disableComponent(Context context, Class cls) {
        ComponentName name = new ComponentName(context, cls);
        PackageManager pm = context.getPackageManager();
        pm.setComponentEnabledSetting(name,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP);
    }

    protected static void enableComponent(Context context, Class cls) {
        ComponentName name = new ComponentName(context, cls);
        PackageManager pm = context.getPackageManager();
        if (pm.getComponentEnabledSetting(name)
                == PackageManager.COMPONENT_ENABLED_STATE_DISABLED) {
            pm.setComponentEnabledSetting(name,
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                    PackageManager.DONT_KILL_APP);
        }
    }

    static boolean getPreferenceBool(SharedPreferences preferences, String key) {
        return preferences.getBoolean(key, (Boolean) Constants.sNodeDefaultMap.get(key));
    }

    static String getPreferenceInt(SharedPreferences preferences, String key) {
        return String.valueOf(preferences.getInt(key, (Integer)Constants.sNodeDefaultMap.get(key)));
    }

    public static void restoreNodePrefs(Context context) {
        String value, node;
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        for (String pref : Constants.sFlickerFreePrefKeys) {
            if (Constants.sBooleanNodePreferenceMap.containsKey(pref)) {
                value = getPreferenceBool(preferences, pref) ? "1" : "0";
                node = Constants.sBooleanNodePreferenceMap.get(pref);
            } else if (Constants.sIntNodePreferenceMap.containsKey(pref)) {
                value = getPreferenceInt(preferences, pref);
                node = Constants.sIntNodePreferenceMap.get(pref);
            } else {
                continue;
            }

            if (!FileUtils.writeLine(node, value)) {
                Log.e(TAG, "Write to node " + node +
                    " failed while restoring saved preference value -> " + pref + ": " + value);
            } else {
                Log.i(TAG, "Write to node " + node +
                    " succedeed while restoring saved preference value -> " + pref + ": " + value);
            }
        }
    }

}
