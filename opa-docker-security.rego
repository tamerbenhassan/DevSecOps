package main

# Do Not store secrets in ENV variables
secrets_env = [
    "passwd",
    "password",
    "pass",
    "secret",
    "key",
    "access",
    "api_key",
    "apikey",
    "token",
    "tkn"
]

deny[msg] {
    some i
    input[i].Cmd == "env"
    val := input[i].Value
    secret := secrets_env[_]
    contains(lower(val[_]), secret)
    msg = sprintf("Line %d: Potential secret in ENV key found: %s", [i, val])
}

# Do not use 'latest' tag for base images
deny[msg] {
    some i
    input[i].Cmd == "from"
    val := split(input[i].Value[0], ":")
    contains(lower(val[1]), "latest")
    msg = sprintf("Line %d: do not use 'latest' tag for base images", [i])
}

# Avoid curl bashing
deny[msg] {
    some i
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    matches := regex.find_n(`(curl|wget)[^|^>]*[|>]`, lower(val), -1)
    count(matches) > 0
    msg = sprintf("Line %d: Avoid curl bashing", [i])
}

# Do not upgrade your system packages
warn[msg] {
    some i
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    matches := regex.match(".*?(apk|yum|dnf|apt|pip).+?(install|[dist-|check-|group]?up[grade|date]).*", lower(val))
    matches == true
    msg = sprintf("Line %d: Do not upgrade your system packages: %s", [i, val])
}

# Do not use ADD if possible
deny[msg] {
    some i
    input[i].Cmd == "add"
    msg = sprintf("Line %d: Use COPY instead of ADD", [i])
}

# Any user...
any_user[i] = name {
    some i
    input[i].Cmd == "user"
    name := input[i].Value
}

# Ensure USER is specified and not running as root
deny[msg] {
    not any_user[_]  # Checks if there is no user directive at all
    msg = "Do not run as root, use USER instead"
}

# ... but do not use a forbidden user
forbidden_users = [
    "root",
    "toor",
    "0"
]

deny[msg] {
    some i
    input[i].Cmd == "user"
    user := input[i].Value
    forbidden := {x | x := forbidden_users[_]}  # Creates a set of forbidden users
    lower(user) == forbidden[_]  # Checks if the user is in the set of forbidden users
    msg = sprintf("Line %d: Last USER directive (USER %s) is forbidden", [i, user])
}

# Do not sudo
deny[msg] {
    some i
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    contains(lower(val), "sudo")
    msg = sprintf("Line %d: Do not use 'sudo' command", [i])
}

# Use multi-stage builds
multi_stage[i] {
    some i
    input[i].Cmd == "copy"
    val := concat(" ", input[i].Flags)
    contains(lower(val), "--from=")
}

deny[msg] {
    not multi_stage[_]
    msg = "You COPY, but do not appear to use multi-stage builds..."
}
