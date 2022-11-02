#!/usr/bin/python3

import sys
from pathlib import Path
from JenkinsJob import JenkinsJob
from JenkinsJob import authenticate
from JenkinsJob import queryAction

"""
Tutorial submission script
"""


if __name__ == "__main__":

    def get_target():
        valid_targets = ["preliminary", "final"]
        valid_targets_str = '/'.join(valid_targets)
        while True:
            sys.stdout.write(
                "Select submission target? [" + valid_targets_str + "] ")
            resp = input()
            if (resp in valid_targets):
                return resp
            sys.stdout.write("Invalid target! Try again.\n")

    target = get_target()

    choices = ["build", "check"]
    action = queryAction(choices)
    auth = authenticate()

    here = Path(__file__).parent.absolute()

    def getAbsPath(subdir, files):
        prefix_path = here / Path(subdir)
        return [prefix_path / Path(f) for f in files]



    job = JenkinsJob(
        name=f"04-gol-{target}-{auth[0]}",
        files=['gol.asm'],
        auth=auth
    )

    if action == "build":
        job.build(zipfiles=False)
    else:
        job.getLogs()
