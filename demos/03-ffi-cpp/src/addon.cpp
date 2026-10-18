#include <napi.h>

#include <cstdint>
#include <vector>

namespace {

// Sieve of Eratosthenes. The comparison with the PureScript version in
// src/Main.purs shows the cost of an FFI call plus native execution versus
// interpreted JavaScript.
int64_t CountPrimes(int64_t limit) {
  if (limit < 2) {
    return 0;
  }
  std::vector<bool> sieve(static_cast<std::size_t>(limit + 1), true);
  sieve[0] = false;
  sieve[1] = false;
  for (int64_t candidate = 2; candidate * candidate <= limit; ++candidate) {
    if (sieve[static_cast<std::size_t>(candidate)]) {
      for (int64_t multiple = candidate * candidate; multiple <= limit;
           multiple += candidate) {
        sieve[static_cast<std::size_t>(multiple)] = false;
      }
    }
  }
  int64_t count = 0;
  for (bool is_prime : sieve) {
    if (is_prime) {
      ++count;
    }
  }
  return count;
}

Napi::Value CountPrimesWrapped(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  if (info.Length() < 1 || !info[0].IsNumber()) {
    Napi::TypeError::New(env, "expected a numeric limit").ThrowAsJavaScriptException();
    return env.Null();
  }
  const int64_t limit = info[0].As<Napi::Number>().Int64Value();
  return Napi::Number::New(env, static_cast<double>(CountPrimes(limit)));
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set("countPrimes", Napi::Function::New(env, CountPrimesWrapped));
  return exports;
}

}  // namespace

NODE_API_MODULE(psdev_ffi, Init)
