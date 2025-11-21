package enterprise.git

import future.keywords

# Positive test: valid commit should be allowed

test_valid_commit if {
  test_input := {"commits": [{"sha": "abc123", "message": "feat(payment): add apple pay support", "changed_files": ["services/payment-gateway/payment.go"]}]}
  allow with input as test_input
}

# Negative test: WIP commit should be denied

test_invalid_commit_wip if {
  test_input := {"commits": [{"sha": "def456", "message": "WIP: some stuff", "changed_files": ["services/payment-gateway/payment.go"]}]}
  not allow with input as test_input
}
