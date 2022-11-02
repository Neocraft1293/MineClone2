---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by michieal.
--- DateTime: 10/26/22 1:16 AM
---

mcl_itemframes = {}
mcl_itemframes.item_frame_base = {}
mcl_itemframes.glow_frame_base = {}
mcl_itemframes.frames_registered = {}
mcl_itemframes.frames_registered.glowing = {}
mcl_itemframes.frames_registered.standard = {}

local S = minetest.get_translator(minetest.get_current_modname())
local table = table
local DEBUG = false

local pairs = pairs

if 1 == 1 then
    minetest.log("action", "[mcl_itemframes] API initialized.")
end

local VISUAL_SIZE = 0.3
local facedir = {}
facedir[0] = { x = 0, y = 0, z = 1 }
facedir[1] = { x = 1, y = 0, z = 0 }
facedir[2] = { x = 0, y = 0, z = -1 }
facedir[3] = { x = -1, y = 0, z = 0 }
local pi = math.pi

local glow_amount = 6 -- LIGHT_MAX is 15, but the items aren't supposed to be a light source.
local frame_item_base = {}
local map_item_base = {}

-- Time to Fleckenstein! (it just sounds cool lol)

--- self: the object to roll.
local function update_roll(self, pos)

    -- get the entity's metadata.
    local meta = minetest.get_meta(pos)

    -- using an integer, as it's the number of 45 degree turns. ie, 0 to 7
    local current_roll = meta:get_int("roll", 0)
    local new_roll = current_roll + 1

    if new_roll == 8 then
        new_roll = 0
    end
    meta:set_int("roll", new_roll)

    local new_roll_deg = new_roll * 45

    -- * `get_rotation()`: returns the rotation, a vector (radians)
    local rot = self:get_rotation()
    local Radians = 0

    -- Radians = Degrees * (pi / 180) degrees to radian formula
    -- Radian quick chart
    -- One full revolution is equal to 2π rad (or) 360°.
    -- 1° = 0.017453 radians and 1 rad = 57.2958°.
    -- To convert an angle from degrees to radians, we multiply it by π/180°.
    -- To convert an angle from radians to degrees, we multiply it by 180°/π.

    Radians = new_roll_deg * (pi / 180)
    rot.z = Radians

    self:set_rotation(rot)

end

--- self: the object to roll.
--- faceDeg: 0-7, inclusive.
local function set_roll(self, faceDeg)
    -- get the entity's metadata.
    local meta = minetest.get_meta(self:get_pos())

    -- using an integer, as it's the number of 45 degree turns. ie, 0 to 7
    local new_roll = faceDeg

    if new_roll >= 8 then
        new_roll = 7
    end
    if new_roll <= 0 then
        new_roll = 0
    end

    meta:set_int("roll", new_roll)

    local new_roll_deg = new_roll * 45

    -- * `get_rotation()`: returns the rotation, a vector (radians)
    local rot = self:get_rotation()
    local Radians = 0

    -- Radians = Degrees * (pi / 180) degrees to radian formula
    -- Radian quick chart
    -- One full revolution is equal to 2π rad (or) 360°.
    -- 1° = 0.017453 radians and 1 rad = 57.2958°.
    -- To convert an angle from degrees to radians, we multiply it by π/180°.
    -- To convert an angle from radians to degrees, we multiply it by 180°/π.

    Radians = new_roll_deg * (pi / 180)

    rot.z = Radians

    self:set_rotation(rot)
end

local function update_map_texture (self, staticdata)
    self.id = staticdata
    local result = true
    result = mcl_maps.load_map(self.id, function(texture)
        -- will not crash even if self.object is invalid by now
        -- update... quite possibly will screw up with each version of Minetest. >.<
        if not texture then
            minetest.log("error", "Failed to load the map texture using mcl_maps.")
        end

        self.object:set_properties({ textures = { texture } })
    end)
    if result ~= nil and result == false then
        mintest.log("error", "[mcl_itemframes] Error setting up Map Item.")
    end

end

