/*
 * Copyright (C) 2018 The Android Open Source Project
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

#define ATRACE_TAG (ATRACE_TAG_POWER | ATRACE_TAG_HAL)
#define LOG_TAG "android.hardware.power@1.3-service.grus"

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android-base/strings.h>
#include <android-base/stringprintf.h>

#include <mutex>

#include <utils/Log.h>

#include "Power.h"
#include "power-helper.h"

#include <linux/input.h>
#include <hardware/power.h>

/* RPM runs at 19.2Mhz. Divide by 19200 for msec */
#define RPM_CLK 19200

#define TAP_TO_WAKE_NODE "/dev/input/event2"
#define INPUT_EVENT_WAKUP_MODE_OFF 4
#define INPUT_EVENT_WAKUP_MODE_ON 5

extern struct stats_section master_sections[];

namespace android {
namespace hardware {
namespace power {
namespace V1_3 {
namespace implementation {

using ::android::hardware::power::V1_0::Feature;
using ::android::hardware::power::V1_0::PowerStatePlatformSleepState;
using ::android::hardware::power::V1_0::Status;
using ::android::hardware::power::V1_1::PowerStateSubsystem;
using ::android::hardware::power::V1_1::PowerStateSubsystemSleepState;
using ::android::hardware::hidl_vec;
using ::android::hardware::Return;
using ::android::hardware::Void;

Power::Power()
    : mHintManager(nullptr),
      mInteractionHandler(nullptr),
      mSustainedPerfModeOn(false),
      mReady(false) {
    mInitThread =
            std::thread([this](){
                            android::base::WaitForProperty(kPowerHalInitProp, "1");
                            mHintManager = HintManager::GetFromJSON("/vendor/etc/powerhint.json");
                            mInteractionHandler = std::make_unique<InteractionHandler>(mHintManager);
                            mInteractionHandler->Init();
                            // Now start to take powerhint
                            mReady.store(true);
                        });
    mInitThread.detach();
}

// Methods from ::android::hardware::power::V1_0::IPower follow.
Return<void> Power::setInteractive(bool /* interactive */)  {
    return Void();
}

Return<void> Power::powerHint(PowerHint_1_0 hint, int32_t data) {
    if (!isSupportedGovernor() || !mReady) {
        return Void();
    }

    switch(hint) {
        case PowerHint_1_0::INTERACTION:
            if (!mSustainedPerfModeOn) {
                mInteractionHandler->Acquire(data);
            }
            break;
        case PowerHint_1_0::SUSTAINED_PERFORMANCE:
            if (data && !mSustainedPerfModeOn) {
                mHintManager->DoHint("SUSTAINED_PERFORMANCE");
                android::base::SetProperty(kPowerHalStateProp, "SUSTAINED_PERFORMANCE");
                mSustainedPerfModeOn = true;
            } else if (!data && mSustainedPerfModeOn) {
                mHintManager->EndHint("SUSTAINED_PERFORMANCE");
                android::base::SetProperty(kPowerHalStateProp, "");
                mSustainedPerfModeOn = false;
            }
            break;
        case PowerHint_1_0::LAUNCH:
            if (!mSustainedPerfModeOn) {
                if (data) {
                    // Hint until canceled
                    mHintManager->DoHint("LAUNCH");
                } else {
                    mHintManager->EndHint("LAUNCH");
                }
            }
            break;
        default:
            break;

    }
    return Void();
}

Return<void> Power::setFeature(Feature feature, bool activate)  {
    feature_t feat = static_cast<feature_t>(feature);
    switch (feat) {
#ifdef TAP_TO_WAKE_NODE
        case POWER_FEATURE_DOUBLE_TAP_TO_WAKE: {
            int fd = open(TAP_TO_WAKE_NODE, O_RDWR);
            struct input_event ev; 
            ev.type = EV_SYN;
            ev.code = SYN_CONFIG;
            ev.value = activate ? INPUT_EVENT_WAKUP_MODE_ON : INPUT_EVENT_WAKUP_MODE_OFF;
            write(fd, &ev, sizeof(ev));
            close(fd);
        } break;
#endif
        default:
            break;
	}
    return Void();
}

Return<void> Power::getPlatformLowPowerStats(getPlatformLowPowerStats_cb _hidl_cb) {

    hidl_vec<PowerStatePlatformSleepState> states;
    uint64_t stats[SYSTEM_SLEEP_STATE_COUNT * SYSTEM_STATE_STATS_COUNT] = {0};
    uint64_t *state_stats;
    struct PowerStatePlatformSleepState *state;

    states.resize(SYSTEM_SLEEP_STATE_COUNT);

    if (extract_system_stats(stats, ARRAY_SIZE(stats)) != 0) {
        states.resize(0);
        goto done;
    }

    /* Update statistics for AOSD */
    state = &states[SYSTEM_STATE_AOSD];
    state->name = "AOSD";
    state_stats = &stats[SYSTEM_STATE_AOSD * SYSTEM_STATE_STATS_COUNT];

    state->residencyInMsecSinceBoot = state_stats[ACCUMULATED_TIME_MS];
    state->totalTransitions = state_stats[TOTAL_COUNT];
    state->supportedOnlyInSuspend = false;
    state->voters.resize(0);

    /* Update statistics for CXSD */
    state = &states[SYSTEM_STATE_CXSD];
    state->name = "CXSD";
    state_stats = &stats[SYSTEM_STATE_CXSD * SYSTEM_STATE_STATS_COUNT];

    state->residencyInMsecSinceBoot = state_stats[ACCUMULATED_TIME_MS];
    state->totalTransitions = state_stats[TOTAL_COUNT];
    state->supportedOnlyInSuspend = false;
    state->voters.resize(0);

done:
    _hidl_cb(states, Status::SUCCESS);
    return Void();
}

static int get_master_low_power_stats(hidl_vec<PowerStateSubsystem> *subsystems) {
    uint64_t all_stats[MASTER_COUNT * MASTER_STATS_COUNT] = {0};
    uint64_t *section_stats;
    struct PowerStateSubsystem *subsystem;
    struct PowerStateSubsystemSleepState *state;

    if (extract_master_stats(all_stats, ARRAY_SIZE(all_stats)) != 0) {
        for (size_t i = 0; i < MASTER_COUNT; i++) {
            (*subsystems)[i].name = master_sections[i].label;
            (*subsystems)[i].states.resize(0);
        }
        return -1;
    }

    for (size_t i = 0; i < MASTER_COUNT; i++) {
        subsystem = &(*subsystems)[i];
        subsystem->name = master_sections[i].label;
        subsystem->states.resize(MASTER_SLEEP_STATE_COUNT);

        state = &(subsystem->states[MASTER_SLEEP]);
        section_stats = &all_stats[i * MASTER_STATS_COUNT];

        state->name = "Sleep";
        state->totalTransitions = section_stats[SLEEP_ENTER_COUNT];
        state->residencyInMsecSinceBoot = section_stats[SLEEP_CUMULATIVE_DURATION_MS] / RPM_CLK;
        state->lastEntryTimestampMs = section_stats[SLEEP_LAST_ENTER_TSTAMP_MS] / RPM_CLK;
        state->supportedOnlyInSuspend = false;
    }

    return 0;
}

// Methods from ::android::hardware::power::V1_1::IPower follow.
Return<void> Power::getSubsystemLowPowerStats(getSubsystemLowPowerStats_cb _hidl_cb) {
    hidl_vec<PowerStateSubsystem> subsystems;

    subsystems.resize(STATS_SOURCE_COUNT);

    // Get low power stats for all of the system masters.
    if (get_master_low_power_stats(&subsystems) != 0) {
        ALOGE("%s: failed to process master stats", __func__);
    }

    _hidl_cb(subsystems, Status::SUCCESS);
    return Void();
}

bool Power::isSupportedGovernor() {
    std::string buf;
    if (android::base::ReadFileToString("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor", &buf)) {
        buf = android::base::Trim(buf);
    }
    // Only support EAS 1.2, legacy EAS
    if (buf == "schedutil" || buf == "sched" || buf == "blu_schedutil") {
        return true;
    } else {
        LOG(ERROR) << "Governor not supported by powerHAL, skipping";
        return false;
    }
}

Return<void> Power::powerHintAsync(PowerHint_1_0 hint, int32_t data) {
    // just call the normal power hint in this oneway function
    return powerHint(hint, data);
}

// Methods from ::android::hardware::power::V1_2::IPower follow.
Return<void> Power::powerHintAsync_1_2(PowerHint_1_2 hint, int32_t data) {
    if (!isSupportedGovernor() || !mReady) {
        return Void();
    }

    switch(hint) {
        case PowerHint_1_2::AUDIO_LOW_LATENCY:
            if (data) {
                // Hint until canceled
                mHintManager->DoHint("AUDIO_LOW_LATENCY");
                android::base::SetProperty(kPowerHalAudioProp, "LOW_LATENCY");
            } else {
                mHintManager->EndHint("AUDIO_LOW_LATENCY");
                android::base::SetProperty(kPowerHalAudioProp, "");
            }
            break;
        case PowerHint_1_2::AUDIO_STREAMING:
            if (!mSustainedPerfModeOn) {
                if (data) {
                    // Hint until canceled
                    mHintManager->DoHint("AUDIO_STREAMING");
                } else {
                    mHintManager->EndHint("AUDIO_STREAMING");
                }
            }
            break;
        default:
            return powerHint(static_cast<PowerHint_1_0>(hint), data);
    }
    return Void();
}

// Methods from ::android::hardware::power::V1_3::IPower follow.
Return<void> Power::powerHintAsync_1_3(PowerHint_1_3 hint, int32_t data) {
    if (!isSupportedGovernor() || !mReady) {
        return Void();
    }

    if (hint == PowerHint_1_3::EXPENSIVE_RENDERING) {
        if (mSustainedPerfModeOn) {
            return Void();
        }

        if (data > 0) {
            mHintManager->DoHint("EXPENSIVE_RENDERING");
            android::base::SetProperty(kPowerHalRenderingProp, "EXPENSIVE_RENDERING");
        } else {
            mHintManager->EndHint("EXPENSIVE_RENDERING");
            android::base::SetProperty(kPowerHalRenderingProp, "");
        }
    } else {
        return powerHintAsync_1_2(static_cast<PowerHint_1_2>(hint), data);
    }

    return Void();
}

}  // namespace implementation
}  // namespace V1_3
}  // namespace power
}  // namespace hardware
}  // namespace android
