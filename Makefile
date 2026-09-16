APP := ResolutionBar
BUILD_DIR := build
PRODUCT := $(BUILD_DIR)/Build/Products/Release/$(APP).app

.PHONY: build install uninstall clean

build:
	xcodebuild -project $(APP).xcodeproj -scheme $(APP) -configuration Release \
		-destination 'generic/platform=macOS' -derivedDataPath $(BUILD_DIR) -quiet build

# Replaces the copy in /Applications and starts it. The first launch registers it as a login item.
install: build
	-pkill -x $(APP)
	rm -rf /Applications/$(APP).app
	ditto $(PRODUCT) /Applications/$(APP).app
	open /Applications/$(APP).app

uninstall:
	-pkill -x $(APP)
	rm -rf /Applications/$(APP).app

clean:
	rm -rf $(BUILD_DIR)
