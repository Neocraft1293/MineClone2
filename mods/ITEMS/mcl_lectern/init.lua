-- Made for MineClone 2 by Michieal.
-- Texture made by Michieal; The model borrows the top from NathanS21's (Nathan Salapat) Lectern model; The rest of the
-- lectern model was created by Michieal.
-- Creation date: 01/07/2023 (07JAN2023)
-- License for Code: GPL3
-- License for Media: CC-BY-SA 4

-- LOCALS
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local node_sound = mcl_sounds.node_sound_wood_defaults()
local pi = 3.1415926

local lectern_def = {
	description = S("Lectern"),
	_tt_help = S("Lecterns not only look good, but are job site blocks for Librarians."),
	_doc_items_longdesc = S("Lecterns not only look good, but are job site blocks for Librarians."),
	_doc_items_usagehelp = S("Place the Lectern on a solid node for best results. May attract villagers, so it's best to place outside of where you call 'home'."),
	sounds = node_sound,
	paramtype = "light",
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	paramtype2 = "facedir",
	drawtype = "mesh",
	mesh = "mcl_lectern_lectern.obj",
	tiles = {"mcl_lectern_lectern.png", },
	groups = {handy = 1, axey = 1, flammable = 2, fire_encouragement = 5, fire_flammability = 5},
	drops = "mcl_lectern:lectern",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	node_prediction = "",
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
	on_place = function(itemstack, placer, pointed_thing)
		local above = pointed_thing.above
		local under = pointed_thing.under

		local pos = under
		local pname = placer:get_player_name()
		if minetest.is_protected(pos, pname) then
			minetest.record_protection_violation(pos, pname)
			return
		end

		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end
		local dir = vector.subtract(under, above)
		local wdir = minetest.dir_to_wallmounted(dir)
		local fdir = minetest.dir_to_facedir(dir)
		if wdir == 0 then
			return itemstack
			-- IE., no Hanging Lecterns for you!
		end
		if wdir == 1 then
			-- (only make standing nodes...)
			-- Determine the rotation based on player's yaw
			local yaw = pi * 2 - placer:get_look_horizontal()

			-- Convert to 16 dir.
			local rotation_level = math.round((yaw / (pi * 2)) * 16)

			-- put the rotation level within bounds.
			if rotation_level > 15 then
				rotation_level = 0
			elseif rotation_level < 0 then
				rotation_level = 15
			end

			fdir = math.floor(rotation_level / 4) -- collapse that to 4 dir.
			local lectern_node = ItemStack(itemstack)
			-- Place the node!
			local _, success = minetest.item_place_node(lectern_node, placer, pointed_thing, fdir)
			if not success then
				return itemstack
			end
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,

}
minetest.register_node("mcl_lectern:lectern", lectern_def)
mcl_wip.register_wip_item("mcl_lectern:lectern")

minetest.register_craft({
	output = "mcl_lectern:lectern",
	recipe = {
		{"group:slab", "group:slab", "group:slab"},
		{"", "mcl_books:bookshelf", ""},
		{"", "group:slab", ""},
	}
})

-- Base Aliases.
minetest.register_alias("lectern", "mcl_lectern:lectern")
