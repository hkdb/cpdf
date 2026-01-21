#!/usr/bin/env python3

"""
cpdf build script using Nuitka
Compiles cpdf into a single standalone binary
"""

from argparse import ArgumentParser
from logging import getLogger, StreamHandler
from os.path import dirname, exists, join
from platform import python_compiler, system
from shlex import split
from shutil import rmtree, copy2, which
from subprocess import CalledProcessError, PIPE, Popen
from sys import exit, stdout
from typing import Iterator
from venv import create

# Python executable path
if python_compiler()[:3] == "MSC":
    PYEXE = join("Scripts", "python")
else:
    PYEXE = join("bin", "python3")


def run_command(cmd: str) -> Iterator[str]:
    """Generator function yielding command outputs"""
    command = split(cmd)
    process = Popen(command, stdout=PIPE, stderr=PIPE, shell=False, text=True)
    for line in iter(process.stdout.readline, ""):
        yield line
    process.stdout.close()
    return_code = process.wait()
    if return_code:
        # Get stderr for error message
        stderr = process.stderr.read()
        raise CalledProcessError(return_code, cmd, stderr=stderr)


# Logger
logger = getLogger("Builder")
logger.setLevel("INFO")
hdlr = StreamHandler(stdout)
logger.addHandler(hdlr)


class Build:
    """Build class for cpdf"""

    def __init__(self) -> None:
        parser = self._set_up_parser()
        self.args = parser.parse_args()
        self.logger = logger
        self.logger.setLevel(self.args.LOG)
        self.srcdir = dirname(__file__) or "."

    def _set_up_parser(self) -> ArgumentParser:
        parser = ArgumentParser(
            prog="build.py",
            description="Build cpdf into a standalone binary using Nuitka"
        )
        parser.add_argument(
            "--log",
            action="store",
            help="Set the log level",
            dest="LOG",
            choices=("DEBUG", "INFO", "WARNING", "ERROR"),
            default="INFO"
        )
        parser.add_argument(
            "--no-clean",
            action="store_true",
            help="Do not clean build artifacts",
            dest="NO_CLEAN",
            default=False
        )
        parser.add_argument(
            "-o", "--outdir",
            action="store",
            help="Path to output directory",
            dest="OUTDIR",
            default="dist"
        )
        return parser

    def _run_command(self, cmd: str) -> str:
        self.logger.debug(f"Command: {cmd}")
        output = ""
        for line in run_command(cmd):
            output += line
            self.logger.info(line.rstrip())
        return output.rstrip()

    def _set_up_venv(self) -> int:
        venv = join(self.srcdir, "venv")
        self.logger.info(f"Setting up virtual environment: {venv}")
        self.py = join(venv, PYEXE)
        create(
            venv,
            system_site_packages=False,
            clear=True,
            with_pip=True,
            upgrade_deps=True
        )

        # Install build dependencies
        self.logger.info("Installing Nuitka...")
        self._run_command(f"{self.py} -m pip install nuitka")

        # Install runtime dependencies
        requirements = join(self.srcdir, "requirements.txt")
        if exists(requirements):
            self.logger.info("Installing dependencies from requirements.txt...")
            self._run_command(f"{self.py} -m pip install -r {requirements}")

        self.logger.info("Virtual environment ready")
        return 0

    def _build(self) -> int:
        self.logger.info("Building cpdf with Nuitka...")

        # Create output directory
        outdir = join(self.srcdir, self.args.OUTDIR)
        if not exists(outdir):
            from os import makedirs
            makedirs(outdir)

        # Build with Nuitka
        cpdf_src = join(self.srcdir, "cpdf")
        cmd = (
            f"{self.py} -m nuitka "
            f"--onefile "
            f"--output-dir={outdir} "
            f"--output-filename=cpdf "
            f"--assume-yes-for-downloads "
            f"{cpdf_src}"
        )
        self._run_command(cmd)

        self.logger.info(f"Build complete: {join(outdir, 'cpdf')}")
        return 0

    def _clean(self) -> int:
        self.logger.info("Cleaning build artifacts...")

        # Remove venv
        venv = join(self.srcdir, "venv")
        if exists(venv):
            rmtree(venv)
            self.logger.debug("Removed venv")

        # Remove Nuitka build directory
        build_dir = join(self.srcdir, self.args.OUTDIR, "cpdf.build")
        if exists(build_dir):
            rmtree(build_dir)
            self.logger.debug("Removed cpdf.build")

        onefile_dir = join(self.srcdir, self.args.OUTDIR, "cpdf.onefile-build")
        if exists(onefile_dir):
            rmtree(onefile_dir)
            self.logger.debug("Removed cpdf.onefile-build")

        self.logger.info("Clean complete")
        return 0

    def _check_dependencies(self) -> int:
        """Check for required build dependencies"""
        if system() == "Linux":
            if not which("patchelf"):
                self.logger.error(
                    "patchelf is required for building on Linux.\n"
                    "Install it with: apt/dnf/pacman install patchelf"
                )
                return 1
        return 0

    def main(self) -> int:
        try:
            result = self._check_dependencies()
            if result:
                return 1

            result = self._set_up_venv()
            if result:
                return 1

            result = self._build()
            if result:
                return 1

            if not self.args.NO_CLEAN:
                result = self._clean()
                if result:
                    return 1

            self.logger.info("Build completed successfully!")
            return 0

        except CalledProcessError as e:
            self.logger.error(f"Command failed: {e.cmd}")
            if e.stderr:
                self.logger.error(e.stderr)
            return 1
        except Exception as e:
            self.logger.error(f"Build failed: {e}")
            return 1


if __name__ == "__main__":
    b = Build()
    exit(b.main())
