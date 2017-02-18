-- zungle mapgen.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


local DEBUG
local max_depth = 31000
local seed_noise = {offset = 0, scale = 32768, seed = 5202, spread = {x = 80, y = 80, z = 80}, octaves = 2, persist = 0.4, lacunarity = 2}


-- This tables looks up nodes that aren't already stored.
local node = setmetatable({}, {
	__index = function(t, k)
		if not (t and k and type(t) == 'table') then
			return
		end

		t[k] = minetest.get_content_id(k)
		return t[k]
	end
})


local biome_ids = {}
if true or zungle_mod.use_bi_hi then
	-- Create a table of biome ids, so I can use the biomemap.
	local get_biome_id = minetest.get_biome_id
	for name, desc in pairs(minetest.registered_biomes) do
		biome_ids[get_biome_id(desc.name)] = desc.name
	end
end


local data = {}


local function generate(p_minp, p_maxp, seed)
	if not (p_minp and p_maxp and seed) then
		return
	end

	local minp, maxp = p_minp, p_maxp
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	if not (vm and emin and emax) then
		return
	end

	vm:get_data(data)
	local heightmap
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local csize = vector.add(vector.subtract(maxp, minp), 1)

	if true or zungle_mod.use_bi_hi then
		heightmap = minetest.get_mapgen_object("heightmap")
	end

  local biomemap
  if true or zungle_mod.use_bi_hi then
    biomemap = minetest.get_mapgen_object("biomemap")
  end

	-- use the same seed (based on perlin noise).
	do
		local seed = minetest.get_perlin(seed_noise):get2d({x=minp.x, y=minp.z})
		if not (seed and type(seed) == 'number') then
			return
		end

		math.randomseed(seed)
	end

  local write = zungle_mod.zungle(minp, maxp, data, area, biomemap, biome_ids, node, heightmap)

  if write then
    vm:set_data(data)

    if DEBUG then
      vm:set_lighting({day = 8, night = 8})
    else
      vm:set_lighting({day = 0, night = 0}, minp, maxp)
      vm:calc_lighting()
    end
    vm:update_liquids()
    vm:write_to_map()
  end
end


if zungle_mod.path then
	dofile(zungle_mod.path .. "/zungle.lua")
end


local function pgenerate(...)
	local status, err = pcall(generate, ...)
	--local status, err = true
	--generate(...)
	if not status then
		print('Treegen: Could not generate terrain:')
		print(dump(err))
		collectgarbage("collect")
	end
end


minetest.register_on_generated(pgenerate)
