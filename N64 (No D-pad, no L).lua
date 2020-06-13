-- settings
controller_port = 1 -- which controller
debug_stick = false -- useful for debugging, shows x y coords and pythagorean theorem triangle etc
show_grid = false -- draw a 10x10 pixel grid, useful for placing buttons
-- visual settings
containing_circle = true -- show a circle surrounding the joystick
stick_line = false -- visualize the stick as a line
stick_cap = true -- show the "thumb cap"
-- end of settings

forms.destroyall() -- close all Lua windows. this is probably mean to do because i think it closes other Lua scripts' windows too?

function create_window()
	local form = forms.newform(287, 142, "Input Viewer")
	return form
end

function get_inputs(controller_index)
	local input_array = joypad.get(controller_index);
	return input_array
end

function update_stick(in_x, in_y)
	-- this should probably be separated into 2 functions, like calculate_stick_draw() and draw_stick()
	top_corner_x = 20
	top_corner_y = 20
	size = 64
	radius = (size/2)
	stick_cap_size = (size/5)

	-- center of the containing circle
	center_x = top_corner_x + radius
	center_y = top_corner_y + radius

	local out_x = 0
	local out_y = 0

	if debug_stick then
		forms.drawString(pb, 0, 0, "IN " .. tostring(math.floor(in_x)) .. "," .. tostring(math.floor(in_y)), "white") 
	end

	-- check if this is a larger axis value than we've gotten before
	if in_x > max_pos_axis_x then
		max_pos_axis_x = in_x
	elseif in_x < max_neg_axis_x then
		max_neg_axis_x = in_x
	end

	if in_y > max_pos_axis_y then
		max_pos_axis_y = in_y
	elseif in_y < max_neg_axis_y then
		max_neg_axis_y = in_y
	end

	-- scale movement to our known axis lengths
	-- (in other words: 100% of axis = 100% of radius, 50% of axis = 50% of radius etc.)
	if in_x > 0 then
		out_x = in_x * (radius/max_pos_axis_x)
	elseif in_x < 0 then
		out_x = in_x * (radius/-max_neg_axis_x)
	end
	if in_y > 0 then
		out_y = in_y * (radius/max_pos_axis_y)
	elseif in_y < 0 then
		out_y = in_y * (radius/-max_neg_axis_y)
	end

	-- make sure we are inside the containing circle (hypotenuse ("magnitude") of triangle x,y cannot be larger than radius)
	-- inspiration from http://blog.hypersect.com/interpreting-analog-sticks/
	magnitude = math.sqrt((out_x^2) + (out_y^2))
	if magnitude > radius then
		scale = radius/magnitude
		out_x = out_x * scale
		out_y = out_y * scale
	end

	-- add center offset (so neutral stick rests at the center and not 0,0 etc)
	-- also invert y because less y is more up, and more y is more down in our window
	out_x = out_x + center_x
	out_y = (-out_y) + center_y

	-- draw containing circle
	if containing_circle then
		forms.drawEllipse(pb, top_corner_x, top_corner_y, size, size, "gray")
	end

	if stick_line then
		if in_x == 0 and in_y == 0 then
			-- just put a blob in the middle
			forms.drawPixel(pb, out_x, out_y) -- center
			forms.drawPixel(pb, out_x, out_y-1) -- up
			forms.drawPixel(pb, out_x, out_y+1) -- down
			forms.drawPixel(pb, out_x-1, out_y) -- left
			forms.drawPixel(pb, out_x+1, out_y) -- right
		else
			forms.drawLine(pb, center_x, center_y, out_x, out_y) -- center
			forms.drawLine(pb, center_x, center_y-1, out_x, out_y-1) -- up
			forms.drawLine(pb, center_x, center_y+1, out_x, out_y+1) -- down
			forms.drawLine(pb, center_x-1, center_y, out_x-1, out_y) -- left
			forms.drawLine(pb, center_x+1, center_y, out_x+1, out_y) -- right
		end
	end

	if stick_cap then
		forms.drawEllipse(pb, out_x-stick_cap_size, out_y-stick_cap_size, stick_cap_size*2, stick_cap_size*2, "gray", "gray") -- stick cap
		forms.drawPixel(pb, out_x, out_y, "black") -- actual stick coordinate (black pixel in the middle)
	end
	
	if debug_stick then -- print all the debug info
		forms.drawString(pb, 90, 0, "OUT " .. tostring(math.floor(out_x)) .. "," .. tostring(math.floor(out_y)), "white") 
		forms.drawString(pb, 0, 90, "MAG: " .. tostring(magnitude), "yellow")
		forms.drawLine(pb, center_x, center_y, out_x, out_y, "yellow") -- hypotenuse or magnitude
		forms.drawLine(pb, center_x, center_y, out_x, center_y)
		forms.drawLine(pb, out_x, out_y, out_x, center_y)
	end

