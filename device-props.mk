# Camera
PRODUCT_PROPERTY_OVERRIDES += \
    persist.camera.sat.fallback.dist=28 \
    persist.camera.sat.fallback.dist.d=5 \
    persist.camera.sat.fallback.luxindex=230 \
    persist.camera.sat.fallback.lux.d=50

# Display density
PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=480

# Display features
PRODUCT_PROPERTY_OVERRIDES += \
    ro.displayfeature.histogram.enable=true \
    ro.eyecare.brightness.threshold=11 \
    ro.eyecare.brightness.level=5 \
    ro.hist.brightness.threshold=7

# Media
PRODUCT_PROPERTY_OVERRIDES += \
    media.settings.xml=/system/etc/media_profiles_vendor.xml

# NFC
PRODUCT_PROPERTY_OVERRIDES += \
    ro.nfc.port=I2C

# Radio
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.uicc_se_enabled=true
