###############################################################################
# Linux Shared Library Makefile Template

TYPE_DEFINES=
TYPE_INCLUDES=
TYPE_CCFLAGS=

include $(shell pwd)/$(dir $(lastword $(MAKEFILE_LIST)))/common.linux.makefile

###############################################################################
# Customizations

LIBS=$(CUSTOM_LIBS)
STATIC_LIBS=$(CUSTOM_STATIC_LIBS)
DYNAMIC_LIBS=$(CUSTOM_DYNAMIC_LIBS)

LDFLAGS=$(CUSTOM_LDFLAGS) -shared $(addprefix -Xlinker --exclude-libs -Xlinker ,$(addsuffix .a,$(addprefix lib,$(STATIC_LIBS)))) -Xlinker -no-undefined -static-libgcc

TARGET_PATH=$(BUILD_DIR)/$(NAME).so

$(TARGET_PATH): $(OBJECTS) $(DEPS)
	mkdir -p $(dir $(TARGET_PATH))
	gcc -fvisibility=hidden -o$(TARGET_PATH) $(LDFLAGS) $(OBJECTS) $(addsuffix .a,$(addprefix $(PRODUCT_DIR)/lib,$(LIBS))) -Wl,-Bstatic $(addprefix -l,$(STATIC_LIBS)) -Wl,-Bdynamic $(addprefix -l,$(DYNAMIC_LIBS))
	cd $(BUILD_DIR) && \
		objcopy --only-keep-debug "$(NAME).so" "$(NAME).so.dbg" && \
		strip --strip-debug --strip-unneeded "$(NAME).so" && \
		objcopy --add-gnu-debuglink="$(NAME).so.dbg" "$(NAME).so"
		
.PHONY: $(NAME)
$(NAME): $(TARGET_PATH)
