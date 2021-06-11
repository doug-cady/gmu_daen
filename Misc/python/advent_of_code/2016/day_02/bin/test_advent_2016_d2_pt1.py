"""
Testing Advent 2016 Day 2 Part 1.
"""

import advent_2016_day2_pt1 as pt1


def test_parse_input() -> None:
    """Test parse input class method."""
    test_parse_pt = pt1.Point(keyrows=3, nums=9, beg_rowcol=[1, 1],
                              proc="URLL\nRUUDDDD\nLRUUR\n")
    assert test_parse_pt.proc_list == ['URLL', 'RUUDDDD', 'LRUUR']


def test_move() -> None:
    """Test move class method."""
    test_move_pt = pt1.Point(keyrows=3, nums=9, beg_rowcol=[1, 1],
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
    test_inst_pt = pt1.Point(keyrows=3, nums=9, beg_rowcol=[1, 1], proc=procs)

    observed_result = test_inst_pt.exec_instructions()
    expected_result = "183"
    assert observed_result == expected_result
