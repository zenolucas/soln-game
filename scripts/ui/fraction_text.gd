class_name FractionText
extends RefCounted
## Text forms of a fraction problem, matching the teacher portal's in-game preview
## ("What is 1/4 + 1/6?").

## PixelOperator8 has no U+2212 minus sign, so subtraction shows the ASCII hyphen.
const MINUS := "-"

static func op_symbol(op: String) -> String:
	if op == "-" or op == "−":
		return MINUS
	return op

static func fraction(numerator, denominator) -> String:
	return "%s/%s" % [numerator, denominator]

static func prompt(n1, d1, op: String, n2, d2) -> String:
	return "What is %s %s %s?" % [fraction(n1, d1), op_symbol(op), fraction(n2, d2)]