end

function draw_grid()
	w = 0
	while w < 300 do
		h = 0
		while h < 200 do
			forms.drawBox(pb, w, h, w+10, h+10, "white")
			h = h + 10
		end
		w = w + 10
	end

end

function check_buttons(input)
	-- For ellipses: Top X, Top Y, Width, Height
	-- For boxes: Top X, Top Y, Bottom X, Bottom Y
	if input["A"] then
		forms.drawEllipse(pb, 180, 65, 30, 30, "blue", "blue") -- fill with color if pressed
	else
		forms.drawEllipse(pb, 180, 65, 30, 30, "blue", "black") -- otherwise just outline
	end

	if input["B"] then
		forms.drawEllipse(pb, 160, 35, 30, 30, "green", "green")
	else
		forms.drawEllipse(pb, 160, 35, 30, 30, "green", "black")
	end

	if input["Z"] then
		forms.drawBox(pb, 115, 60, 135, 95, "gray", "gray")
	else
		forms.drawBox(pb, 115, 60, 135, 95, "gray", "black")
	end

	if input["R"] then
		forms.drawBox(pb, 245, 0, 270, 10, "gray", "gray")
	else
		forms.drawBox(pb, 245, 0, 270, 10, "gray", "black")
	end

	if input["Start"] then
		forms.drawEllipse(pb, 110, 20, 30, 30, "red", "red")
	else
		forms.drawEllipse(pb, 110, 20, 30, 30, "red", "black")
	end

	if input["C Up"] then
		forms.drawEllipse(pb, 220, 5, 20, 20, "yellow", "yellow")
	else
		forms.drawEllipse(pb, 220, 5, 20, 20, "yellow", "black")
	end

	if input["C Left"] then
		forms.drawEllipse(pb, 200, 25, 20, 20, "yellow", "yellow")
	else
		forms.drawEllipse(pb, 200, 25, 20, 20, "yellow", "black")
	end

	if input["C Right"] then
		forms.drawEllipse(pb, 240, 25, 20, 20, "yellow", "yellow")
	else
		forms.drawEllipse(pb, 240, 25, 20, 20, "yellow", "black")
	end

	if input["C Down"] then
		forms.drawEllipse(pb, 220, 45, 20, 20, "yellow", "yellow")
	else
		forms.drawEllipse(pb, 220, 45, 20, 20, "yellow", "black")
	end
end

-- init window and picture box
f = create_window();
pb = forms.pictureBox(f, 0, 0, 300, 200);

forms.setDefaultForegroundColor(pb,"white")
forms.setDefaultBackgroundColor(pb,"black")

max_pos_axis_x = 1
max_pos_axis_y = 1
max_neg_axis_x = -1
max_neg_axis_y = -1


while true do
	forms.clear(pb, "black")

	if show_grid then
		draw_grid() -- useful for placing buttons
	end
	
	local inputs = get_inputs(controller_port)

	update_stick(inputs["X Axis"], inputs["Y Axis"])

	check_buttons(inputs)

	-- update forms and advance emulator
	forms.refresh(pb)
	emu.frameadvance()
end