package alpha.deliveryStrategy

default strategy := "smtp"

strategy := "smime" if {
    contains(lower(input.subject), "[confidential]")
}
