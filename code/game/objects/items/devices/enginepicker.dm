/*
//////////
	Item meant to spawn one of the three (Tesla / Singularity / Supermatter) engines on-station at round-start.
	Should be found in the CE's office. Not access-restricted.
//////////
*/

/obj/item/enginepicker
	name = "Bluespace Engine Delivery Device"
	desc = "With all of the innovations in power-generating science, Nanotrasen has decided to invent a per-station bluespace-based delivery system for a unique engine of the Chief Engineer's choice. Only one choice can be made. Device self-destructs on use."
	icon = 'icons/obj/device.dmi'
	icon_state = "enginepicker"

	var/list/list_enginebeacons = list()

/obj/item/enginepicker/attack_self(mob/living/carbon/user)
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	locatebeacons()
	var/default = null
	var/E = input("Select the station's Engine:", "[src]", default) as null|anything in list_enginebeacons
	if(E)
		processchoice(E, user)

//This proc finds all of the '/obj/item/radio/beacon/engine' in the world and assigns them to a list
/obj/item/enginepicker/proc/locatebeacons()
	LAZYCLEARLIST(list_enginebeacons)
	for(var/obj/item/radio/beacon/engine/B in world)
		if(B && !QDELETED(B))
			list_enginebeacons += B

//Spawns and logs / announces the appropriate engine based on the choice made
/obj/item/enginepicker/proc/processchoice(var/obj/item/radio/beacon/engine/choice, mob/living/carbon/user)
	var/issuccessful = FALSE
	var/engname
	var/G
	var/turf/T = get_turf(choice)
	if(choice.enginetype.len > 1)	//If the beacon has multiple engine types
		var/default = null
		var/E = input("You have selected a combined beacon, which option would you prefer?", "[src]", default) as null|anything in choice.enginetype
		if(E)
			engname = E
			issuccessful = TRUE
		else
			return
	if(!engname)
		engname = DEFAULTPICK(choice.enginetype, null)	//This should(?) account for a possibly scrambled list with a single entry
	switch(engname)
		if("Tesla")
			G = /obj/machinery/the_singularitygen/tesla
			issuccessful = TRUE
		if("Singularity")
			G = /obj/machinery/the_singularitygen
			issuccessful = TRUE

	if(issuccessful)
		clearturf(T) 	//qdels all items / gibs all mobs on the turf. Let's not have an SM shard spawn on top of a poor sod.
		new G(T)		//Spawns the switch-selected engine on the chosen beacon's turf

		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in GLOB.living_mob_list)
			ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			announcer.say(";Engine delivery detected. Type: " + engname + ".")	//Let's announce the terrible choice to everyone

		visible_message("<span class='notice'>\The [src] begins to violently vibrate and hiss, then promptly disintegrates!</span>")
		qdel(src)	//Self-destructs to prevent crew from spawning multiple engines.
	else
		visible_message("<span class='notice'>\The [src] buzzes! No beacon found or selected!</span>")
		return

//Deletes objects and mobs from the beacon's turf.
/obj/item/enginepicker/proc/clearturf(var/turf/T)
	for(var/obj/item/I in T)
		I.visible_message("\The [I] gets crushed to dust!")
		qdel(I)
	for(var/mob/living/M in T)
		M.visible_message("\The [M] gets obliterated!")
		M.gib()