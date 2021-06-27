/datum/event/grid_check	//NOTE: Times are measured in master controller ticks!
	announceWhen		= 5

/datum/event/grid_check/setup()
	endWhen = rand(30, 120)

/datum/event/grid_check/start()
	power_failure()

/datum/event/grid_check/announce()
	return

/datum/event/grid_check/end()
	if(power_fail_event)
		power_restore()


var/power_fail_event = FALSE
/proc/power_failure()
	if(power_fail_event)
		return
	power_fail_event = TRUE

	var/datum/announcement/centcomm/grid_off/announcement = new
	announcement.play()
	if(prob(25))
		addtimer(CALLBACK(GLOBAL_PROC, .proc/play_ambience), 600)

	var/list/skipped_areas = list(/area/station/aisat/ai_chamber, /area/station/tcommsat/computer, /area/station/tcommsat/chamber)

	for(var/obj/machinery/power/smes/S in smes_list)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas || !is_station_level(S.z))
			continue
		S.charge = 0
		S.power_failure = TRUE
		S.power_change()

	for(var/obj/machinery/power/apc/C in apc_list)
		if(C.cell && is_station_level(C.z))
			C.cell.charge = 0

/proc/play_ambience()
	for(var/mob/M in player_list)
		M.playsound_music('sound/ambience/specific/hullcreak.ogg', VOL_AMBIENT, null, null, CHANNEL_AMBIENT_LOOP)

/proc/power_restore(badminery = 0)
	power_fail_event = FALSE
	var/list/skipped_areas = list(/area/station/aisat/ai_chamber, /area/station/tcommsat/computer, /area/station/tcommsat/chamber)

	var/datum/announcement/centcomm/grid_on/announcement = new
	announcement.play()

	if(badminery)
		for(var/obj/machinery/power/apc/C in apc_list)
			if(C.cell && is_station_level(C.z))
				C.cell.charge = C.cell.maxcharge

	for(var/obj/machinery/power/smes/S in smes_list)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas || !is_station_level(S.z))
			continue
		if(badminery)
			S.charge = S.capacity
		S.power_failure = FALSE
		S.power_change()

//This one can be called only by admin.
/proc/power_restore_quick(announce = 1)
	if(announce)
		var/datum/announcement/centcomm/grid_on/announcement = new
		announcement.play()

	for(var/obj/machinery/power/smes/S in smes_list)
		if(!is_station_level(S.z))
			continue
		S.RefreshParts()
		S.charge = S.capacity
		S.input_attempt = TRUE
		S.output_attempt = TRUE
		S.input_level = S.input_level_max
		S.output_level = S.output_level_max
		S.power_failure = FALSE
		S.power_change()