local remove_item_entity = function(pos, node)

    local name_found = false
    local found_name_to_use = ""

    for k, v in pairs(mcl_itemframes.frames_registered.glowing) do
        if node.name == v then
            name_found = true
            found_name_to_use = v
            break
        end
    end

    -- try to cut down on excess looping, if possible.
    if name_found == false then
        for k, v in pairs(mcl_itemframes.frames_registered.standard) do
            if node.name == v then
                name_found = true
                found_name_to_use = v
                break
            end
        end
    end

    if 1 == 1 then
        minetest.log("action", "mcl_itemframes] remove_item_entity: " .. found_name_to_use .. "'s displayed item.")
    end

    if node.name == "mcl_itemframes:item_frame" or node.name == "mcl_itemframes:glow_item_frame" or node.name == found_name_to_use then
        for _, obj in pairs(minetest.get_objects_inside_radius(pos, 0.5)) do
            local entity = obj:get_luaentity()
            if entity then
                if entity.name == "mcl_itemframes:item" or entity.name == "mcl_itemframes:map" or
                        entity.name == "mcl_itemframes:glow_item" or entity.name == "mcl_itemframes:glow_map" then
                    obj:remove()
                elseif entity.name == found_name_to_use .. "_item" or entity.name == found_name_to_use .. "_map" then
                    if 1 == 1 then
                        minetest.log("action", "mcl_itemframes] remove_item_entity: " .. entity.name .. "-- the item.")
                    end
                    obj:remove()
                end
            end
        end
    end
end

mcl_itemframes.update_item_entity = function(pos, node, param2)
    if 1 == 1 then
        minetest.log("action", "[mcl_itemframes] Update_Item_Entity:\nPosition: " .. dump(pos) .. "\nNode: " .. dump(node))
    end
    remove_item_entity(pos, node)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local item = inv:get_stack("main", 1)
    if not item:is_empty() then
        if not param2 then
            param2 = node.param2
        end

        if node.name == "mcl_itemframes:item_frame" or node.name == "mcl_itemframes:glow_item_frame" then
            local posad = facedir[param2]
            pos.x = pos.x + posad.x * 6.5 / 16
            pos.y = pos.y + posad.y * 6.5 / 16
            pos.z = pos.z + posad.z * 6.5 / 16
        end

        local yaw = pi * 2 - param2 * pi / 2
        local map_id = item:get_meta():get_string("mcl_maps:id")
        local map_id_entity = {}
        local map_id_lua = {}

        if map_id == "" then
            if node.name == "mcl_itemframes:item_frame" then
                map_id_entity = minetest.add_entity(pos, "mcl_itemframes:item")
            elseif node.name == "mcl_itemframes:glow_item_frame" then
                map_id_entity = minetest.add_entity(pos, "mcl_itemframes:glow_item")
            end
            map_id_lua = map_id_entity:get_luaentity()
            map_id_lua._nodename = node.name
            local itemname = item:get_name()
            if itemname == "" or itemname == nil then
                map_id_lua._texture = "blank.png"
                map_id_lua._scale = 1
            else
                map_id_lua._texture = itemname
                local def = minetest.registered_items[itemname]
                map_id_lua._scale = def and def.wield_scale and def.wield_scale.x or 1
            end
            map_id_lua:_update_texture()
            if node.name == "mcl_itemframes:item_frame" or node.name == "mcl_itemframes:glow_item_frame" then
                map_id_entity:set_yaw(yaw)
            end
        else
            if node.name == "mcl_itemframes:item_frame" then
                map_id_entity = minetest.add_entity(pos, "mcl_itemframes:map", map_id)
            elseif node.name == "mcl_itemframes:glow_item_frame" then
                map_id_entity = minetest.add_entity(pos, "mcl_itemframes:glow_map", map_id)
            end
            map_id_entity:set_yaw(yaw)
        end

        -- finally, set the rotation (roll) of the displayed object.
        local roll = meta:get_int("roll", 0)
        set_roll(map_id_entity, roll)

    end
end

