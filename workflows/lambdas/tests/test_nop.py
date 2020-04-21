from lambdas.nop import _nop, _cma_output


def test_nop():
    expected = None

    actual = _nop()

    assert expected == actual


def test_cma_output():
    expected = {"NOP": None}

    actual = _cma_output(None)

    assert expected == actual
