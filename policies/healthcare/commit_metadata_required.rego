package healthcare.metadata

# Commit Metadata Requirements Policy
# Ensures all healthcare commits have required compliance metadata

default allow = false

# Allow commits with complete metadata
allow if {
    input.commit
    has_required_metadata(input.commit)
    valid_metadata_format(input.commit)
}

# Required metadata validation
has_required_metadata(commit) if {
    # All commits need basic metadata
    has_business_impact(commit)
    has_risk_level(commit)
    has_clinical_safety(commit)
    has_reviewers(commit)
    has_audit_trail(commit)
    
    # Domain-specific metadata
    has_domain_metadata(commit)
}

# Basic metadata checks
has_business_impact(commit) if {
    contains(commit.message, "Business Impact:")
}

has_risk_level(commit) if {
    contains(commit.message, "Risk Level:")
    risk_levels := ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
    some level in risk_levels
    contains(commit.message, level)
}

has_clinical_safety(commit) if {
    contains(commit.message, "Clinical Safety:")
    safety_levels := ["REQUIRES_CLINICAL_REVIEW", "NO_CLINICAL_IMPACT"]
    some level in safety_levels
    contains(commit.message, level)
}

has_reviewers(commit) if {
    contains(commit.message, "Reviewers:")
    # Must have at least one reviewer
    reviewers_line := extract_reviewers_line(commit.message)
    contains(reviewers_line, "@")
}

has_audit_trail(commit) if {
    contains(commit.message, "Audit Trail:")
    contains(commit.message, "files modified")
}

# Domain-specific metadata requirements
has_domain_metadata(commit) if {
    # If PHI-related, needs HIPAA metadata
    not phi_related(commit)
}

has_domain_metadata(commit) if {
    phi_related(commit)
    has_hipaa_metadata(commit)
}

has_domain_metadata(commit) if {
    # If medical device, needs FDA metadata
    not medical_device_related(commit) 
}

has_domain_metadata(commit) if {
    medical_device_related(commit)
    has_fda_metadata(commit)
}

has_domain_metadata(commit) if {
    # If financial, needs SOX metadata
    not financial_related(commit)
}

has_domain_metadata(commit) if {
    financial_related(commit) 
    has_sox_metadata(commit)
}

# HIPAA metadata requirements
has_hipaa_metadata(commit) if {
    contains(commit.message, "HIPAA Compliance:")
    contains(commit.message, "PHI-Impact:")
    contains(commit.message, "Audit-Trail:")
    contains(commit.message, "Encryption-Status:")
}

# FDA metadata requirements  
has_fda_metadata(commit) if {
    contains(commit.message, "FDA Compliance:")
    contains(commit.message, "FDA-510k:")
    contains(commit.message, "Clinical-Safety:")
    contains(commit.message, "Patient-Impact:")
}

# SOX metadata requirements
has_sox_metadata(commit) if {
    contains(commit.message, "SOX Compliance:")
    contains(commit.message, "SOX-Control:")
    contains(commit.message, "Financial-Impact:")
    contains(commit.message, "Audit-Evidence:")
}

# Domain detection
phi_related(commit) if {
    phi_keywords := ["phi", "patient", "medical", "health"]
    some keyword in phi_keywords
    contains(lower(commit.message), keyword)
}

medical_device_related(commit) if {
    device_keywords := ["diagnostic", "therapeutic", "clinical", "device", "algorithm"]
    some keyword in device_keywords
    contains(lower(commit.message), keyword)
}

financial_related(commit) if {
    financial_keywords := ["payment", "billing", "financial", "invoice", "transaction"]
    some keyword in financial_keywords
    contains(lower(commit.message), keyword)
}

# Metadata format validation
valid_metadata_format(commit) if {
    # Risk level must be valid
    valid_risk_level(commit)
    # Clinical safety must be valid
    valid_clinical_safety(commit)
    # Compliance domains must be valid
    valid_compliance_domains(commit)
}

valid_risk_level(commit) if {
    risk_line := extract_risk_level_line(commit.message)
    valid_levels := ["CRITICAL", "HIGH", "MEDIUM", "LOW"] 
    some level in valid_levels
    contains(risk_line, level)
}

valid_clinical_safety(commit) if {
    safety_line := extract_clinical_safety_line(commit.message)
    valid_assessments := ["REQUIRES_CLINICAL_REVIEW", "NO_CLINICAL_IMPACT"]
    some assessment in valid_assessments
    contains(safety_line, assessment)
}

valid_compliance_domains(commit) if {
    # If compliance is specified, must be valid frameworks
    not contains(commit.message, "Compliance:")
}

valid_compliance_domains(commit) if {
    compliance_line := extract_compliance_line(commit.message)
    valid_frameworks := ["HIPAA", "FDA", "SOX", "HITECH", "GDPR", "PCI-DSS"]
    # At least one valid framework must be mentioned
    some framework in valid_frameworks
    contains(compliance_line, framework)
}

# Helper extraction functions
extract_reviewers_line(message) := line if {
    lines := split(message, "\n")
    reviewer_lines := [l | l := lines[_]; startswith(l, "Reviewers:")]
    count(reviewer_lines) > 0
    line := reviewer_lines[0]
}

extract_risk_level_line(message) := line if {
    lines := split(message, "\n")
    risk_lines := [l | l := lines[_]; startswith(l, "Risk Level:")]
    count(risk_lines) > 0
    line := risk_lines[0]
}

extract_clinical_safety_line(message) := line if {
    lines := split(message, "\n")
    safety_lines := [l | l := lines[_]; startswith(l, "Clinical Safety:")]
    count(safety_lines) > 0
    line := safety_lines[0]
}

extract_compliance_line(message) := line if {
    lines := split(message, "\n")
    compliance_lines := [l | l := lines[_]; startswith(l, "Compliance:")]
    count(compliance_lines) > 0
    line := compliance_lines[0]
}

# Comprehensive deny rules
deny contains msg if {
    input.commit
    not has_business_impact(input.commit)
    msg := sprintf("Commit %s missing required 'Business Impact:' metadata", [input.commit.sha])
}

deny contains msg if {
    input.commit
    not has_risk_level(input.commit)
    msg := sprintf("Commit %s missing required 'Risk Level:' metadata", [input.commit.sha])
}

deny contains msg if {
    input.commit
    not has_clinical_safety(input.commit)
    msg := sprintf("Commit %s missing required 'Clinical Safety:' metadata", [input.commit.sha])
}

deny contains msg if {
    input.commit
    phi_related(input.commit)
    not has_hipaa_metadata(input.commit)
    msg := sprintf("PHI-related commit %s missing required HIPAA metadata", [input.commit.sha])
}

deny contains msg if {
    input.commit
    medical_device_related(input.commit)
    not has_fda_metadata(input.commit)
    msg := sprintf("Medical device commit %s missing required FDA metadata", [input.commit.sha])
}

deny contains msg if {
    input.commit
    financial_related(input.commit)
    not has_sox_metadata(input.commit)
    msg := sprintf("Financial commit %s missing required SOX metadata", [input.commit.sha])
}