mcl_itemframes.update_generic_item_entity = function(pos, node, param2)

    if 1 == 1 then
        minetest.log("action", "[mcl_itemframes] Update_Generic_Item:\nPosition: " .. dump(pos) .. "\nNode: " .. dump(node))
    end

    remove_item_entity(pos, node)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local item = inv:get_stack("main", 1)

    local name_found = false
    local found_name_to_use = ""
    local has_glow = false

    for k, v in pairs(mcl_itemframes.frames_registered.glowing) do
        if node.name == v then
            name_found = true
            has_glow = true
            found_name_to_use = v
            break
        end
    end

    -- try to cut down on excess looping, if possible.
    if name_found == false then
        for k, v in pairs(mcl_itemframes.frames_registered.standard) do
            if node.name == v then
                name_found = true
                has_glow = false
                found_name_to_use = v
                break
            end
        end
    end

    if name_found == false then
        minetest.log("error", "[mcl_itemframes] Update_Generic_Item:\nFailed to find registered node:\nNode name - " .. node.name)
        minetest.log("error", "[mcl_itemframes] Update_Generic_Item:\nRegistry definition:" .. dump(mcl_itemframes.frames_registered))
        return
    end

    if not item:is_empty() then
        -- update existing items placed.
        if not param2 then
            param2 = node.param2
        end
        local pos_adj = facedir[param2]

        if node.name == found_name_to_use then
            pos.x = pos.x + pos_adj.x * 6.5 / 16
            pos.y = pos.y + pos_adj.y * 6.5 / 16
            pos.z = pos.z + pos_adj.z * 6.5 / 16

            if 1 == 1 then
                minetest.log("[mcl_itemframes] Update_Generic_Item:\nFound Name in Registry: " .. found_name_to_use)
            end
        end
        local yaw = pi * 2 - param2 * pi / 2
        local map_id = item:get_meta():get_string("mcl_maps:id")
        local map_id_entity = {}
        local map_id_lua = {}

        if map_id == "" then
            -- handle regular items placed into custom frame.
            if 1 == 1 then
                minetest.log("action", "[mcl_itemframes] Update_Generic_Item:\nAdding entity: " .. node.name .. "_item")
            end
            if node.name == found_name_to_use then
                map_id_entity = minetest.add_entity(pos, node.name .. "_item")
            else
                local debugs_string = "[mcl_itemframes] Update_Generic_Item:\nCouldn't find node name in registry: "
                minetest.log("error", debugs_string .. found_name_to_use "\nregistry: " .. dump(mcl_itemframes.frames_registered))

                return
            end

            map_id_lua = map_id_entity:get_luaentity()
            map_id_lua._nodename = node.name

            local itemname = item:get_name()
            if itemname == "" or itemname == nil then
                map_id_lua._texture = "blank.png"
                map_id_lua._scale = 1
                if has_glow then
                    map_id_lua.glow = glow_amount
                end
            else
                map_id_lua._texture = itemname
                local def = minetest.registered_items[itemname]
                map_id_lua._scale = def and def.wield_scale and def.wield_scale.x or 1
            end
            if 1 == 1 then
                minetest.log("action", "[mcl_itemframes] Update_Generic_Item: item's name: " .. itemname)
            end
            map_id_lua:_update_texture()
            if node.name == found_name_to_use then
                map_id_entity:set_yaw(yaw)
            else
                minetest.log("error", "[mcl_itemframes] Update_Generic_Item: Failed to set Display Item's yaw. " .. node.name)
            end
        else
            -- handle map items placed into custom frame.
            if 1 == 1 then
                minetest.log("action", "[mcl_itemframes] Update_Generic_Item: Placing map in a " .. found_name_to_use .. " frame.")
            end

            if node.name == found_name_to_use then
                map_id_entity = minetest.add_entity(pos, found_name_to_use .. "_map", map_id)
                map_id_entity:set_yaw(yaw)
            else
                minetest.log("error", "[mcl_itemframes] Update_Generic_Item: Failed to set Map Item in " .. found_name_to_use .. "'s frame.")
            end
        end

        -- finally, set the rotation (roll) of the displayed object.
        local roll = meta:get_int("roll", 0)
        set_roll(map_id_entity, roll)
    end
end

local drop_item = function(pos, node, meta, clicker)
    local cname = ""
    if clicker and clicker:is_player() then
        cname = clicker:get_player_name()
    end
    if not minetest.is_creative_enabled(cname) then
        if (node.name == "mcl_itemframes:item_frame" or node.name == "mcl_itemframes:glow_item_frame") then
            local inv = meta:get_inventory()
            local item = inv:get_stack("main", 1)
            if not item:is_empty() then
                minetest.add_item(pos, item)
            end
        end
    end

    meta:set_string("infotext", "")
    meta:set_int("roll", 0)
    remove_item_entity(pos, node)
