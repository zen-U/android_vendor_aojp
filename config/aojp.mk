# Copyright (C) 2014 KBC Developers
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

LOCAL_PATH := vendor/aojp

# default locale
PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.locale.language=ja \
    ro.product.locale.region=JP

#Input method (Japanese keyboard)
PRODUCT_PACKAGES += OpenWnn libWnnEngDic libWnnJpnDic libwnndict

# Felica for samsung deviceis
#PRODUCT_COPY_FILES += \
#    $(LOCAL_PATH)/rootdir/sbin/felica_init.sh:root/sbin/felica_init.sh\
#    $(LOCAL_PATH)/rootdir/sbin/setpropex:root/sbin/setpropex
#
