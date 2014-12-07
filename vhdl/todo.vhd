library IEEE;
use IEEE.std_logic_1164.all;

-- If you're seeing this file, I was too lazy to remove it in the release.
-- Shame on me.
--
--            .---------------------------------------------------.
--            | rv                                                |
--            | .---------------------------------------.         |
--            | | pls (pipelanes)                       |         |
--            | |  .=================================.  | .-----. |
--            | |  | pl (pipelane)                   |  | |gpreg| |
--            | |  |  - . .---.  - - .  - - .  - - . |  | |.---.| |
--  imem <----+-+->| |br  |alu| |mulu  |memu  |brku  |<-+>||fwd|| |
--            | |  |  - ' '---'  - - '  - - '  - - ' |  | |'---'| |
--            | |  '================================='  | '-----' |
--            | |    ^             ^       ^      ^     |         |
--            | |    |             |       |      |     |         |
--            | |    v             v       v      v     |         |
--            | | .------.       .====.  .----. .----.  |         |
--          .-+-+>|cxplif|       |dmsw|  |trap| |limm|  |         |
--          | | | '------'       '===='  '----' '----'  |         |
--          | | |    ^            ^  ^                  |         |
--          | | |    |            |  '------------------+---------+--> dmem
-- rctrl <-<  | '----+------------+---------------------'         |
--          | |      v            v                               |
--          | |   .=====.      .----.      .-----.      .-----.   |
--          | |   |cxreg|<---->|creg|<---->|gbreg|<---->|     |<--+--> mem
--          '-+-->|.---.|      '----'      '-----'      | cfg |   |
--            |   ||fwd||         ^           ^   ...<--|     |   |
--            |   |'---'|---------+-----------+-------->|     |   |
--            |   '====='         |           |         '-----'   |
--            '-------------------+-----------+-------------------'
--                                |           |
--                                v           |
--                               dbg    imem affinity
--
--
-- Entity TODO list:
-- [x] rv     = RVex processor             @ rvex.vhd
-- [x] pls    = PipeLaneS                  @ rvex_pipelanes.vhd
-- [x] pl     = PipeLane                   @ rvex_pipelane.vhd
-- [x] br     = BRanch unit                @ rvex_branch.vhd
-- [x] alu    = Arith. Logic Unit          @ rvex_alu.vhd
-- [x] memu   = MEMory Unit                @ rvex_memu.vhd
-- [x] mulu   = MULtiply Unit              @ rvex_mul.vhd
-- [x] brku   = BReaKpoint Unit            @ rvex_breakpoint.vhd
-- [x] gpreg  = General Purpose REGisters  @ rvex_gpreg.vhd
-- [x] fwd    = ForWarDing logic           @ rvex_forward.vhd
-- [x] cxplif = ConteXt Register InterFace @ rvex_contextPipelaneIFace.vhd
-- [x] dmsw   = Data Memory SWitch         @ rvex_dmemSwitch.vhd
-- [x] limm   = Long IMMediate routing     @ rvex_limmRouting.vhd
-- [x] trap   = TRAP routing               @ rvex_trapRouting.vhd
-- [x] cxreg  = ConteXt REGister logic     @ rvex_contextRegLogic.vhd
-- [x] creg   = Control REGisters          @ rvex_ctrlRegs.vhd
-- [x] gbreg  = GloBal REGister logic      @ rvex_globalRegLogic.vhd
-- [x] cfg    = ConFiGuration control      @ rvex_cfgCtrl.vhd
--
-- *yay*
--
-- Key for the entity TODO list:
-- [ ] = nothing done
-- [?] = some work is done, but it's out of date
-- [.] = entity done
-- [x] = architecture done
--
-- More specific TODO list now that the core code is almost done:
-- [x] Make the pretty-print procedure for trap information to finish
--     pretty-printed simulation output.
-- [x] Make bus logic stuff for control registers.
-- [x] Make package with procedures which allow procedural
--     generation/configuration of the control registers, so cxreg and gbreg
--     don't become one big mess.
-- [ ] On that note, making the opcode package more procedurally generated to
--     compress the VHDL code a bit is not a bad thing either.
-- [x] Figure out the register map again, with all changes that I've implicitly
--     made embedded in it.
-- [x] Code cxreg and gbreg, (hopefully) in such a way that the code is neatly
--     formatted enough to double as a register map table.
-- [x] Port general purpose register file from current rvex design to the code
--     style of the new design and add the debug bus interface and forwarding
--     to it.
-- [.] Make a testbench for the processor which accepts a bunch of test cases
--     with assembly input and a set of expected memory accesses. (mostly done)
-- [ ] Make a lot of those test cases.
-- [ ] Debug core.
-- [ ] Make synthesizable standalone core design to synthesize and test on the
--     ML605.
-- [ ] Debug standalone on ML605.
-- (standalone core should be functional at this point)
-- [ ] Make reconfCache generic-configurable.
-- [ ] Add the necessary extra status outputs to reconfCache.
-- [ ] Fix the incorrect flushing behavior for bypass writes while you're at
--     it.
-- [ ] Make cached core design.
-- [ ] Make a synthesizable testbench thing to test the core + cache without
--     needing to deal with grlib first.
-- [ ] Debug cache(d core) on ML605.
-- [ ] Connect cached core design to grlib.
-- [ ] Debug grlib'd core on ML605.
-- (full core should be functional at this point)
-- [ ] Optimize timing performance if necessary/possible.
-- [ ] Add performance counters, at least to the point where it supports the
--     same stuff as the old core.
-- [ ] Add ll/sc instructions.
-- [ ] Make basic PDF with documentation.
-- [ ] Wrap everything up in a box nicely.

entity todo is
end todo;

architecture Behavioral of todo is
begin
end Behavioral;