end

function mcl_itemframes.drop_generic_item(pos, node, meta, clicker)
    local name_found = false
    local found_name_to_use = ""

    for k, v in pairs(mcl_itemframes.frames_registered.glowing) do
        if node.name == v then
            name_found = true
            found_name_to_use = v
            break
        end
    end

    -- try to cut down on excess looping, if possible.
    if name_found == false then
        for k, v in pairs(mcl_itemframes.frames_registered.standard) do
            if node.name == v then
                name_found = true
                found_name_to_use = v
                break
            end
        end
    end

    local cname = ""
    if clicker and clicker:is_player() then
        cname = clicker:get_player_name()
    end
    if not minetest.is_creative_enabled(cname) then
        if (node.name == found_name_to_use) then
            local inv = meta:get_inventory()
            local item = inv:get_stack("main", 1)
            if not item:is_empty() then
                minetest.add_item(pos, item)
            end
        end
    end

    meta:set_string("infotext", "")
    remove_item_entity(pos, node)

end

mcl_itemframes.item_frame_base = {
    description = S("Item Frame"),
    _tt_help = S("Can hold an item"),
    _doc_items_longdesc = S("Item frames are decorative blocks in which items can be placed."),
    _doc_items_usagehelp = S("Just place any item on the item frame. Use the item frame again to retrieve the item."),
    drawtype = "mesh",
    is_ground_content = false,
    mesh = "mcl_itemframes_itemframe1facedir.obj",
    selection_box = { type = "fixed", fixed = { -6 / 16, -6 / 16, 7 / 16, 6 / 16, 6 / 16, 0.5 } },
    collision_box = { type = "fixed", fixed = { -6 / 16, -6 / 16, 7 / 16, 6 / 16, 6 / 16, 0.5 } },
    tiles = { "mcl_itemframes_item_frame_back.png", "mcl_itemframes_item_frame_back.png", "mcl_itemframes_item_frame_back.png", "mcl_itemframes_item_frame_back.png", "default_wood.png", "mcl_itemframes_item_frame_back.png" },
    inventory_image = "mcl_itemframes_item_frame.png",
    wield_image = "mcl_itemframes_item_frame.png",
    use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    groups = { dig_immediate = 3, deco_block = 1, dig_by_piston = 1, container = 7, attached_node_facedir = 1 },
    sounds = mcl_sounds.node_sound_defaults(),
    node_placement_prediction = "",

    on_timer = function(pos)
        local inv = minetest.get_meta(pos):get_inventory()
        local stack = inv:get_stack("main", 1)
        local itemname = stack:get_name()
        if minetest.get_item_group(itemname, "clock") > 0 then
            local new_name = "mcl_clock:clock_" .. (mcl_worlds.clock_works(pos) and mcl_clock.old_time or mcl_clock.random_frame)
            if itemname ~= new_name then
                stack:set_name(new_name)
                inv:set_stack("main", 1, stack)
                local node = minetest.get_node(pos)
                if node.name == "mcl_itemframes:item_frame" or node.name == "mcl_itemframes:glow_item_frame" then
                    mcl_itemframes.update_item_entity(pos, node, node.param2)
                else
                    mcl_itemframes.update_generic_item_entity(pos, node, node.param2)
                end

            end
            minetest.get_node_timer(pos):start(1.0)
        end
    end,

    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end

        -- Use pointed node's on_rightclick function first, if present
        local node = minetest.get_node(pointed_thing.under)
        if placer and not placer:get_player_control().sneak then
            if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
                return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
            end
        end

        return minetest.item_place(itemstack, placer, pointed_thing, minetest.dir_to_facedir(vector.direction(pointed_thing.above, pointed_thing.under)))
    end,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 1)
    end,

    on_rightclick = function(pos, node, clicker, itemstack)
        if not itemstack then
            return
        end
        local pname = clicker:get_player_name()
        if minetest.is_protected(pos, pname) then
            minetest.record_protection_violation(pos, pname)
            return
        end
        local meta = minetest.get_meta(pos)

        if node.name == "mcl_itemframes:item_frame" or node.name == "mcl_itemframes:glow_item_frame" then
            drop_item(pos, node, meta, clicker)
        else
            mcl_itemframes.drop_generic_item(pos, node, meta, clicker)
        end

        local inv = meta:get_inventory()
        if itemstack:is_empty() then
            remove_item_entity(pos, node)
            meta:set_string("infotext", "")
            inv:set_stack("main", 1, "")
            return itemstack
        end
        local put_itemstack = ItemStack(itemstack)
        put_itemstack:set_count(1)
        local itemname = put_itemstack:get_name()
        if minetest.get_item_group(itemname, "compass") > 0 then
            put_itemstack:set_name(mcl_compass.get_compass_itemname(pos, minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2)), put_itemstack))
        end
        if minetest.get_item_group(itemname, "clock") > 0 then
            minetest.get_node_timer(pos):start(1.0)
        end

        inv:set_stack("main", 1, put_itemstack)
        if node.name == "mcl_itemframes:item_frame" or node.name == "mcl_itemframes:glow_item_frame" then
            mcl_itemframes.update_item_entity(pos, node)
        else
            mcl_itemframes.update_generic_item_entity(pos, node)
        end

        -- Add node infotext when item has been named
        local imeta = itemstack:get_meta()
        local iname = imeta:get_string("name")
        if iname then
            meta:set_string("infotext", iname)
        end

        if not minetest.is_creative_enabled(clicker:get_player_name()) then
            itemstack:take_item()
        end
        return itemstack
    end,

    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        local name = player:get_player_name()
        if minetest.is_protected(pos, name) then
            minetest.record_protection_violation(pos, name)
            return 0
        else
            return count
        end
    end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        local name = player:get_player_name()
        if minetest.is_protected(pos, name) then
            minetest.record_protection_violation(pos, name)
            return 0
        else
            return stack:get_count()
        end
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local name = player:get_player_name()
        if minetest.is_protected(pos, name) then
            minetest.record_protection_violation(pos, name)
            return 0
        else
            return stack:get_count()
        end
    end,

    on_destruct = function(pos)
        local meta = minetest.get_meta(pos)
        local node = minetest.get_node(pos)

        if node.name == "mcl_itemframes:item_frame" or node.name == "mcl_itemframes:glow_item_frame" then
            drop_item(pos, node, meta) -- originally had ", clicker" too. Except, clicker doesn't exist in the context.
        else
            mcl_itemframes.drop_generic_item(pos, node, meta)
        end
    end,

    on_rotate = function(pos, node, user, mode, param2)
        --local meta = minetest.get_meta(pos)
        local node = minetest.get_node(pos)

        local objs = nil
        local name_found = false
        local found_name_to_use = ""
        name_found = false
        found_name_to_use = ""

        for k, v in pairs(mcl_itemframes.frames_registered.glowing) do
            if node.name == v then
                name_found = true
                found_name_to_use = v
                break
            end
        end

        -- try to cut down on excess looping, if possible.
        if name_found == false then
            for k, v in pairs(mcl_itemframes.frames_registered.standard) do
                if node.name == v then
                    name_found = true
                    found_name_to_use = v
                    break
                end
            end
        end

        if node.name == found_name_to_use then
            objs = minetest.get_objects_inside_radius(pos, 0.5)
        else
            return -- short circuit if it's somehow not the right thing.
        end

        if objs then
            if mode == screwdriver.ROTATE_FACE or mode == screwdriver.ROTATE_AXIS then
                for _, obj in ipairs(objs) do
                    if obj and obj:get_luaentity() then
                        local obj_name = obj:get_luaentity().name
                        if obj_name == "mcl_itemframes:item" or obj_name == "mcl_itemframes:glow_item" then
                            if mode == screwdriver.ROTATE_AXIS then
                                update_roll(obj, pos)
                            end
                            break
                        elseif obj_name == found_name_to_use .. "_item" then
                            if mode == screwdriver.ROTATE_AXIS then
                                update_roll(obj, pos)
                            end
                            break
                        end
                    end
                end
                return false
            end
        end
    end,
}

