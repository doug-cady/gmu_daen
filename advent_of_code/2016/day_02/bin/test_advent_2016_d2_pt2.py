"""
Testing Advent 2016 Day 2 Part 2.
"""

import advent_2016_day2_pt2 as pt2
# TODO ##

def test_move() -> None:
    """Test move class method."""
    test_move_pt = pt2.Point(keyrows=3, nums=9, beg_rowcol=[1, 1],
                             proc="URLL\nRUUDDDD\nLRUUR\n")
    test_move_pt.move(instr='R')
    observed_result = (test_move_pt.row, test_move_pt.col)
    expected_result = (1, 2)
    assert observed_result == expected_result

    test_move_pt.move(instr='D')
    observed_result = (test_move_pt.row, test_move_pt.col)
    expected_result = (2, 2)
    assert observed_result == expected_result


def test_exec_instructions() -> None:
    """Test execute instructions class method."""
    procs = "URLL\nRUUDDDD\nLRUUR\n"
    test_inst_pt = pt2.Point(keyrows=3, nums=9, beg_rowcol=[1, 1], proc=procs)

    observed_result = test_inst_pt.exec_instructions()
    expected_result = "183"
    assert observed_result == expected_result
