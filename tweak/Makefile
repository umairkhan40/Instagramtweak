TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = Instagram
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Rhino

Rhino_FILES = Tweak.x
Rhino_CFLAGS = -fobjc-arc
Rhino_FRAMEWORKS = UIKit CoreFoundation Foundation Photos AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
