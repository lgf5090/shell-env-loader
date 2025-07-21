# Test Escape Logic
print "Testing escape logic..."

let expected = '{"debug": true, "port": 3000}'
let actual = '"{\"debug\": true, \"port\": 3000}"'

print $"Expected: ($expected)"
print $"Actual: ($actual)"

# Remove quotes
let normalized_actual = if ($actual | str starts-with '"') and ($actual | str ends-with '"') {
    $actual | str substring 1..(-2)
} else if ($actual | str starts-with '"') {
    $actual | str substring 1..
} else {
    $actual
}

print $"Normalized: ($normalized_actual)"

# Unescape - fix the pattern
let unescaped_actual = $normalized_actual
    | str replace --all '\"' '"'
    | str replace --all '\\' '\'

print $"Unescaped: ($unescaped_actual)"

# Escape expected
let escaped_expected = $expected 
    | str replace --all '"' '\\"'
    | str replace --all '\\' '\\\\'

print $"Escaped expected: ($escaped_expected)"

print ""
print "Comparisons:"
print $"expected == normalized_actual: ($expected == $normalized_actual)"
print $"expected == unescaped_actual: ($expected == $unescaped_actual)"
print $"escaped_expected == normalized_actual: ($escaped_expected == $normalized_actual)"
