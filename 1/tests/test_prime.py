from primes import first_n, first_n_fast


def test_first_n() -> None:
    assert first_n(5) == [2, 3, 5, 7, 11]


def test_first_n_fast() -> None:
    assert first_n_fast(5) == [2, 3, 5, 7, 11]
