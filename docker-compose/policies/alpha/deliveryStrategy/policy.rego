package alpha.deliveryStrategy

default strategy := ["tunnel","smime","seal"]

strategy := ["tunnel", "smime", "smtp"] if {
    subject := lower(input.subject)
    k := data.keywords[_]
    contains(subject, lower(k))
}

