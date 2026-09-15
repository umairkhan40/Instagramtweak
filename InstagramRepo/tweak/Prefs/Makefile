TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = RhinoPrefs

RhinoPrefs_FILES = RHSettingsController.m
RhinoPrefs_FRAMEWORKS = UIKit
RhinoPrefs_PRIVATE_FRAMEWORKS = Preferences
RhinoPrefs_INSTALL_PATH = /Library/PreferenceBundles
RhinoPrefs_FRAMEWORKS += Foundation

include $(THEOS_MAKE_PATH)/bundle.mk
