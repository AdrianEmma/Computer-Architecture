
from http import HTTPStatus
from pathlib import Path

from zipfile import ZipFile

import os
import requests

import shutil
import sys

import getpass
from xml.dom import minidom

import argparse


def queryYesNo(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.
    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
        It must be "yes" (the default), "no" or None (meaning
        an answer is required of the user).
    The "answer" return value is True for "yes" or False for "no".
    """
    valid = {"yes": True, "y": True, "ye": True,
             "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "
                             "(or 'y' or 'n').\n")


def queryNumber(question, checker):
    """
    Prompt the user for a number, the checker argument is function from int to 
    bool that checks the validity of the number, e.g., lambda x: x > 10 if only
    numbers above 10 are accepted.
    """
    while True:
        sys.stdout.write(question)
        resp = input().lower()
        try:
            num = int(resp)
            if checker(num) == False:
                raise RuntimeError("invalid range")
            return num
        except:
            print(resp + " is not a valid response!")


def queryAction(choices):
    """
    Prompt the user for an action
    """
    choice_str = '/'.join(choices)
    while True:
        sys.stdout.write("Select action ? [" + choice_str + "] ")
        resp = input()
        if (resp in choices):
            return resp
        else:
            sys.stdout.write("Invalid action! Try again.\n")


def authenticate():
    """
    Create an authentication (user, password/token) pair
    """
    sys.stdout.write("GASPAR: ")
    user = input()
    token = getpass.getpass("token: ")
    return (user, token)


def raiseError(*args):
    """
    Raise an irrecoverable error
    """
    print('\033[91mError\033[0m:' + " ".join(map(str, args)))
    raise RuntimeError("Failed to submit")


class JenkinsJob:

    """
    Jenkins job structure for submitting builds (students), querying build 
    console logs (students) and disable or enabling them (admins)
    """
    DEFAULT_SERVER = 'https://ceng-labs.epfl.ch/job/'
    MAX_SUBMISSION = 3 # only for warning, does not inhibit building

    from http import HTTPStatus

    HTTPS_OK = HTTPStatus.OK
    HTTPS_CREATED = HTTPStatus.CREATED
    HTTPS_UNAUTHORIZED = HTTPStatus.UNAUTHORIZED
    HTTPS_FORBIDDEN = HTTPStatus.FORBIDDEN
    HTTPS_CONFLICT = HTTPStatus.CONFLICT

    def humanReadableError(status_code):
        obj = HTTPStatus(status_code)
        # return f"{str(obj)} ({status_code})"
        if (status_code == JenkinsJob.HTTPS_CREATED):
            return f"CREATED ({status_code})"
        elif (status_code == JenkinsJob.HTTPS_OK):
            return f"OK ({status_code})"
        elif (status_code == JenkinsJob.HTTPS_FORBIDDEN):
            return f"FORBIDDEN ACCESS ({status_code})"
        elif (status_code == JenkinsJob.HTTPS_UNAUTHORIZED):
            return f"Invalid credentials ({status_code})"
        elif (status_code == JenkinsJob.HTTPS_CONFLICT):
            return f"Submission disabled ({status_code})"
        else:
            return str(status_code)

    def assertStatus(got, expected, msg):
        if (got != expected):
            raiseError(f"{msg} error ${JenkinsJob.humanReadableError(got)}")
        else:
            return True

    def __init__(self, name, files, auth, no_prompt=False):

        self.no_prompt = no_prompt
        self.name = name
        self.files = files
        self.auth = auth
        self.job_address = JenkinsJob.DEFAULT_SERVER + name

    def getInfo(self):
        print("fetching job information " + self.job_address)
        job_info_req = requests.get(
            self.job_address + "/api/json",
            auth=self.auth
        )

        if (job_info_req.status_code != JenkinsJob.HTTPS_OK):
            raiseError("Can not find the job information! (error " +
                       JenkinsJob.humanReadableError(job_info_req.status_code) + ")")

        job_info = job_info_req.json()

        return job_info

    def makeSubmissionDir(self):

        submission_path = os.getcwd() / Path("__submission__")
        submission_path.mkdir(exist_ok=True)
        return submission_path

    def getLogs(self):
        job_info = self.getInfo()
        if (len(job_info['builds']) == 0):
            print("You do not have any builds.")
        else:
            build_num = queryNumber(
                f"Select a build number to see the output [1-{len(job_info['builds'])}]:",
                lambda x: x >= 1 and x <= len(job_info['builds'])
            )

            build_info_address = self.job_address + \
                "/" + str(build_num) + "/api/json"

            # print("Fetching build info from " + build_info_address)

            build_info_req = requests.get(
                build_info_address,
                auth=self.auth
            )

            if (build_info_req.status_code != JenkinsJob.HTTPS_OK):
                raiseError(
                    f"Failed to get build information: error {JenkinsJob.humanReadableError(build_info_req.status_code)} ")

            build_info = build_info_req.json()

            if (build_info['building'] == True):
                print("Build is not complete yet!")
            # else:
            #     def getTestAction():
            #         tests = None
            #         for action in build_info['actions']:
            #             if "_class" in action and action['_class'] == "hudson.tasks.junit.TestResultAction":
            #                 tests = action
            #         return tests

            #     tests = getTestAction()
            #     print(
            #         f"Test stats:\n\ttotal: {tests['totalCount']}\n\tfailed: {tests['failCount']}\n\tskipped: {tests['skipCount']}")
            #     print(f"Build status: {build_info['result']}")

            log_address = self.job_address + "/" + \
                str(build_num) + "/logText/progressiveText?start=0"
            print("Fetching logs from " + log_address)
            console = requests.get(
                log_address,
                auth=self.auth
            )
            if (console.status_code != JenkinsJob.HTTPS_OK):
                raiseError(
                    f"Failed to get logs: error {JenkinsJob.humanReadableError(console.status_code)}")

            logs = console.content.decode("ascii")
            submission_path = self.makeSubmissionDir()
            if (queryYesNo("Show logs?", "yes")):
                print(logs)
            if (queryYesNo("Save to file?", "yes")):
                logpath = submission_path / \
                    Path('build_' + str(build_num) + ".log")
                print("Saving the log to " + str(logpath))
                with open(logpath, 'w') as logfp:
                    logfp.write(logs)

    def build(self, zipfiles=True):

        job_info = self.getInfo()
        if (len(job_info['builds']) > JenkinsJob.MAX_SUBMISSION):
            print(
                f"You have already made {len(job_info['builds'])} submissions (max is {JenkinsJob.MAX_SUBMISSION}), future submissions will be not be part of your grade!")

        submission_path = self.makeSubmissionDir()
        root_path = os.getcwd()

        os.chdir(submission_path)

        source_file = [root_path / Path(f) for f in self.files]
        
        files = {}
        if zipfiles:
            print("Creating submission archive")
            with ZipFile("archive.zip", 'w') as zfp:
                for fpath in self.files:
                    # print("copying " + str(fpath) + " to " + str(submission_path / fpath.name))
                    if fpath.is_file():
                        shutil.copy(Path(fpath), submission_path)
                        print("Adding " + fpath.name)
                        zfp.write(fpath.name)
                    else:
                        raiseError("can not find " + fpath.name)

                zfp.close()

            os.chdir(root_path)

            archive = submission_path / Path("archive.zip")
            files = {
                'submission.zip': (str(archive), open(str(archive), 'rb')),
            }
        else:
            for fpath in source_file:
                if fpath.is_file():
                    print("Adding " + fpath.name)
                    files[fpath.name] = (str(fpath), open(fpath, 'rb'))
                else:
                    raiseError("can not find " + fpath.name + ", make sure the file is placed in the vhdl directory")

        build_address = JenkinsJob.DEFAULT_SERVER + self.name + "/buildWithParameters"

        job_build_req = requests.post(
            build_address,
            auth=self.auth,
            files=files
        )

        if (job_build_req.status_code != JenkinsJob.HTTPS_CREATED):
            raiseError(
                f"Could not issue build request! error {JenkinsJob.humanReadableError(job_build_req.status_code)}")
        else:
            print("Successfully sent build request, you can check the results later")


