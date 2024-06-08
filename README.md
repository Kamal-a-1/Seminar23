Selection algorithm for SCL decoding in VHDL and C++.

The algorithm is described in this paper: https://ieeexplore.ieee.org/document/7867834

Generic variables:

    - L: the number of metrics to be selected.
    - M: the number of bits in binary representation.

Inputs:

    - enable: should be on for one cycle to indicate a new input.
    - metrics: 2*L x M matrix containing all the metrics in binary representation.
    - reset: to reset the internal signals and outputs.

Outputs:

    - F: the output indicating the smaller metrics with 1.
    - ready: indicating whether F is ready or not.
