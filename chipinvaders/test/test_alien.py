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
        self.hit = dut.hit
        self.dir = dut.dir
        self.fire = dut.fire
        self.alive = dut.alive
        self.fired = dut.fired
        
    async def reset_module(self):
        self.rst_n.value = 0
        await FallingEdge(self.clk)
        self.rst_n.value = 1
        await RisingEdge(self.clk)
        
    async def set_hit(self, hit: int = 1):
        self.hit.value = hit
        await RisingEdge(self.clk)

@cocotb.test()
async def test_init(dut):
    """Test: Test inital values"""    
    tester = AlienTester(dut)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    
    # initial values
    have_alive = tester.alive.value
    have_fired = tester.fired.value
    
    assert have_fired == 0, f"test_init (fired): Expected 0, got {have_fired}"
    assert have_alive == 1, f"test_init (alive): Expected 1, got {have_alive}"

    # revert values
    tester.alive.value = 0
    tester.fired.value = 1

    await tester.reset_module()
    
    # values after reset signal
    have_alive = tester.alive.value
    have_fired = tester.fired.value
    
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