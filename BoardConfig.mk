#
# Copyright (C) 2019 The PixelExperience Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Inherit from sdm710-common
-include device/xiaomi/sdm710-common/BoardConfigCommon.mk

DEVICE_PATH := device/xiaomi/grus

# Assert
TARGET_OTA_ASSERT_DEVICE := grus

# Kernel
TARGET_KERNEL_CONFIG := grus_defconfig

# Partitions
BOARD_BUILD_SYSTEM_ROOT_IMAGE := true

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom

# NFC
TARGET_USES_NQ_NFC := true

# Inherit from the proprietary version
-include vendor/xiaomi/grus/BoardConfigVendor.mk

# Sepolicy
BOARD_PLAT_PRIVATE_SEPOLICY_DIR += $(DEVICE_PATH)/sepolicy/private
