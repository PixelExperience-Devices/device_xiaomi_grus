/*
 * Copyright (C) 2019 The LineageOS Project
 * QPNP haptic additions by faust93
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

#define LOG_TAG "android.hardware.vibrator@1.1-service.xiaomi"

#include <android/hardware/vibrator/1.1/IVibrator.h>
#include <hidl/HidlSupport.h>
#include <hidl/HidlTransportSupport.h>
#include <utils/Errors.h>
#include <utils/StrongPointer.h>

#include "Vibrator.h"

using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;
using android::hardware::vibrator::V1_1::IVibrator;
using android::hardware::vibrator::V1_1::implementation::Vibrator;

const static std::string OVERRIDE_PATH = "/sys/class/leds/vibrator/vmax_override";
const static std::string ENABLE_PATH = "/sys/class/leds/vibrator/activate";
const static std::string DURATION_PATH = "/sys/class/leds/vibrator/duration";
const static std::string AMPLITUDE_PATH = "/sys/class/leds/vibrator/vmax_mv_user";
const static std::string AMPLITUDE_CALL_PATH = "/sys/class/leds/vibrator/vmax_mv_call";
const static std::string AMPLITUDE_NOTIF_PATH = "/sys/class/leds/vibrator/vmax_mv_strong";

android::status_t registerVibratorService() {

    std::ofstream override(OVERRIDE_PATH);
    if (!override) {
        int error = errno;
        ALOGE("Failed to open %s (%d): %s", OVERRIDE_PATH.c_str(), error, strerror(error));
        return -error;
    }
    override << 1 << std::endl;
    if (!override) {
        int error = errno;
        ALOGE("Failed to override vibrator settings (%d): %s", errno, strerror(errno));
        return -error;
    }
    override.close();

    std::ofstream enable(ENABLE_PATH);
    if (!enable) {
        int error = errno;
        ALOGE("Failed to open %s (%d): %s", ENABLE_PATH.c_str(), error, strerror(error));
        return -error;
    }

    std::ofstream duration(DURATION_PATH);
    if (!duration) {
        int error = errno;
        ALOGE("Failed to open %s (%d): %s", DURATION_PATH.c_str(), error, strerror(error));
        return -error;
    }

    std::ofstream amplitude(AMPLITUDE_PATH);
    if (!amplitude) {
        int error = errno;
        ALOGE("Failed to open %s (%d): %s", AMPLITUDE_PATH.c_str(), error, strerror(error));
        return -error;
    }

    std::ofstream amplitude_call(AMPLITUDE_CALL_PATH);
    if (!amplitude_call) {
        int error = errno;
        ALOGE("Failed to open %s (%d): %s", AMPLITUDE_CALL_PATH.c_str(), error, strerror(error));
        return -error;
    }

    std::ofstream amplitude_notif(AMPLITUDE_NOTIF_PATH);
    if (!amplitude_notif) {
        int error = errno;
        ALOGE("Failed to open %s (%d): %s", AMPLITUDE_NOTIF_PATH.c_str(), error, strerror(error));
        return -error;
    }

    android::sp<IVibrator> service = new Vibrator(std::move(enable), std::move(duration), std::move(amplitude), std::move(amplitude_call), std::move(amplitude_notif));
    if (!service) {
        ALOGE("Cannot allocate Vibrator HAL service");
        return 1;
    }

    android::status_t status = service->registerAsService();
    if (status != android::OK) {
        ALOGE("Cannot register Vibrator HAL service");
        return 1;
    }

    return android::OK;
}

int main() {
    configureRpcThreadpool(1, true);

    android::status_t status = registerVibratorService();
    if (status != android::OK) {
        return status;
    }

    joinRpcThreadpool();
}
