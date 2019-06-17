/obj/structure/bed/post_buckle_mob(mob/living/M)
	. = ..()
	if(ishuman(M) && M.client)
		to_chat(M, "<span class='boldnotice'>If you log out now, your character will leave the round permanently (you'll have 2 minutes to cancel this by logging back in).</span> - <span class='warning'>you start getting ready to sleep.</span>")
	for(var/X in active_timers) //Reset their sleep logout timer.
		qdel(X)
	addtimer(CALLBACK(src, /obj/structure/bed/proc/remove_from_round, M), 2 MINUTES)

/obj/structure/bed/proc/remove_from_round(var/mob/living/user)
	if(user.client)
		return //They've logged back in. Don't delete them.
	user.visible_message("[user] drifts off into a peaceful sleep.")
	if(user.mind && user.mind.assigned_role)
		//Handle job slot/tater cleanup.
		var/job = user.mind.assigned_role

		SSjob.FreeRole(job)
		if(user.mind.special_role)
			message_admins("[user] left the round permanently as a [user.mind.special_role].")
			user.mind.special_role = null

	// Delete them from datacore.
	for(var/datum/data/record/R in GLOB.data_core.medical)
		if((R.fields["name"] == user.real_name))
			GLOB.data_core.medical -= R
			qdel(R)
	for(var/datum/data/record/T in GLOB.data_core.security)
		if((T.fields["name"] == user.real_name))
			GLOB.data_core.security -= T
			qdel(T)
	for(var/datum/data/record/G in GLOB.data_core.general)
		if((G.fields["name"] == user.real_name))
			GLOB.data_core.general -= G
			qdel(G)

	log_game("[user] went to sleep forever, and was removed from the round.")
	// Ghost and delete the mob.
	user.ghostize(0)
	GLOB.used_names += user.real_name
	qdel(user)
	user = null