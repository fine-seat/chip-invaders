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

class CannonTester:
    """Helper class for testing."""

    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.clk
        self.input_left = dut.input_left
        self.input_right = dut.input_right
        self.input_fire = dut.input_fire
        self.output_aliens = dut.output_aliens
        # self.output_cannon = dut.output_cannon
        self.y_pos_cannon = dut.y_pos_cannon
        self.x_pos_cannon = dut.x_pos_cannon
        self.alive_cannon = dut.alive_cannon

    async def set_operand(self, value: int, save_A: bool, save_B: bool):
        """Set operand input value."""
        await FallingEdge(self.clk)
        self.operand.value = value
        self.save_A.value = save_A
        self.save_B.value = save_B
        
    async def set_right(self):
        """Set right value."""
        await FallingEdge(self.clk)
        self.input_right.value = 1


@cocotb.test()
async def test_basic_movement(dut):
    """Test: Check basic movement functionality"""
    tester = CannonTester(dut)

    clock = Clock(dut.clk, 3, unit="us")
    cocotb.start_soon(clock.start())

    want = 105

    await tester.set_right()
    # replace this line with actions that we want to put to test
    await RisingEdge(tester.clk)
    await tester.set_right()

    have = int(str(tester.x_pos_cannon), 2)

    assert want == have, f"✗ Test failed\r\n\tExpected value: {want}\r\n\tReceived value:{have}"

    dut._log.info("✓ Test passed\r\n\tExpected and received values match")

def run_tests():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent

    sources = [proj_path / "src" / "chipinvaders.sv"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="chipinvaders",
        always=True,
        waves=True,
        timescale=("1ns", "1ps"),
    )

    runner.test(hdl_toplevel="chipinvaders", test_module="test_chipinvaders", waves=True)

if __name__ == "__main__":
    run_tests()