--- reworked to set up the base item definitions, and to register them for item and glow_item.
function mcl_itemframes.create_base_item_entity()
    if 1 == 1 then
        minetest.log("action", "[mcl_itemframes] create_item_entity.")
    end

    --"mcl_itemframes:item",
    frame_item_base = {
        hp_max = 1,
        visual = "wielditem",
        visual_size = { x = VISUAL_SIZE, y = VISUAL_SIZE },
        physical = false,
        pointable = false,
        textures = { "blank.png" },
        _texture = "blank.png",
        _scale = 1,

        on_activate = function(self, staticdata)
            if staticdata and staticdata ~= "" then
                local data = staticdata:split(";")
                if data and data[1] and data[2] then
                    self._nodename = data[1]
                    self._texture = data[2]
                    if data[3] then
                        self._scale = data[3]
                    else
                        self._scale = 1
                    end
                end
            end
            if self._texture then
                self.object:set_properties({
                    textures = { self._texture },
                    visual_size = { x = VISUAL_SIZE / self._scale, y = VISUAL_SIZE / self._scale },
                })
            end
        end,
        get_staticdata = function(self)
            if self._nodename and self._texture then
                local ret = self._nodename .. ";" .. self._texture
                if self._scale then
                    ret = ret .. ";" .. self._scale
                end
                return ret
            end
            return ""
        end,

        _update_texture = function(self)
            if self._texture then
                self.object:set_properties({
                    textures = { self._texture },
                    visual_size = { x = VISUAL_SIZE / self._scale, y = VISUAL_SIZE / self._scale },
                })
            end
        end,
    }
    -- "mcl_itemframes:map",
    map_item_base = {
        initial_properties = {
            visual = "upright_sprite",
            visual_size = { x = 1, y = 1 },
            pointable = false,
            physical = false,
            collide_with_objects = false,
            textures = { "blank.png" },
        },
        on_activate = function(self, staticdata)
            if 1 == 1 then
                minetest.log("action", "[mcl_itemframes] map_item:on_activate.")
            end
            update_map_texture(self, staticdata)
        end,

        get_staticdata = function(self)
            return self.id
        end,
    }

    local glow_frame_item = table.copy(frame_item_base)
    glow_frame_item.glow = glow_amount
    local glow_frame_map_item = table.copy(map_item_base)
    glow_frame_map_item.name = "mcl_itemframes:glow_map"

    minetest.register_entity("mcl_itemframes:glow_item", glow_frame_item)
    minetest.register_entity("mcl_itemframes:glow_map", glow_frame_map_item)
    minetest.register_entity("mcl_itemframes:item", frame_item_base)
    minetest.register_entity("mcl_itemframes:map", map_item_base)

