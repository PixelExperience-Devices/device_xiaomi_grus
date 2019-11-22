LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := android.hardware.vibrator@1.1-service.grus
LOCAL_INIT_RC := android.hardware.vibrator@1.1-service.grus.rc
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_RELATIVE_PATH := hw

LOCAL_SRC_FILES := \
    Vibrator.cpp \
    service.cpp

LOCAL_SHARED_LIBRARIES := \
    libhidlbase \
    libhidltransport \
    liblog \
    libhwbinder \
    libutils \
    libhardware \
    android.hardware.vibrator@1.0 \
    android.hardware.vibrator@1.1

include $(BUILD_EXECUTABLE)
