package outbound.delivery_strategy

default strategy := "seal"

strategy := "seal" if {
	input.channel == "smtp"
}

strategy := "smtp" if {
	input.channel == "json"
}

