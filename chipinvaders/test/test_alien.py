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
        self.x_idx = dut.x_idx
        self.y_idx = dut.y_idx
        self.hit = dut.hit
        self.dir = dut.dir
        self.alive = dut.alive
        self.fired = dut.fired
        self.x_pos = dut.x_pos
        self.y_pos = dut.y_pos
        
    async def set_indices(self, x: int = 0, y: int = 0):
        await RisingEdge(self.clk)
        self.x_idx.value = x
        self.y_idx.value = y
        
    async def reset_module(self):
        self.rst_n.value = 0
        await FallingEdge(self.clk)
        self.rst_n.value = 1
        await FallingEdge(self.clk)
        
    async def set_hit(self, hit: int = 1):
        self.hit.value = hit
        await RisingEdge(self.clk)

@cocotb.test()
async def test_init(dut):
    """Test: Test inital values"""
    # todo: edit when bitmaps are finished
    alien_width = 10
    alien_spacing = 10
    
    tester = AlienTester(dut)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    for x in range(16):
        for y in range(16):
            expected_x_pos = (alien_width + alien_spacing) * x
            expected_y_pos = (alien_width + alien_spacing) * y
            
            dut._log.info(f"Test {x+y}: Init alien on position {x}, {y}")
            
            await tester.set_indices(x, y)
    
            await tester.reset_module()
            
            have_alive = tester.alive.value
            have_fired = tester.fired.value
            have_x_pos = int(str(tester.x_pos.value), 2)
            have_y_pos = int(str(tester.y_pos.value), 2)
            
            assert have_x_pos == expected_x_pos, f"test_init (x_pos): Expected {expected_x_pos}, got {have_x_pos}"
            assert have_y_pos == expected_y_pos, f"test_init (y_pos): Expected {expected_y_pos}, got {have_y_pos}"
            assert have_fired == 0, f"test_init (fired): Expected 0, got {have_fired}"
            assert have_alive == 1, f"test_init (alive): Expected 1, got {have_alive}"

    dut._log.info("✓ Init test passed")
    
@cocotb.test()
async def test_hit(dut):
    """Test: Test hitting the alien"""
    tester = AlienTester(dut)
    
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
       
    await tester.set_hit()
    
    await RisingEdge(tester.clk)
    have = tester.alive.value
    
    assert have == 0, f"test_hit: Expected 0, got {have}"
    
    dut._log.info("✓ Hitting test passed")


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
    )

    runner.test(hdl_toplevel="alien", test_module="test_alien", waves=True)

if __name__ == "__main__":
    test_alien_runner()