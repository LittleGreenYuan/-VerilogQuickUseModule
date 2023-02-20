# -VerilogQuickUseModule
A series of personal summary hardware description languages will be stored in this warehouse, making it possible to use them out of the box and simplifying the development of FPGA.

- Int2IEEE754
  Convert the positive integer stored in INT form to IEEE754 single-precision floating-point number.
  This program has a conversion speed rarely achieved by other IP cores. The worst case is the maximum number of digits+5 time cycles. Since this program was originally used to process common ADC acquisition data, it did not fully cover the verification of 32-bit positive integers.
