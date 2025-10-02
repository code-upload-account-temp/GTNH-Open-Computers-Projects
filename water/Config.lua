local sides = require("sides")

T2_INPUT_HATCH_SIZE = 1024000
T3_INPUT_HATCH_SIZE = 1024000

-- T7 requires at least UV superconductor base in molten form, but can use higher-tier superconductor base fluids to multiply output by up to 2x
-- This system assumes all could be configured in the dual interface, but lets you choose which one to try to draw
-- Options are "UV" (1x), "UHV" (1.25x), "UEV" (1.5x), "UIV" (1.75x), "UMV" (2x)
-- Ignore this if T7 is not present
T7_SUPERCONDUCTOR_BASE_TIER = "UV"

-- Modify these to set desired target values in L, remember to reboot
T1_MAINTAIN = 100000
T2_MAINTAIN = 100000
T2_MIN_BATCH = 200000
T3_MAINTAIN = 100000
T3_MIN_BATCH = 200000
T4_MAINTAIN = 100000
T4_MIN_BATCH = 200000
T5_MAINTAIN = 100000
T5_MIN_BATCH = 200000
T6_MAINTAIN = 100000
T6_MIN_BATCH = 200000
T7_MAINTAIN = 100000
T7_MIN_BATCH = 200000
T8_MAINTAIN = 100000
T8_MIN_BATCH = 200000

-- You can probably leave these as-is, but changing them will alter the amount of precursor water ordered for a batch, assuming the specified rate of failure
SUCCESS_CHANCE_GUESS_T1=0.85
SUCCESS_CHANCE_GUESS_T2=0.95
SUCCESS_CHANCE_GUESS_T3=0.95
SUCCESS_CHANCE_GUESS_T4=1
SUCCESS_CHANCE_GUESS_T5=0.99
SUCCESS_CHANCE_GUESS_T6=0.95
SUCCESS_CHANCE_GUESS_T7=0.85
SUCCESS_CHANCE_GUESS_T8=0.85
