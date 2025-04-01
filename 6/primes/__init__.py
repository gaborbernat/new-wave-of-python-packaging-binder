from __future__ import annotations

import sys

from ._lib import first_n as first_n_fast


def first_n(count: int) -> list[int]:
    primes: list[int] = []
    at = 2
    while len(primes) < count:
        for divisor in primes:
            if at % divisor == 0:
                break
        else:
            primes.append(at)
        at += 1
    return primes


def run() -> None:
    print(first_n(int(sys.argv[1])))


def run_fast() -> None:
    print(first_n_fast(int(sys.argv[1])))


__all__ = ["first_n", "first_n_fast", "run", "run_fast"]
