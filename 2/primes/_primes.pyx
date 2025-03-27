def primes(int nb_primes):
    cdef int n, i, len_p
    cdef int[10000] p
    if nb_primes > 10000:
        raise ValueError(nb_primes)
    len_p = 0
    n = 2
    while len_p < nb_primes:
        for i in p[:len_p]:
            if n % i == 0:
                break
        else:
            p[len_p] = n
            len_p += 1
        n += 1
    result_as_list = [prime for prime in p[:len_p]]
    return result_as_list
