import { createRequire } from "node:module";
import { join } from "node:path";
import { performance } from "node:perf_hooks";

// The compiled addon lives outside the generated output directory, so it is
// resolved from the project root instead of from this module's location.
const require = createRequire(import.meta.url);
const addon = require(join(process.cwd(), "build", "Release", "psdev_ffi.node"));

export const countPrimesCpp = (limit) => () => addon.countPrimes(limit);

export const now = () => performance.now();
