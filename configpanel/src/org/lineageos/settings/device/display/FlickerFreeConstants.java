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

public class FlickerFreeConstants {

        // Preference keys
        protected static final String FLICKER_FREE_KEY = "flicker_free";
        protected static final String FLICKER_FREE_EXP_KEY = "flicker_free_exp";
        protected static final String FLICKER_FREE_BRI_KEY = "flicker_free_bri";

        // Flicker-free nodes
        protected static final String FLICKER_FREE_NODE =
                "/sys/devices/platform/soc/soc:qcom,dsi-display@18/msm_fb_ea_enable";

        protected static final String FLICKER_FREE_EXP_NODE =
                "/sys/devices/platform/soc/soc:qcom,dsi-display@18/msm_fb_ea_min";

        protected static final String FLICKER_FREE_BRI_NODE =
                "/sys/devices/platform/soc/soc:qcom,dsi-display@18/msm_fb_ea_elvss_off_treshold";
}
