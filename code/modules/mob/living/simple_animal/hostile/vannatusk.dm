/mob/living/simple_animal/hostile/vannatusk
	name = "vannatusk"
	desc = "A monstrous interdimensional invader. Its body is protected by a chitin carapace."
	icon = 'icons/mob/npc/vannatusk.dmi'
	icon_state = "vannatusk"
	icon_living = "vannatusk"
	icon_dead = "vannatusk_dead"

	mob_swap_flags = HUMAN|SIMPLE_ANIMAL|SLIME|MONKEY
	mob_push_flags = ALLMOBS

	tameable = FALSE

	organ_names = list("chest", "lower body", "left arm", "right arm", "left leg", "right leg", "head")
	response_help  = "pets"
	response_disarm = "shoves"
	response_harm   = "harmlessly punches"
	maxHealth = 350
	health = 350
	harm_intent_damage = 5
	melee_damage_lower = 30
	melee_damage_upper = 30
	armor_penetration = 15
	resist_mod = 3
	mob_size = 15
	environment_smash = 2
	attacktext = "mangled"
	attack_emote = "charges toward"
	attack_sound = 'sound/effects/creatures/vannatusk_attack.ogg'
	emote_sounds = list('sound/effects/creatures/vannatusk_sound.ogg', 'sound/effects/creatures/vannatusk_sound_2.ogg')

	minbodytemp = 0
	maxbodytemp = 350
	min_oxy = 0
	max_co2 = 0
	max_tox = 0

	blood_type = "#001126"

	speed = 3

	meat_type = /obj/item/reagent_containers/food/snacks/meat/vannatusk

	var/crystal_harvested = FALSE

	psi_pingable = FALSE

/mob/living/simple_animal/hostile/vannatusk/Initialize()
	. = ..()
	set_light(1.2, 3, LIGHT_COLOR_BLUE)

/mob/living/simple_animal/hostile/vannatusk/death()
	..(null, "collapses!")
	flick("vannatusk_death_animation", src)

/mob/living/simple_animal/hostile/vannatusk/FoundTarget()
	if(last_found_target)
		custom_emote(VISIBLE_MESSAGE,"stares alertly at [last_found_target]")
		if(!Adjacent(last_found_target))
			fire_spike(last_found_target)

/mob/living/simple_animal/hostile/vannatusk/proc/fire_spike(var/atom/target)
	visible_message(SPAN_DANGER("\The [src] fires a spike at [target]!"))
	fire_projectile(/obj/projectile/bonedart, target, 'sound/weapons/bloodyslice.ogg', firer = src)

/obj/item/bone_dart/vannatusk
	name = "bone dart"
	desc = "A sharp piece of bone shaped into a small dart."
	icon = 'icons/mob/npc/vannatusk.dmi'
	icon_state = "bonedart"

/mob/living/simple_animal/hostile/vannatusk/attackby(obj/item/attacking_item, mob/user)
	if(stat != DEAD)
		return ..()
	if(istype(attacking_item, /obj/item/surgery/scalpel))
		if(crystal_harvested)
			to_chat(user, SPAN_WARNING("\The [src]'s crystal has already been harvested!"))
			return

		visible_message(SPAN_NOTICE("[user] recovers a bluespace crystal from [src]'s remains!"))
		var/obj/item/bluespace_crystal/C = new(get_turf(src))
		user.put_in_any_hand_if_possible(C)
		crystal_harvested = TRUE
		return

	return..()

/mob/living/simple_animal/hostile/vannatusk/dead/Initialize()
	. = ..()
	death()

/obj/machinery/vannatusk_spawner
	name = "telepad"
	desc = "A bluespace telepad used for creating bluespace portals."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = TRUE
	use_power = POWER_USE_IDLE

/obj/machinery/vannatusk_spawner/power_change()
	..()
	spark(src, 3, GLOB.alldirs)
	new /mob/living/simple_animal/hostile/vannatusk(get_turf(src))
	qdel(src)
