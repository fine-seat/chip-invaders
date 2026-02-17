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

@cocotb.test()
async def test_move_right(dut):
    """Test: Test moving right"""
    tester = AlienTester(dut)
    
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    
    for i in range(1, 20):
        frequency_value = 10
        
        await tester.reset_module()
    
        tester.alive.value = 1
        tester.movement_frequency.value = frequency_value
        tester.movement_direction.value = 1
        await RisingEdge(tester.clk)
        
        for _ in range(i*(frequency_value + 1)):
            await RisingEdge(tester.clk)
        
        have = int(str(tester.position_x), 2)
        
        assert have == i, f"test_move_right: Expected {i}, got {have}"
        
    dut._log.info("✓ Test move right passed")


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