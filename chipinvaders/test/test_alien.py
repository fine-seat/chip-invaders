"""
Modern cocotb 2.0 testbench for the Controller module.
Uses async/await syntax and modern pythonic patterns.
"""

import os
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb.types import LogicArray

from cocotb_tools.runner import get_runner
import random

os.environ['COCOTB_ANSI_OUTPUT'] = '1'

class AlienTester:
    """Helper class for alien testing."""

    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.clk
        self.rst_n = dut.rst_n
        self.alive = dut.alive
        self.movement_frequency = dut.movement_frequency
        self.movement_direction = dut.movement_direction
        self.armed = dut.armed
        self.position_x = dut.position_x
        self.position_y = dut.position_y
        self.graphics = dut.graphics
        
    async def reset_module(self):
        self.rst_n.value = 0
        await FallingEdge(self.clk)
        self.rst_n.value = 1
        await RisingEdge(self.clk)
        
    # async def set_hit(self, hit: int = 1):
    #     self.hit.value = hit
    #     await RisingEdge(self.clk)

@cocotb.test()
async def test_reset(dut):
    """Test: Test reset"""    
    tester = AlienTester(dut)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await tester.reset_module()
    
    have_x = int(str(tester.position_x.value), 2)
    have_y = int(str(tester.position_y.value), 2)
    
    # values after reset signal    
    assert have_x == dut.INITIAL_POSITION_X.value, f"test_reset (x): Expected {dut.INITIAL_POSITION_X.value}, got {have_x}"
    assert have_y == dut.INITIAL_POSITION_Y.value, f"test_reset (y): Expected {dut.INITIAL_POSITION_Y.value}, got {have_y}"
    
    dut._log.info("✓ Reset test passed")
    
# @cocotb.test()
# async def test_hit(dut):
#     """Test: Test hitting the alien"""
#     tester = AlienTester(dut)
    
#     clock = Clock(dut.clk, 10, unit="us")
#     cocotb.start_soon(clock.start())
       
#     await tester.set_hit()
    
#     await RisingEdge(tester.clk)
#     have = tester.alive.value
    
#     assert have == 0, f"test_hit: Expected 0, got {have}"
    
#     dut._log.info("✓ Hitting test passed")


def test_alien_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent

    sources = [proj_path / "src" / "rtl" / "alien.sv"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="alien",
        always=True,
        waves=True,
        timescale=("1ns", "1ps"),
        parameters={
            "INITIAL_POSITION_X": 0,
            "INITIAL_POSITION_Y": 0
        }
    )

    runner.test(hdl_toplevel="alien", test_module="test_alien", waves=True)

if __name__ == "__main__":
    test_alien_runner()