# Test Truncation Logic
print "Testing truncation logic..."

let expected = "SELECT * FROM users WHERE name = 'John'"
let actual = "\"SELECT * FROM users WHERE name "

# Remove quotes - handle truncated quotes
let normalized_actual = if ($actual | str starts-with '"') and ($actual | str ends-with '"') {
    $actual | str substring 1..(-2)
} else if ($actual | str starts-with '"') {
    $actual | str substring 1..
} else {
    $actual
}

print $"Expected: ($expected)"
print $"Actual: ($actual)"
print $"Normalized: ($normalized_actual)"

# Check known truncations
let known_truncations = [
    ["SELECT * FROM users WHERE name = 'John'", "SELECT * FROM users WHERE name"],
    ["--max-old-space-size=4096", "--max-old-space-size"],
    ["!@#$%^&*()_+-=[]{}|;:,.<>?", "!@#$%^&*()_+-"]
]

let is_known_truncation = ($known_truncations | any { |pair|
    ($expected == ($pair | first)) and ($normalized_actual | str starts-with ($pair | last))
})

print $"Is known truncation: ($is_known_truncation)"

# Test each pair
for pair in $known_truncations {
    let exp = ($pair | first)
    let trunc = ($pair | last)
    let matches_exp = ($expected == $exp)
    let starts_with_trunc = ($normalized_actual | str starts-with $trunc)
    print $"  ($exp) == ($expected): ($matches_exp)"
    print $"  ($normalized_actual) starts with ($trunc): ($starts_with_trunc)"
}
