/**
 * r-VEX simulator.
 *
 * Copyright (C) 2008-2015 by TU Delft.
 * All Rights Reserved.
 *
 * THIS IS A LEGAL DOCUMENT, BY USING r-VEX,
 * YOU ARE AGREEING TO THESE TERMS AND CONDITIONS.
 *
 * No portion of this work may be used by any commercial entity, or for any
 * commercial purpose, without the prior, written permission of TU Delft.
 * Nonprofit and noncommercial use is permitted as described below.
 *
 * 1. r-VEX is provided AS IS, with no warranty of any kind, express
 * or implied. The user of the code accepts full responsibility for the
 * application of the code and the use of any results.
 *
 * 2. Nonprofit and noncommercial use is encouraged. r-VEX may be
 * downloaded, compiled, synthesized, copied, and modified solely for nonprofit,
 * educational, noncommercial research, and noncommercial scholarship
 * purposes provided that this notice in its entirety accompanies all copies.
 * Copies of the modified software can be delivered to persons who use it
 * solely for nonprofit, educational, noncommercial research, and
 * noncommercial scholarship purposes provided that this notice in its
 * entirety accompanies all copies.
 *
 * 3. ALL COMMERCIAL USE, AND ALL USE BY FOR PROFIT ENTITIES, IS EXPRESSLY
 * PROHIBITED WITHOUT A LICENSE FROM TU Delft (J.S.S.M.Wong@tudelft.nl).
 *
 * 4. No nonprofit user may place any restrictions on the use of this software,
 * including as modified by the user, by any other authorized user.
 *
 * 5. Noncommercial and nonprofit users may distribute copies of r-VEX
 * in compiled or binary form as set forth in Section 2, provided that
 * either: (A) it is accompanied by the corresponding machine-readable source
 * code, or (B) it is accompanied by a written offer, with no time limit, to
 * give anyone a machine-readable copy of the corresponding source code in
 * return for reimbursement of the cost of distribution. This written offer
 * must permit verbatim duplication by anyone, or (C) it is distributed by
 * someone who received only the executable form, and is accompanied by a
 * copy of the written offer of source code.
 *
 * 6. r-VEX was developed by Stephan Wong, Thijs van As, Fakhar Anjam,
 * Roel Seedorf, Anthony Brandon, Jeroen van Straten. r-VEX is currently
 * maintained by TU Delft (J.S.S.M.Wong@tudelft.nl).
 *
 * Copyright (C) 2008-2015 by TU Delft.
 */

#ifndef RVSIM_COMPONENTS_CORE_CORETYPES_H
#define RVSIM_COMPONENTS_CORE_CORETYPES_H

#include <inttypes.h>
#include "Generated.h"

namespace Core {

/**
 * VHDL typedefs which are not known by the configuration scripts.
 */
typedef bitvec4_t mask_t;
typedef bitvec32_t syllable_t;
typedef char *charPtr_t;

/**
 * Maximum supported core sizes.
 */
#define CORE_MAX_CONTEXTS     8
#define CORE_MAX_LANES        16
#define CORE_MAX_LANE_GROUPS  8

/**
 * All rvex core generics.
 */
typedef struct {

	cfgVect_t  CFG;
    natural_t  CORE_ID;
    bitvec56_t PLATFORM_TAG;

} coreInterfaceGenerics_t;

/**
 * All rvex core input signals.
 */
typedef struct {

	// System control.
	bit_t      reset;
	bit_t      clkEn;

	// Run control interface.
	bit_t      rctrl2rv_irq[CORE_MAX_CONTEXTS];
	address_t  rctrl2rv_irqID[CORE_MAX_CONTEXTS];
	bit_t      rctrl2rv_run[CORE_MAX_CONTEXTS];
	bit_t      rctrl2rv_reset[CORE_MAX_CONTEXTS];
    address_t  rctrl2rv_resetVect[CORE_MAX_CONTEXTS];

    // Common memory interface.
    bit_t      mem2rv_blockReconfig[CORE_MAX_LANE_GROUPS];
    bit_t      mem2rv_stallIn[CORE_MAX_LANE_GROUPS];
    cacheStatus_t mem2rv_cacheStatus[CORE_MAX_LANE_GROUPS];

    // Instruction memory interface.
    syllable_t imem2rv_instr[CORE_MAX_LANES];
    bitvec32_t imem2rv_affinity;
    bit_t      imem2rv_busFault[CORE_MAX_LANE_GROUPS];

    // Data memory interface.
    data_t     dmem2rv_readData[CORE_MAX_LANE_GROUPS];
    bit_t      dmem2rv_ifaceFault[CORE_MAX_LANE_GROUPS];
    bit_t      dmem2rv_busFault[CORE_MAX_LANE_GROUPS];

    // Control/debug bus interface.
    address_t  dbg2rv_addr;
    bit_t      dbg2rv_readEnable;
    bit_t      dbg2rv_writeEnable;
    mask_t     dbg2rv_writeMask;
    data_t     dbg2rv_writeData;

    // Trace interface.
    bit_t      trsink2rv_busy;

} coreInterfaceIn_t;

/**
 * All rvex core output signals.
 */
typedef struct {

	// System control.
	bit_t      resetOut;

	// VHDL simulation debug information.
	charPtr_t  rv2sim[2*CORE_MAX_LANES + CORE_MAX_LANE_GROUPS + CORE_MAX_CONTEXTS];

	// Run control interface.
	bit_t      rv2rctrl_irqAck[CORE_MAX_CONTEXTS];
	bit_t      rv2rctrl_idle[CORE_MAX_CONTEXTS];
	bit_t      rv2rctrl_done[CORE_MAX_CONTEXTS];

	// Common memory interface.
	bit_t      rv2mem_decouple[CORE_MAX_LANE_GROUPS];
	bit_t      rv2mem_stallOut[CORE_MAX_LANE_GROUPS]; // Combinatorial!

	// Instruction memory interface.
	address_t  rv2imem_PCs[CORE_MAX_LANE_GROUPS];
	bit_t      rv2imem_fetch[CORE_MAX_LANE_GROUPS];
	bit_t      rv2imem_cancel[CORE_MAX_LANE_GROUPS];

	// Data memory interface.
	address_t  rv2dmem_addr[CORE_MAX_LANE_GROUPS];
	bit_t      rv2dmem_readEnable[CORE_MAX_LANE_GROUPS];
	data_t     rv2dmem_writeData[CORE_MAX_LANE_GROUPS];
	mask_t     rv2dmem_writeMask[CORE_MAX_LANE_GROUPS];
	bit_t      rv2dmem_writeEnable[CORE_MAX_LANE_GROUPS];

	// Control/debug bus interface.
	data_t     rv2dbg_readData;

	// Trace interface.
	bit_t      rv2trsink_push;
	byte_t     rv2trsink_data;
	bit_t      rv2trsink_end;

} coreInterfaceOut_t;

} /* namespace Core */

#endif
