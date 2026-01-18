ARCHS := arm64
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

# 记录构建开始时间
before-all::
	@date +%s > $(CURDIR)/.build_start

# 使用 Xcode 项目构建
XCODEPROJ_NAME = TrollSIMSwitcher
BUILD_VERSION = "1.2"
FILE_NAME = "com.developlab.trollsimswitcher"

# 指定 Theos 使用 xcodeproj 规则
include $(THEOS_MAKE_PATH)/xcodeproj.mk

# 在打包阶段用ldid签名赋予权力，顺便删除_CodeSignature
before-package::
	@if [ -f $(THEOS_STAGING_DIR)/Applications/$(XCODEPROJ_NAME).app/Info.plist ]; then \
		echo -e "\033[32mSigning with ldid...\033[0m"; \
		ldid -Sentitlements.plist $(THEOS_STAGING_DIR)/Applications/$(XCODEPROJ_NAME).app; \
	else \
		@echo -e "\033[31mNo Info.plist found. Skipping ldid signing.\033[0m"; \
	fi
	@echo -e "\033[32mRemoving _CodeSignature folder..."
	@rm -rf $(THEOS_STAGING_DIR)/Applications/$(XCODEPROJ_NAME).app/_CodeSignature
	@rm -rf $(THEOS_STAGING_DIR)/Applications/$(XCODEPROJ_NAME).app/PlugIns/TrollSIMSwitcherWidgetExtension.appex/_CodeSignature
	@echo -e "\033[32mRemoving Frameworks folder..."
	@rm -rf $(THEOS_STAGING_DIR)/Applications/$(XCODEPROJ_NAME).app/Frameworks
	@echo -e "\033[32mCopy RootHelper to package..."
	# 这里必须要手动复制RootHelper到包内，不要放到Xcode工程目录下，不然就无法运行二进制文件
	@cp -f MaintenanceHelper/MaintenanceHelper $(THEOS_STAGING_DIR)/Applications/$(XCODEPROJ_NAME).app/
	
# 包装完成后重命名为 .tipa
after-package::
	@echo "Renaming .ipa to .tipa..."
	@if [ -f ./packages/$(FILE_NAME)_$(BUILD_VERSION)+debug.ipa ]; then \
		mv ./packages/$(FILE_NAME)_$(BUILD_VERSION)+debug.ipa ./packages/$(FILE_NAME)_$(BUILD_VERSION)+debug.tipa; \
		echo "Renamed debug ipa to tipa."; \
	elif [ -f ./packages/$(FILE_NAME)_$(BUILD_VERSION).ipa ]; then \
		mv ./packages/$(FILE_NAME)_$(BUILD_VERSION).ipa ./packages/$(FILE_NAME)_$(BUILD_VERSION).tipa; \
		echo "Renamed release ipa to tipa."; \
	else \
		echo "No .ipa file found."; \
	fi
	
	@START=$$(cat $(CURDIR)/.build_start 2>/dev/null || date +%s); \
	 END=$$(date +%s); \
	 DURATION=$$((END - START)); \
	 echo "构建+打包耗时：$$DURATION 秒"; \
	 rm -f $(CURDIR)/.build_start
