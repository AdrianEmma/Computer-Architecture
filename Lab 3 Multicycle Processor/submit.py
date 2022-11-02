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
        ["IR.vhd", "PC.vhd", "buttons.vhd", "controller.vhd", 
        "extend.vhd", "mux2x5.vhd", "mux2x16.vhd", "mux2x32.vhd", 
        "ALU.vhd", "add_sub.vhd", "comparator.vhd", "logic_unit.vhd",
        "multiplexer.vhd", "shift_unit.vhd", "register_file.vhd",
        "CPU.vhd", "decoder.vhd", "RAM.vhd"]
    )

  


    job = JenkinsJob(
        name=f"03-multicycle-{auth[0]}",
        files= vhdl,
        auth=auth
    )
    
    if action == "build":
        job.build(zipfiles=False)
    else:
        job.getLogs()
