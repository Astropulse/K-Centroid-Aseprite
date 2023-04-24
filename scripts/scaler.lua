local scaler = {}

function scaler:kCenter(width, height, colors, accuracy)
	app.transaction(
		function()
			local image = app.activeCel.image
			cel = app.activeSprite:newCel(app.activeSprite:newLayer(), app.activeFrame)
			cel.layer.name = "K-Tiles"

			cel2 = app.activeSprite:newCel(app.activeSprite:newLayer(), app.activeFrame)
			cel2.layer.name = "K-Centroid"

			local tiles = {}
			local newImg = Image(image.width, image.height)
			local newImg2 = Image(width, height)

			local wFactor = image.width/width
			local hFactor = image.height/height

			-- Create a table of image tiles and colors
			for x = 0, width - 1 do
				for y = 0, height - 1 do
					tiles[#tiles+1] = kMeans(Image(image, Rectangle(x*wFactor, y*hFactor, wFactor, hFactor)), colors, accuracy)

					newImg:drawImage(tiles[#tiles][1], Point(x*wFactor, y*hFactor))
					newImg2:drawPixel(x, y, tiles[#tiles][2])
				end
			end
			cel.image = newImg
			cel2.image = newImg2
			app.refresh()
		end)
end

function kMeans(image, k, accuracy)

	-- Lock the random seed for consistent results
	math.randomseed(1)

	-- Convert the pixel data to a table of RGB values
	local pixels = {}
	pixels.size = image.width * image.height
	for i = 1, pixels.size do
		local pixel = image:getPixel((i - 1) % image.width, math.floor((i - 1) / image.width))
		pixels[i] = {r = app.pixelColor.rgbaR(pixel), g = app.pixelColor.rgbaG(pixel), b = app.pixelColor.rgbaB(pixel)}
	end

	-- Initialize the centroids randomly
	local centroids = {}
	for i = 1, k do
		table.insert(centroids, pixels[math.random(#pixels)])
	end

	-- Iterate untill accuracy is exceeded
	for iter = 1, accuracy do
		-- Assign each pixel to its nearest centroid
		local clusters = {}
		for i, pixel in ipairs(pixels) do
			local min_dist = math.huge
			local nearest_centroid
			for j, centroid in ipairs(centroids) do
				local dist = distance(pixel, centroid)
				if dist < min_dist then
					min_dist = dist
					nearest_centroid = centroid
				end
			end
			if not clusters[nearest_centroid] then
				clusters[nearest_centroid] = {}
			end
		table.insert(clusters[nearest_centroid], pixel)
		end

		-- Recalculate the centroids
		local new_centroids = {}
		for centroid, cluster in pairs(clusters) do
			local sum_r, sum_g, sum_b = 0, 0, 0
			for i, pixel in ipairs(cluster) do
				sum_r = sum_r + pixel.r
				sum_g = sum_g + pixel.g
				sum_b = sum_b + pixel.b
			end
			local num_pixels = #cluster
			table.insert(new_centroids, {r = sum_r / num_pixels, g = sum_g / num_pixels, b = sum_b / num_pixels, count = num_pixels})
		end

		centroids = new_centroids
	end

	-- Find the largest centroid
	local biggest_centroid = centroids[1]
	for n, centroid in pairs(centroids) do
		if centroid.count > biggest_centroid.count then
			biggest_centroid = centroid
		end
	end

	-- Replace each pixel with the nearest centroid
	for y = 0, image.height - 1 do
		for x = 0, image.width - 1 do
			local pixel = image:getPixel(x, y)
			local pixel = {r = app.pixelColor.rgbaR(pixel), g = app.pixelColor.rgbaG(pixel), b = app.pixelColor.rgbaB(pixel)}
			local min_dist = math.huge
			local nearest_centroid
			for i, centroid in ipairs(centroids) do
				local dist = distance(pixel, centroid)
				if dist < min_dist then
					min_dist = dist
					nearest_centroid = centroid
				end
			end
			image:drawPixel(x, y, app.pixelColor.rgba(nearest_centroid.r, nearest_centroid.g,
						nearest_centroid.b, 255))
		end
	end

	-- Return a table with a tile image and a color
	return {image, app.pixelColor.rgba(biggest_centroid.r, biggest_centroid.g, biggest_centroid.b, 255)}
end

-- Define a function to calculate the Euclidean distance between two colors
function distance(color1, color2)
	local dr, dg, db = color1.r - color2.r, color1.g - color2.g, color1.b - color2.b
	return dr * dr + dg * dg + db * db
end	  

return scaler