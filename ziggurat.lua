-- Ziggurat ziggurat.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


local max_depth = 31000
local ziggurat_rarity = 20  -- 20
local biome_rarity = 5  -- 5

-- ziggurat stone
newnode = zigg_mod.clone_node("default:sandstone")
newnode.description = "Pyramid Stone"
newnode.tiles = {'zigg_ziggurat_stone.png'}
newnode.groups.ziggurat = 1
newnode.drop = 'default:sandstone'
minetest.register_node("zigg:ziggurat_1", newnode)


local ziggurat_biomes = {}
for _, i in pairs({"rainforest", "desert", "desertstone_grassland", }) do
	ziggurat_biomes[i] = true
end

local ziggurat_noise_1 = {offset = 0, scale = 1, seed = -6012, spread = {x = 20, y = 10, z = 20}, octaves = 6, persist = 1, lacunarity = 2}


zigg_mod.ziggurat = function(minp, maxp, data, area, biomemap, biome_ids, node, heightmap)
	if not (minp and maxp and data and area and node and type(data) == 'table') then
		return
	end

	if math.random(ziggurat_rarity) ~= 1 then
		return
	end

	if biomemap then
		local biome = biome_ids[biomemap[3240]]
		if not (zigg_mod.ziggurats_everywhere or ziggurat_biomes[biome]) then
			return
		end
	elseif math.random(biome_rarity) ~= 1 then
		return
	end


	local min_y = 80
	local index = 0
	for z = minp.z, maxp.z do
		local dz = z - minp.z
		for x = minp.x, maxp.x do
			local dx = x - minp.x
			index = index + 1
			if dz > 8 and dz < 72 and dx > 8 and dx < 72 and heightmap[index] - minp.y < 0 then
				return
			elseif heightmap[index] - minp.y < min_y then
				min_y = heightmap[index] - minp.y
			end
		end
	end
	if min_y >= 72 or heightmap[3240] >= 72 then
		return
	end

	local base_height = math.min(min_y, 35)

	local csize = vector.add(vector.subtract(maxp, minp), 1)
	local map_max = {x = csize.x, y = csize.y, z = csize.z}
	local map_min = {x = minp.x, y = minp.y, z = minp.z}

	local ziggurat_1 = minetest.get_perlin_map(ziggurat_noise_1, map_max):get3dMap_flat(map_min)
	if not ziggurat_1 then
		return
	end

	local write = true
	local p2write = false

	index = 0
	local index3d = 0
	for z = minp.z, maxp.z do
		local dz = z - minp.z
		for x = minp.x, maxp.x do
			local dx = x - minp.x
			index = index + 1
			index3d = math.floor((z - minp.z) / 5) * (csize.y) * csize.x + math.floor((x - minp.x) / 5) + 1
			local ivm = area:index(x, minp.y, z)

			for y = minp.y, maxp.y do
				local dy = y - minp.y

				if dy >= base_height + 3 and dy <= base_height + 37 - math.max(math.abs(dx - 40), math.abs(dz - 40)) and ziggurat_1[index3d] > 0 then
					if data[ivm - area.ystride] == node['zigg:ziggurat_1'] and math.random(50) == 1 then
            if minetest.registered_items['booty:coffer'] then
              data[ivm] = node['booty:coffer']
            else
              data[ivm] = node['default:chest']
            end
					else
						data[ivm] = node['air']
					end
				elseif dy >= base_height + 3 and dy <= base_height + 37 - math.max(math.abs(dx - 40), math.abs(dz - 40)) then
					data[ivm] = node['zigg:ziggurat_1']
				elseif dy >= base_height and dy <= base_height + 40 - math.max(math.abs(dx - 40), math.abs(dz - 40)) then
					data[ivm] = node['default:sandstone_block']
				end

				ivm = ivm + area.ystride
				if dy % 5 == 0 then
					index3d = index3d + csize.x
				end
			end
		end
	end

	return write, p2write
end
