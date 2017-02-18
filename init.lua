-- Zigg init.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


zigg_mod = {}
zigg_mod.version = "1.0"
zigg_mod.path = minetest.get_modpath(minetest.get_current_modname())
zigg_mod.world = minetest.get_worldpath()


function zigg_mod.clone_node(name)
	if not (name and type(name) == 'string') then
		return
	end

	local node = minetest.registered_nodes[name]
	local node2 = table.copy(node)
	return node2
end


dofile(zigg_mod.path .. "/mapgen.lua")