end

function mcl_itemframes.create_custom_items(name, has_glow)

    if has_glow then
        local glow_frame_item = table.copy(frame_item_base)
        local glow_frame_map_item = table.copy(map_item_base)
        glow_frame_map_item.glow = glow_amount
        glow_frame_item.glow = glow_amount

        minetest.register_entity(name .. "_item", glow_frame_item)
        minetest.register_entity(name .. "_map", glow_frame_map_item)
        if 1 == 1 then
            minetest.log("action", "\n[mcl_itemframes] create_custom_item_entity: glow name: " .. name .. "_item")
            minetest.log("action", "[mcl_itemframes] create_custom_item_entity: glow name: " .. name .. "_map\n")
        end
    else
        minetest.register_entity(name .. "_item", frame_item_base)
        minetest.register_entity(name .. "_map", map_item_base)
        if 1 == 1 then
            minetest.log("action", "\n[mcl_itemframes] create_custom_item_entity: name: " .. name .. "_item")
            minetest.log("action", "[mcl_itemframes] create_custom_item_entity: name: " .. name .. "_map\n")
        end
    end
end

function mcl_itemframes.update_frame_registry(modname, name, has_glow)
    local mod_name_pass = false
    if modname ~= "" and modname ~= "false" then
        if minetest.get_modpath(modname) then
            mod_name_pass = true
        end
        if mod_name_pass == false then
            return
        end
    end

    local frame = name -- should only be called within the create_frames functions.
    if has_glow == true then
        table.insert(mcl_itemframes.frames_registered.glowing, frame)
    else
        table.insert(mcl_itemframes.frames_registered.standard, frame)
    end

end

