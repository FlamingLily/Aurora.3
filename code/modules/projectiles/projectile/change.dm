/obj/projectile/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = DAMAGE_BURN
	check_armor = ENERGY

/obj/projectile/change/on_hit(atom/target, blocked, def_zone)
	. = ..()
	wabbajack(target)

/obj/projectile/change/proc/wabbajack(var/mob/M)
	if(istype(M, /mob/living) && M.stat != DEAD)
		if(M.transforming)
			return
		if(M.has_brain_worms())
			return //Borer stuff - RR

		if(istype(M, /mob/living/carbon/human/apparition))
			visible_message("<span class='caution'>\The [src] doesn't seem to affect [M] in any way.</span>")
			return

		if(istype(M, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/Robot = M
			if(Robot.mmi)
				qdel(Robot.mmi)
		else
			for(var/obj/item/W in M)
				if(istype(W, /obj/item/implant))	//TODO: Carn. give implants a dropped() or something
					qdel(W)
					continue
				M.drop_from_inventory(W)

		var/mob/living/new_mob

		var/options = list("robot", "slime")
		for(var/t in GLOB.all_species)
			options += t
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species)
				options -= H.species.name
		else if(isrobot(M))
			options -= "robot"
		else if(isslime(M))
			options -= "slime"

		var/randomize = pick(options)
		switch(randomize)
			if("robot")
				new_mob = new /mob/living/silicon/robot(M.loc)
				new_mob.gender = M.gender
				new_mob.set_invisibility(0)
				new_mob.job = "Cyborg"
				var/mob/living/silicon/robot/Robot = new_mob
				Robot.mmi = new /obj/item/device/mmi(new_mob)
				Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
			if("slime")
				new_mob = new /mob/living/carbon/slime(M.loc)
				new_mob.universal_speak = 1
			else
				var/mob/living/carbon/human/H
				if(ishuman(M))
					H = M
				else
					new_mob = new /mob/living/carbon/human(M.loc)
					H = new_mob

				if(M.gender == MALE)
					H.gender = MALE
					H.name = pick(GLOB.first_names_male)
				else
					H.gender = FEMALE
					H.name = pick(GLOB.first_names_female)
				H.name += " [pick(GLOB.last_names)]"
				H.real_name = H.name

				INVOKE_ASYNC(H, TYPE_PROC_REF(/mob/living/carbon/human, set_species), randomize)
				H.universal_speak = 1

		if(new_mob)
			for (var/spell/S in M.spell_list)
				new_mob.add_spell(new S.type)

			new_mob.set_intent(I_HURT)
			if(M.mind)
				M.mind.transfer_to(new_mob)
			else
				new_mob.key = M.key

			to_chat(new_mob, SPAN_WARNING("Your form morphs into that of \a [lowertext(randomize)]."))

			qdel(M)
			return
		else
			to_chat(M, SPAN_WARNING("Your form morphs into that of \a [lowertext(randomize)]."))
			return
