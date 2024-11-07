define gen_build
BUILD_DIR_$(BUILD_NAME) := $(1)

ifneq ($(TB_SOURCE),)
$(foreach x, $(TB_SOURCE), \
	$(eval $(call gen_build_next, $(x), $$(BUILD_DIR_$(BUILD_NAME)))) \
)
endif

ifneq ($(V_COMPILE),)
# Extract VERILATOR_ROOT and strip whitespace

$(foreach y, $(V_COMPILE), \
	$(eval $(call verilator_build_stage, $(y), $$(BUILD_DIR_$(BUILD_NAME)))) \
)
$(eval $(call verilator_build_stage, , $$(BUILD_DIR_$(BUILD_NAME))))

.PHONY: build-v-$(BUILD_NAME)
build-v-$(BUILD_NAME):
	test=$(shell verilator -V | grep "VERILATOR_ROOT" | awk '{print $$3}' | xargs)/include

.PHONY: compile-v-$(BUILD_NAME)
compile-v-$(BUILD_NAME): $(foreach x, $(V_COMPILE), _V_STAGE_$(BUILD_NAME)_$(x))

endif

endef


define verilator_build_stage
STAGE := $(1)
ifneq ($(STAGE),)
_V_STAGE_$(BUILD_NAME)_$(STAGE):
	@echo V_STAGE_$(BUILD_NAME)_$(STAGE)
	cd $(2) && \
	verilator -Wall --cc $$(V_SOURCE_$(STAGE)) --top-module $(STAGE) --trace --Wno-DECLFILENAME --Wno-PINCONNECTEMPTY -Wno-UNUSED && \
	cd obj_dir && \
	make -f V$(STAGE).mk
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
