/datum/keybinding
	var/list/hotkey_keys
	var/name
	var/full_name
	var/description = ""
	var/category = CATEGORY_MISC
	var/weight = WEIGHT_LOWEST

/datum/keybinding/proc/down(client/user)
	return FALSE

/datum/keybinding/proc/up(client/user)
	return FALSE

/datum/keybinding/proc/can_use(client/user)
	return TRUE
