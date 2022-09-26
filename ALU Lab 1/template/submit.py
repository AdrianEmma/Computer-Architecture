#!/usr/bin/python3

from JenkinsJob import JenkinsJob
from JenkinsJob import authenticate
from JenkinsJob import queryAction
from pathlib import Path

"""
Tutorial submission script
"""
if __name__ == "__main__":

    choices = ["build", "check"]
    action = queryAction(choices)
    auth = authenticate()
    
    here = Path(__file__).parent.absolute()

    def getAbsPath(subdir, files):
        prefix_path = here / Path(subdir)
        return [prefix_path / Path(f) for f in files]
    
    vhdl = getAbsPath(
        "vhdl",
        ["add_sub.vhd", "ALU.vhd", "comparator.vhd", "logic_unit.vhd", "multiplexer.vhd", "shift_unit.vhd"]
    )

    tb = getAbsPath(
        "testbench",
        ["tb_ALU.vhd", "tb_logic_unit.vhd"]
    )


    job = JenkinsJob(
        name=f"01-alu-{auth[0]}",
        files= vhdl + tb,
        auth=auth
    )
    
    if action == "build":
        job.build(zipfiles=False)
    else:
        job.getLogs()
