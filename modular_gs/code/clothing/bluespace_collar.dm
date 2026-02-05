/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver
	name = "Bluespace collar receiver"
	desc = "A collar containing a miniaturized bluespace whitehole. Other bluespace transmitter collars can connect to this, causing the wearer to receive food from other transmitter collars directly into the stomach. "
	slot_flags = ITEM_SLOT_NECK
	var/mob/living/carbon/victim = 0

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver/Initialize(mapload)
	. = ..()
	register_item_context()
	register_context()

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver/equipped(mob/user, slot)
	. = ..()
	var/mob/living/carbon/wearer = user
	if(!iscarbon(wearer))
		return FALSE
	if(slot !=ITEM_SLOT_NECK )
		return FALSE
	if(!wearer?.client?.prefs?.read_preference(/datum/preference/toggle/weight_gain_items))
		return FALSE
	victim = user;

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver/dropped(mob/user)
	. = ..()
	var/mob/living/carbon/wearer = user
	if(!iscarbon(wearer) || !(wearer.get_item_by_slot(ITEM_SLOT_NECK) == src) || !wearer?.client?.prefs?.read_preference(/datum/preference/toggle/weight_gain_items))
		return FALSE
	victim = 0

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver/proc/isworn()
	if(istype(victim, /mob/living/carbon))
		return TRUE
	else
		return FALSE

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter))
		var/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/transmitter = tool
		transmitter.linked_receiver = src
		var/mob/living/carbon/player_user = user
		to_chat(player_user, "<span class='notice'>You link the bluespace collar with the other transmitter</span>")
	..()
	return

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	. = ..()

	if(istype(target, /obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter))
		context[SCREENTIP_CONTEXT_LMB] = "Link to transmitter"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter
	name = "Bluespace collar transmitter"
	desc = "A collar containing a miniaturized bluespace blackhole. Can be connected to a bluespace collar receiver to transmit food to a linked receiver collar. "
	slot_flags = ITEM_SLOT_NECK
	var/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver/linked_receiver = 0

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/Initialize(mapload)
	. = ..()
	register_item_context()
	register_context()

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/equipped(mob/user, slot)
	. = ..()
	var/mob/living/carbon/wearer = user
	if(!iscarbon(wearer) || slot !=ITEM_SLOT_NECK || !wearer?.client?.prefs?.read_preference(/datum/preference/toggle/weight_gain_items))
		return FALSE

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/dropped(mob/user)
	. = ..()
	var/mob/living/carbon/wearer = user
	if(!iscarbon(wearer) || !(wearer.get_item_by_slot(ITEM_SLOT_NECK) == src) || !wearer?.client?.prefs?.read_preference(/datum/preference/toggle/weight_gain_items))
		return FALSE

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver))
		var/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver/receiver= tool
		linked_receiver = receiver
		var/mob/living/carbon/player_user = user
		to_chat(player_user, "<span class='notice'>You link the bluespace collar to the other receiver</span>")
	. = ..()
	return

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/proc/islinked()
	if (linked_receiver && linked_receiver.isworn())
		return TRUE
	else
		return FALSE

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_RMB] = "Unlink"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	. = ..()

	if(istype(target, /obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_receiver))
		context[SCREENTIP_CONTEXT_LMB] = "Link to receiver"
		return CONTEXTUAL_SCREENTIP_SET

// For food
/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/proc/transpose_food(/obj/item/food/owner, mob/living/original_eater, mob/living/feeder)
	return FALSE

// For the alternative edible functionality
/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/proc/transpose_edible(datum/component/edible/foodstuff, mob/living/original_eater, mob/living/feeder)
	if (!islinked())
		return FALSE

	var/atom/owner = foodstuff.parent
	var/mob/living/carbon/human/eater = linked_receiver.victim

	if(!owner.reagents)
		stack_trace("[eater] failed to bite [owner], because [owner] had no reagents.")
		return FALSE
	if(eater.satiety > -200)
		eater.satiety -= foodstuff.junkiness
	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	if(!owner.reagents.total_volume)
		return
	var/sig_return = SEND_SIGNAL(foodstuff.parent, COMSIG_FOOD_EATEN, eater, feeder, foodstuff.bitecount, foodstuff.bite_consumption)
	if(sig_return & DESTROY_FOOD)
		qdel(owner)
		return

	//Give a buff when the dish is hand-crafted and unbitten
	if(foodstuff.bitecount == 0)
		foodstuff.apply_buff(eater)

	var/fraction = 0.3
	fraction = min(foodstuff.bite_consumption / owner.reagents.total_volume, 1)
	owner.reagents.trans_to(eater, foodstuff.bite_consumption, transferred_by = feeder, methods = INGEST)
	eater.hud_used?.hunger?.update_hunger_bar()
	foodstuff.bitecount++

	foodstuff.checkLiked(fraction, eater)

	foodstuff.check_materials(eater, fraction)

	if(!owner.reagents.total_volume)
		foodstuff.On_Consume(eater, feeder)

	//Invoke our after eat callback if it is valid
	foodstuff.after_eat?.Invoke(eater, feeder, foodstuff.bitecount)

	//Invoke the eater's stomach's after_eat callback if valid
	if(iscarbon(eater))
		var/mob/living/carbon/carbon_eater = eater
		var/obj/item/organ/stomach/stomach = carbon_eater.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(istype(stomach))
			stomach.after_eat(owner)

	return TRUE

// For containers
/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/proc/transpose_container(datum/reagents/reagents , fraction, mob/M, mob/user)
	return FALSE


// For industrial feeding tube
/* TO BE REIMPLEMENTED WHEN INDUSTRIAL FEEDING TUBE IS
/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/proc/transpose_industrial_feeding(obj/item/reagent_containers/food/snacks/food, datum/reagents/food_reagents, mob/living/original_eater)
	if (!islinked())
		return FALSE
	var/mob/living/carbon/human/eater = linked_receiver.victim
	var/food_size = food_reagents.total_volume //We're cramming the Whole Thing down your throat~
	food_reagents.reaction(eater, INGEST, food_size)
	food_reagents.trans_to(eater, food_size)
	eater.fullness += food_size
	food.checkLiked(food_size, eater) //...Hopefully you like the taste.
	eater.visible_message("<span class='warning'>[eater]'s belly seems to greatly distend, as if it was being inflated with large amounts of food.</span>", "<span class='danger'>You feel an immense pressure in your stomach, as if large amounts of food were pumped directly into you.</span>")
	return TRUE
*/

// For feeding tube
/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/proc/transpose_feeding(transfer_amount, obj/item/reagent_containers/beaker, mob/living/original_eater)
	return FALSE

/obj/item/clothing/neck/human_petcollar/locked/bluespace_collar_transmitter/attack_self_secondary(mob/user, modifiers)
	linked_receiver = 0
	var/mob/living/carbon/U = user
	to_chat(U, "<span class='notice'>You remove the currently linked receiver collar from the buffer</span>")
	. = ..()
