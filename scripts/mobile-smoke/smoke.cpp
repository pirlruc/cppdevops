// Minimal TU for mobile matrix smoke compiles (MOBILE-MECH-001).
// Includes a standard-library header so libc++ linkage is exercised.
#include <cstdio>

int main() {
  std::puts("cppdevops mobile smoke ok");
  return 0;
}
