include $(PROJECT_ROOT)/build-utils/build.mk
include $(PROJECT_ROOT)/build-utils/gtkwave.mk

# Get all dirs in 
# SIMS_FOLDERS := $(wildcard $(PROJECT_ROOT)/*/*/)
SIMS_FOLDERS := $(shell find $(PROJECT_ROOT) -type d -print)/

# Checks for tb.mk
# For every folder check for tb.mk if found add to VALID_SIMS_FOLDERS
VALID_SIMS_FOLDERS :=
$(foreach folder,$(SIMS_FOLDERS),$(if $(wildcard $(folder)/tb.mk),$(eval VALID_SIMS_FOLDERS += $(folder))))

# ------------------------------------------------------------ #

VERILATOR_DIR := $(shell verilator -V | grep "VERILATOR_ROOT" | awk '{print $$3}' | xargs)
define include_tb
include $(1)/tb.mk
endef

# ------------------------------------------------------------ #



# Make Process
$(foreach x, $(VALID_SIMS_FOLDERS), \
	$(eval $(call include_tb, $(x))) \
	$(eval $(call gen_build, $(x))) \
	$(eval $(call gtkwave_sim_target, $(x))) \
)

# Clean build
clean:
	$(foreach x,$(VALID_SIMS_FOLDERS), \
		rm -f $(x)/*.vcd && \
		rm -f $(x)/*.out && \
		rm -f $(x)/*.o && \
		rm -fr $(x)/obj_dir \
	)