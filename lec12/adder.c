#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

struct PairOfBits {bool bit1, bit2; };
typedef struct PairOfBits PairOfBits;

struct PairOfBytes {int8_t byte1, byte2; };
typedef struct PairOfBytes PairOfBytes;

PairOfBits full_adder(bool a, bool b, bool carry_in) {
  bool sum = a ^ b ^ carry_in;
  bool carry_out = a&b | (a|b)&carry_in;
              // = a&carry_in | a&b | b&carry_in;
  PairOfBits result = {sum, carry_out};
  return result;
}

PairOfBytes ripple_carry4(int8_t a, int8_t b, bool carry_in) {
  int8_t sum = 0;

  PairOfBits bits = full_adder(1&a, 1&b, carry_in);
  sum = sum | bits.bit1;
  
  bits = full_adder((2&a)>>1, (2&b)>>1, bits.bit2);
  sum = sum | (bits.bit1 << 1);
  
  bits = full_adder((4&a)>>2, (4&b)>>2, bits.bit2);
  sum |= bits.bit1 << 2;

  bits = full_adder((8&a)>>3, (8&b)>>3, bits.bit2);
  sum |= bits.bit1 << 3;
  
  PairOfBytes result = {sum, (int8_t) bits.bit2};
  return result;
}

int main(int argc, char* argv[]) {
  int8_t a = (int8_t) atoi(argv[1]);
  int8_t b = (int8_t) atoi(argv[2]);
  PairOfBytes output = ripple_carry4(a, b, 0);
  printf("sum = %d\n", (int) output.byte1);
  printf("carry_out = %d\n", (int) output.byte2);
  return EXIT_SUCCESS;
}
