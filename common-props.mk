# Audio
PRODUCT_PROPERTY_OVERRIDES += \
    audio.deep_buffer.media=true \
    ro.af.client_heap_size_kbyte=7168 \
    ro.config.media_vol_steps=25 \
    ro.config.vc_call_vol_steps=7

# Bluetooth
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.bluetooth.soc=cherokee \
    vendor.qcom.bluetooth.soc=cherokee \

# Camera
PRODUCT_PROPERTY_OVERRIDES += \
    camera.disable_zsl_mode=true \
    persist.vendor.camera.HAL3.enabled=1 \
    persist.vendor.camera.eis.enable=1 \
    vendor.camera.aux.packagelist=com.google.android.GoogleCamera,org.codeaurora.snapcam,com.android.camera \
    vendor.camera.aux.packagelist.ext=,com.xiaomi.biometric,com.xiaomi.biometric.haldemo,com.xiaomi.factory.mmi

# CNE and DPM
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.cne.feature=0 \
    persist.vendor.dpm.feature=9 \
    persist.vendor.dpm.loglevel=0 \
    persist.vendor.dpm.nsrm.bkg.evt=3955

# Data modules
PRODUCT_PROPERTY_OVERRIDES += \
    persist.data.df.dev_name=rmnet_usb0 \
    persist.vendor.data.profile_update=true \
    persist.vendor.data.mode=concurrent \
    ro.vendor.use_data_netmgrd=true

# Display density
PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=480 \
    ro.display.type=oled \
    persist.debug.force_burn_in=true \
    persist.sys.sf.native_mode=0 \
    persist.sys.sf.color_saturation=1.0 \
    vendor.display.enable_default_color_mode=1 \
    vendor.display.dataspace_saturation_matrix=1.16868,-0.03155,-0.01473,-0.16868,1.03155,-0.05899,0.00000,0.00000,1.07372

# Display features
PRODUCT_PROPERTY_OVERRIDES += \
    sys.displayfeature_hidl=true \
    sys.displayfeature.hbm.enable=true \
    ro.displayfeature.histogram.enable=true \
    ro.eyecare.brightness.threshold=15 \
    ro.eyecare.brightness.level=8 \
    ro.hist.brightness.threshold=7 \
    ro.whitepoint_calibration_enable=true

# Display post-processing
PRODUCT_PROPERTY_OVERRIDES += \
    ro.qualcomm.cabl=0 \
    ro.vendor.display.ad=1 \
    ro.vendor.display.ad.hdr_calib_data=/vendor/etc/hdr_config.cfg \
    ro.vendor.display.ad.sdr_calib_data=/vendor/etc/sdr_config.cfg \
    ro.vendor.display.sensortype=2

# Graphics
PRODUCT_PROPERTY_OVERRIDES += \
    debug.sf.disable_backpressure=1 \
    debug.sf.enable_hwc_vds=1
#    sdm.debug.disable_inline_rotator=1 \
#    sdm.debug.disable_inline_rotator_secure=1

# Media
PRODUCT_PROPERTY_OVERRIDES += \
    audio.offload.video=true

# Memory optimizations
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.qti.sys.fw.bservice_enable=true

# Netflix custom property
PRODUCT_PROPERTY_OVERRIDES += \
    ro.netflix.bsp_rev=Q670-14477-1

# Perf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.qti.core_ctl_min_cpu=2 \
    ro.vendor.qti.core_ctl_max_cpu=4 \
    vendor.iop.enable_prefetch_ofr=0 \
    vendor.iop.enable_uxe=0 \
    persist.vendor.perfservice.disable=1

# RCS and IMS
PRODUCT_PROPERTY_OVERRIDES += \
    persist.rcs.supported=0 \
    persist.vendor.ims.disableUserAgent=0

# Nitz
PRODUCT_PROPERTY_OVERRIDES += \
    persist.rild.nitz_plmn="" \
    persist.rild.nitz_long_ons_0="" \
    persist.rild.nitz_long_ons_1="" \
    persist.rild.nitz_long_ons_2="" \
    persist.rild.nitz_long_ons_3="" \
    persist.rild.nitz_short_ons_0="" \
    persist.rild.nitz_short_ons_1="" \
    persist.rild.nitz_short_ons_2="" \
    persist.rild.nitz_short_ons_3=""

# Radio
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.fflag.override.settings_network_and_internet_v2=true \
    persist.radio.multisim.config=dsds \
    persist.vendor.radio.custom_ecc=1 \
    persist.vendor.radio.enable_temp_dds=true \
    persist.vendor.radio.enableadvancedscan=true \
    persist.vendor.radio.force_on_dc=true \
    persist.vendor.radio.procedure_bytes=SKIP \
    rild.libpath=/vendor/lib64/libril-qc-hal-qmi.so \
    persist.vendor.radio.atfwd.start=true \
    persist.vendor.radio.flexmap_type=none \
    persist.vendor.radio.force_on_dc=true \
    persist.vendor.radio.redir_party_num=1 \
    persist.vendor.radio.report_codec=1 \
    ril.subscription.types=RUIM \
    ro.telephony.default_network=22,22 \
    telephony.lteOnCdmaDevice=1 \
    persist.radio.add_power_save=1 \
    persist.vendor.radio.report_codec=1 \
    persist.vendor.radio.sib16_support=1 \
    persist.vendor.radio.uicc_se_enabled=true \
    DEVICE_PROVISIONED=1 \
    ro.se.type=eSE,HCE,UICC

# SSR
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.ssr.enable_ramdumps=0 \
    persist.vendor.ssr.restart_level=ALL_ENABLE

# TimeService
PRODUCT_PROPERTY_OVERRIDES += \
    persist.timed.enable=true \
    persist.delta_time.enable=true

# WFD
PRODUCT_PROPERTY_OVERRIDES += \
    persist.debug.wfd.enable=1 \
    persist.sys.wfd.virtual=0

# FP
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.fp.fod=true \
    persist.vendor.sys.fp.fod.location.X_Y=448,1938 \
    persist.vendor.sys.fp.fod.size.width_height=185,185
