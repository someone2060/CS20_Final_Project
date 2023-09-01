/*** MISC. FUNCTIONS
 * Includes functions that are used univerally, but don't fit in a specific category. They include:
 *   - signum (does the same as Math.signum in Java)
 *   - modulo (a modulo function that uses floored division instead of truncated division)
 *   - xor (an xor gate)
 *   - xnor (an xnor gate)
 *   - getSlice (gets a specified indice of an array; same as getSlice() in Arrays import) */

/* Returns a number based on the sign of the inputted float.
 * Original java method can be learned about here: https://www.javatpoint.com/java-math-signum-method */
static int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
}

/* Same function as using the '%' operator, but uses floored division instead of truncated division.
 * See https://en.wikipedia.org/wiki/Modulo_operation#Variants_of_the_definition */
float modulo(float a, float n) {
  return a - n*floor(a/n);
}

/* Has the same functionality as an electrical XOR gate. */
static boolean xor(boolean a, boolean b) {
  return !(a && b) &&
          (a || b);
}

/* Has the same functionality as an electrical XNOR gate. */
static boolean xnor(boolean a, boolean b) {
  return (a && b) ||
        !(a || b);
}

/* Gets a specified indice of an array.
 * This has the same function as getSlice() in the Arrays import. You can learn more about it here: https://www.javatpoint.com/array-slicing-in-java */
static PVector[] getSlice(PVector[] array, int startIndex, int endIndex) {
  PVector[] out = new PVector[endIndex-startIndex];
  for (int i=0; i<out.length; i++) {
    out[i] = array[startIndex+i];
  }
  return out;
}
// overloaded getSlice()
static ArrayList<PVector> getSlice (ArrayList<PVector> array, int startIndex, int endIndex) {
  ArrayList<PVector> out = new ArrayList<PVector>();
  for (int i=0; i<endIndex-startIndex; i++) {
    out.add(array.get(startIndex+i) );
  }
  return out;
}
// overloaded getSlice()
static StringList getSlice (StringList array, int startIndex, int endIndex) {
  StringList out = new StringList();
  for (int i=0; i<endIndex-startIndex; i++) {
    out.append(array.get(startIndex+i) );
  }
  return out;
}