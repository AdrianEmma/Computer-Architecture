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
    prefix_path = here / Path("vhdl")
    fileset = ["circuit.vhd"]

    job = JenkinsJob(
        name=f"00-tutorial-{auth[0]}",
        files=[prefix_path / Path(f) for f in fileset],
        auth=auth
    )
    
    if action == "build":
        job.build(zipfiles=False)
    else:
        job.getLogs()
