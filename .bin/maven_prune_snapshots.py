#!/usr/bin/env python3
import os
import multiprocessing
import re
import collections
import datetime


REPOSITORY_HOME = os.path.join(
    os.getenv("HOME"),
    ".m2",
    "repository"
)

NUM_THREADS = 4


def main():
    start = datetime.datetime.now()
    all_removed_files = 0
    with multiprocessing.Pool(NUM_THREADS) as p:
        for deleted_files in p.imap_unordered(prune_directory, snapshot_dirs()):
            all_removed_files += deleted_files
    print(f"Deleted {all_removed_files} files in {datetime.datetime.now() - start}.")


def prune_directory(args):
    directory_name, fnames = args
    files_by_dt = collections.defaultdict(list)

    for fname in fnames:
        m = re.search(r"-(\d{8}\.\d{6}-\d*).*", fname)
        if m:
            files_by_dt[m.group(1)].append(fname)

    deleted_files = 0
    for key in sorted(files_by_dt)[:-1]:
        for fname in files_by_dt[key]:
            os.unlink(os.path.join(directory_name, fname))
            deleted_files += 1
    return deleted_files


def snapshot_dirs():
    for root, dirs, fnames in os.walk(REPOSITORY_HOME):
        if root.endswith("-SNAPSHOT") and fnames:
            yield root, fnames


if __name__ == '__main__':
    main()