--- name: The name used to distinguish the item frame. Prepends "mcl_itemframes:" to the name. Example usage:
--- "glow_item_frame" creates a node named "mcl_itemframes:glow_item_frame".
function mcl_itemframes.create_custom_frame(modname, name, has_glow, tiles, color, ttframe, description)
    local mod_name_pass = false
    if modname ~= "" and modname ~= "false" then
        if minetest.get_modpath(modname) then
            mod_name_pass = true
        end
        if mod_name_pass == false then
            return
        end
    end
    if name == nil then
        name = ""
    end

    if has_glow == nil or has_glow == "" then
        has_glow = false
    end

    if tiles == nil or tiles == "" then
        minetest.log("error", "No textures passed to Create_Custom_Frame!! Exiting frame creation.")
        return
    end

    local working_name = "mcl_itemframes:" .. name

    if 1 == 1 then
        minetest.log("action", "[mcl_itemframes] create_custom_frame: " .. working_name)
        minetest.log("action", "[mcl_itemframes] create_custom_frame - calling create_custom_items " .. working_name)
    end

    -- make any special frame items.
    mcl_itemframes.create_custom_items(working_name, has_glow)

    local custom_itemframe_definition = {}

    if has_glow == false then
        custom_itemframe_definition = table.copy(mcl_itemframes.item_frame_base)
    else
        custom_itemframe_definition = table.copy(mcl_itemframes.glow_frame_base)
    end

    custom_itemframe_definition.tiles = { "(" .. tiles .. "^[multiply:" .. color .. ")" }
    custom_itemframe_definition._tt_help = ttframe
    custom_itemframe_definition.description = description

    minetest.register_node(working_name, custom_itemframe_definition)

    mcl_itemframes.update_frame_registry(modname, working_name, has_glow)
    mcl_itemframes.custom_register_lbm(working_name)

end

-- the local version is for the base glow & base frame.
local function create_register_lbm(name)

    -- FIXME: Item entities can get destroyed by /clearobjects
    -- glow frame
    minetest.register_lbm({
        label = "Respawn item frame item entities",
        name = "mcl_itemframes:respawn_entities",
        nodenames = { name },
        run_at_every_load = true,
        action = function(pos, node)
            mcl_itemframes.update_item_entity(pos, node)
        end,
    })

end
function mcl_itemframes.custom_register_lbm(name)

    -- FIXME: Item entities can get destroyed by /clearobjects
    -- glow frame
    minetest.register_lbm({
        label = "Respawn item frame item entities",
        name = "mcl_itemframes:respawn_entities",
        nodenames = { name },
        run_at_every_load = true,
        action = function(pos, node)
            mcl_itemframes.update_generic_item_entity(pos, node)
        end,
    })

end

function mcl_itemframes.create_base_frames()
    if 1 == 1 then
        minetest.log("action", "[mcl_itemframes] create_frames.")
    end

    -- make the base items for the base frames.
    mcl_itemframes.create_base_item_entity()

    minetest.register_node("mcl_itemframes:item_frame", mcl_itemframes.item_frame_base)

    -- make glow frame from the base item_frame.
    mcl_itemframes.glow_frame_base = table.copy(mcl_itemframes.item_frame_base)
    mcl_itemframes.glow_frame_base.description = S("Glow Item Frame")
    mcl_itemframes.glow_frame_base._tt_help = S("Can hold an item and glows")
    mcl_itemframes.glow_frame_base.longdesc = S("Glow item frames are decorative blocks in which items can be placed.")
    mcl_itemframes.glow_frame_base.tiles = { "mcl_itemframes_glow_item_frame.png" }
    mcl_itemframes.glow_frame_base.inventory_image = "mcl_itemframes_glow_item_frame_item.png"
    mcl_itemframes.glow_frame_base.wield_image = "mcl_itemframes_glow_item_frame.png"
    mcl_itemframes.glow_frame_base.mesh = "mcl_itemframes_glow_item_frame.obj"

    minetest.register_node("mcl_itemframes:glow_item_frame", mcl_itemframes.glow_frame_base)

    mcl_itemframes.update_frame_registry("false", "mcl_itemframes:item_frame", false)
    mcl_itemframes.update_frame_registry("false", "mcl_itemframes:glow_item_frame", true)
    create_register_lbm("mcl_itemframes:item_frame")
    create_register_lbm("mcl_itemframes:glow_item_frame")
end
