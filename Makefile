#/***************************************************************************
# KVM
#
# Kinematic Velocity Modelling
#							 -------------------
#		begin				: 2025-04-18
#		git sha				: $Format:%H$
#		copyright			: (C) 2025 by Anonymous
#		email				: Anonymous@hotmail.com
# ***************************************************************************/
#
#/***************************************************************************
# *																		 *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or	 *
# *   (at your option) any later version.								   *
# *																		 *
# ***************************************************************************/

#################################################
# Edit the following to match your sources lists
#################################################

PLUGINNAME := KVM

PY_FILES := __init__.py \
	KVM.py \
	KVM_dialog.py

UI_FILES := KVM_dialog_base.ui \
	Dialog_time.ui \
	table_asv.ui

RESOURCE_QRC := resources.qrc
COMPILED_RESOURCE_FILES := resources.py

EXTRA_FILES := metadata.txt icon.png README.txt README.html pb_tool.cfg plugin_upload.py
EXTRA_DIRS := data help i18n scripts

LOCALES :=
LRELEASE ?= lrelease

PACKAGE_DIR := dist
ZIP_FILE := $(PACKAGE_DIR)/$(PLUGINNAME).zip

# Example for Windows:
# make deploy QGIS_PLUGIN_DIR="C:/Users/your_user/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins"
QGIS_PLUGIN_DIR ?=

.PHONY: help compile transcompile clean package deploy remove

help:
	@echo "Available targets:"
	@echo "  make compile        Compile Qt resource files (resources.qrc -> resources.py)"
	@echo "  make transcompile   Compile translation files (.ts -> .qm) if LOCALES are set"
	@echo "  make clean          Remove generated files (resources.py, *.qm, dist/)"
	@echo "  make package        Create a distributable ZIP in dist/"
	@echo "  make deploy         Copy plugin to local QGIS plugin directory (set QGIS_PLUGIN_DIR)"
	@echo "  make remove         Remove deployed plugin from local QGIS plugin directory"

compile: $(COMPILED_RESOURCE_FILES)

$(COMPILED_RESOURCE_FILES): $(RESOURCE_QRC)
	pyrcc5 -o $(COMPILED_RESOURCE_FILES) $(RESOURCE_QRC)

transcompile:
ifneq ($(strip $(LOCALES)),)
	@echo "Compiling translations..."
	@for loc in $(LOCALES); do \
		$(LRELEASE) i18n/$$loc.ts -qm i18n/$$loc.qm; \
	done
else
	@echo "No LOCALES defined; skipping translation compilation."
endif

clean:
	rm -f $(COMPILED_RESOURCE_FILES)
	rm -f i18n/*.qm
	rm -rf $(PACKAGE_DIR)

package: compile
	@mkdir -p $(PACKAGE_DIR)/$(PLUGINNAME)
	# Copy core files
	cp -f $(PY_FILES) $(PACKAGE_DIR)/$(PLUGINNAME)/
	cp -f $(UI_FILES) $(PACKAGE_DIR)/$(PLUGINNAME)/
	cp -f $(COMPILED_RESOURCE_FILES) $(PACKAGE_DIR)/$(PLUGINNAME)/
	cp -f $(EXTRA_FILES) $(PACKAGE_DIR)/$(PLUGINNAME)/
	# Copy directories if they exist
	@for d in $(EXTRA_DIRS); do \
		if [ -d $$d ]; then cp -rf $$d $(PACKAGE_DIR)/$(PLUGINNAME)/; fi; \
	done
	# Create ZIP
	rm -f $(ZIP_FILE)
	cd $(PACKAGE_DIR) && zip -r $(PLUGINNAME).zip $(PLUGINNAME)
	@echo "Created package: $(ZIP_FILE)"

deploy: compile
ifndef QGIS_PLUGIN_DIR
	$(error QGIS_PLUGIN_DIR is not set. Example: make deploy QGIS_PLUGIN_DIR="C:/Users/your_user/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins")
endif
	@mkdir -p "$(QGIS_PLUGIN_DIR)/$(PLUGINNAME)"
	cp -f $(PY_FILES) "$(QGIS_PLUGIN_DIR)/$(PLUGINNAME)/"
	cp -f $(UI_FILES) "$(QGIS_PLUGIN_DIR)/$(PLUGINNAME)/"
	cp -f $(COMPILED_RESOURCE_FILES) "$(QGIS_PLUGIN_DIR)/$(PLUGINNAME)/"
	cp -f $(EXTRA_FILES) "$(QGIS_PLUGIN_DIR)/$(PLUGINNAME)/"
	@for d in $(EXTRA_DIRS); do \
		if [ -d $$d ]; then cp -rf $$d "$(QGIS_PLUGIN_DIR)/$(PLUGINNAME)/"; fi; \
	done
	@echo "Plugin deployed to: $(QGIS_PLUGIN_DIR)/$(PLUGINNAME)"

remove:
ifndef QGIS_PLUGIN_DIR
	$(error QGIS_PLUGIN_DIR is not set. Example: make remove QGIS_PLUGIN_DIR="C:/Users/your_user/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins")
endif
	rm -rf "$(QGIS_PLUGIN_DIR)/$(PLUGINNAME)"
	@echo "Plugin removed from: $(QGIS_PLUGIN_DIR)/$(PLUGINNAME)"

