#!/usr/bin/env python3
"""
SLURM job status checker for Snakemake.
Checks the status of a SLURM job and returns running/success/failed.
"""

import subprocess
import sys


def get_job_status(jobid):
    """Query SLURM for job status"""
    try:
        result = subprocess.run(
            ['sacct', '-j', jobid, '--format=State', '--noheader', '-P'],
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode != 0:
            # Job not found in sacct, try squeue
            result = subprocess.run(
                ['squeue', '-j', jobid, '-h', '-o', '%t'],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode != 0 or not result.stdout.strip():
                # Job not in queue, assume completed
                return 'success'

            state = result.stdout.strip().split('\n')[0]
        else:
            # Get the first non-empty state
            states = [s.strip() for s in result.stdout.strip().split('\n') if s.strip()]
            if not states:
                return 'running'
            state = states[0]

        # Map SLURM states to Snakemake states
        running_states = {
            'PENDING', 'PD',
            'RUNNING', 'R',
            'CONFIGURING', 'CF',
            'COMPLETING', 'CG',
            'SUSPENDED', 'S',
            'REQUEUED', 'RQ'
        }

        success_states = {
            'COMPLETED', 'CD'
        }

        failed_states = {
            'FAILED', 'F',
            'CANCELLED', 'CA',
            'DEADLINE', 'DL',
            'NODE_FAIL', 'NF',
            'OUT_OF_MEMORY', 'OOM',
            'PREEMPTED', 'PR',
            'TIMEOUT', 'TO',
            'BOOT_FAIL', 'BF'
        }

        if state in running_states:
            return 'running'
        elif state in success_states:
            return 'success'
        elif state in failed_states:
            return 'failed'
        else:
            # Unknown state, assume running
            return 'running'

    except subprocess.TimeoutExpired:
        return 'running'
    except Exception:
        return 'running'


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: slurm_status.py <jobid>", file=sys.stderr)
        sys.exit(1)

    jobid = sys.argv[1]
    status = get_job_status(jobid)
    print(status)
