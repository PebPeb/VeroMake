define gen_build

BUILD_DIR_$(BUILD_NAME) := $(1)

ifneq ($(TB_SOURCE),)
$(foreach x, $(TB_SOURCE), \
	$(eval $(call gen_build_next, $(x), $$(BUILD_DIR_$(BUILD_NAME)))) \
)
endif

ifneq ($(V_COMPILE),)

$(foreach y, $(V_COMPILE), \
	$(eval $(call next_stage, $(y))) \
	$(eval $(call verilator_build_stage, $(y), $$(BUILD_DIR_$(BUILD_NAME)))) \
)

		
.PHONY: compile-v-$(BUILD_NAME)
compile-v-$(BUILD_NAME): $(foreach x, $(V_COMPILE), _V_STAGE_$(BUILD_NAME)_$(x)) _build-v-$(BUILD_NAME)

# .PHONY: build-v-$(BUILD_NAME)
_build-v-$(BUILD_NAME):
	@echo $$(BUILD_DIR_$(BUILD_NAME))
	cd $$(BUILD_DIR_$(BUILD_NAME)) && \
	g++ -I obj_dir -I$(VERILATOR_DIR)/include \
	./$(V_TB) \
	obj_dir/*__ALL.cpp \
	$(VERILATOR_DIR)/include/verilated.cpp \
	$(VERILATOR_DIR)/include/verilated_vcd_c.cpp \
	-o $(BUILD_NAME).o 

endif
endef


# Issues With $(1) be aassigned after execution
# 'next_stage' is called before 'verilator_build_stage'
define next_stage
STAGE := $(1)
endef

# Builds verilator
# Then compiles the verilator output
define verilator_build_stage
_V_STAGE_$(BUILD_NAME)_$(STAGE):
	@echo V_STAGE_$(BUILD_NAME)_$(STAGE)
	cd $(2) && \
	verilator -Wall --cc $$(V_SOURCE_$(STAGE)) --top-module $(STAGE) --trace --Wno-DECLFILENAME --Wno-PINCONNECTEMPTY -Wno-UNUSED && \
	cd obj_dir && \
	make -f V$(STAGE).mk
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
