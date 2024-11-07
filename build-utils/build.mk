define gen_build
BUILD_DIR_$(BUILD_NAME) := $(1)

ifneq ($(TB_SOURCE),)
$(foreach x, $(TB_SOURCE), \
	$(eval $(call gen_build_next, $(x), $$(BUILD_DIR_$(BUILD_NAME)))) \
)
endif

ifneq ($(V_COMPILE),)
$(foreach x, $(V_COMPILE), \
	$(eval $(call verilator_build_stage, $(x), $$(BUILD_DIR_$(BUILD_NAME)))) \
)




.PHONY: Test_$(BUILD_NAME)
Test_$(BUILD_NAME): 
	@echo $(V_COMPILE)
endif

endef
# $(eval $(call verilator_build, $$(BUILD_DIR_$(BUILD_NAME))))

# define verilator_build

# .PHONY: compile-v-$(BUILD_NAME)
# compile-v-$(BUILD_NAME): $(wildcard V_STAGE_$(BUILD_NAME)*)
# 	@echo Test

# endef

define verilator_build_stage
STAGE := $(1)
ifneq ($(1),)
.PHONY: V_STAGE_$(BUILD_NAME)_$(STAGE)
V_STAGE_$(BUILD_NAME)_$(STAGE):
	@echo V_STAGE_$(BUILD_NAME)_$(STAGE)
	@echo V_SOURCE_$(STAGE)
	cd $(2) && \
	verilator -Wall --cc $$(V_SOURCE_$(STAGE)) --top-module $(STAGE) --trace --Wno-DECLFILENAME --Wno-PINCONNECTEMPTY -Wno-UNUSED
endif
endef


define gen_build_next
ifeq ($(suffix $(1)),.v)
.PHONY: build-iv-$(BUILD_NAME)
build-iv-$(BUILD_NAME):
	cd $(2) && \
	iverilog -o $(basename $(notdir $(1))).out -DVCD_DUMP=1 $(1) $(TB_INCLUDE) && \
	vvp $(basename $(notdir $(1))).out
endif
endef


# ifeq ($(suffix $(1)),.cpp)
# .PHONY: build-v-$(BUILD_NAME)
# build-v-$(BUILD_NAME):
# 	cd $(2) && \
# 	verilator -Wall --cc $(TB_INCLUDE) --top-module $(TB_TOP_MODULE) --trace --Wno-DECLFILENAME --Wno-PINCONNECTEMPTY -Wno-UNUSED
# endif