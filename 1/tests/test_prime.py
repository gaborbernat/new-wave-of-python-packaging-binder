from primes import first_n


def test_first_n() -> None:
    assert first_n(5) == [2, 3, 5, 7, 11]
