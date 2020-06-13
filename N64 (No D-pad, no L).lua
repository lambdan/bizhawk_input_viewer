-- settings
controller_port = 1 -- which controller
debug_stick = false -- useful for debugging, shows x y coords and pythagorean theorem triangle etc
show_grid = false -- draw a 10x10 pixel grid, useful for placing buttons

-- visual settings
containing_circle = true -- show a circle surrounding the joystick
containing_circle_background = true -- fill containing circle
stick_stem = true -- show the stick stem (its a line)
stem_thickness = 4 -- pixels
stick_cap = true -- show the "thumb cap" (its a ring with rings)
stick_cap_ring_gap = 4 -- pixels, should be an even number otherwise rings wont be symmetrical

-- colors
stick_cap_ring_color = 0xffcfd0d2
stick_cap_between_rings_color = 0xff979b9c
stick_stem_color = 0xff56575a
stick_container_color = 0xff5b5e5f
stick_container_inner_color = 0xff2a2c2e
a_color = 0xff0052b6
b_color = 0xff009556
c_color = 0xffffc000
start_color = 0xffdc0013
z_color = 0xff5b5c5e
r_color = 0xff5b5c5e
background_color = "black"
default_color = "pink" -- this is used for elements without color set like debug text

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

	-- center of the containing circle
	center_x = top_corner_x + radius
	center_y = top_corner_y + radius

	local out_x = 0
	local out_y = 0

	if debug_stick then
		forms.drawString(pb, 0, 0, "IN " .. tostring(math.floor(in_x)) .. "," .. tostring(math.floor(in_y))) 
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
		if containing_circle_background then
			forms.drawEllipse(pb, top_corner_x, top_corner_y, size, size, stick_container_color, stick_container_inner_color) -- outer grey
		else
			forms.drawEllipse(pb, top_corner_x, top_corner_y, size, size, stick_container_color)
		end
	end

	if stick_stem then
		-- center should always show
		forms.drawEllipse(pb, center_x-stem_thickness, center_y-stem_thickness, stem_thickness*2, stem_thickness*2, stick_stem_color, stick_stem_color)
		-- draw destination if stick_cap not on
		if not stick_cap then
			forms.drawEllipse(pb, out_x-stem_thickness, out_y-stem_thickness, stem_thickness*2, stem_thickness*2, stick_stem_color, stick_stem_color)
		end

		-- draw lines 
		forms.drawLine(pb, center_x, center_y, out_x, out_y, stick_stem_color) -- center line
		local i = 0
		while i <= stem_thickness do -- then draw surrounding lines to make it thicker
			forms.drawLine(pb, center_x, center_y-i, out_x, out_y-i, stick_stem_color) -- up
			forms.drawLine(pb, center_x, center_y+i, out_x, out_y+i, stick_stem_color) -- down
			forms.drawLine(pb, center_x-i, center_y, out_x-i, out_y, stick_stem_color) -- left
			forms.drawLine(pb, center_x+i, center_y, out_x+i, out_y, stick_stem_color) -- right
			i = i + 1
		end
	end

	if stick_cap then
		ring1 = stick_cap_ring_gap*4
		ring2 = stick_cap_ring_gap*3
		ring3 = stick_cap_ring_gap*2
		ring4 = stick_cap_ring_gap*1
		forms.drawEllipse(pb, out_x-ring1, out_y-ring1, ring1*2, ring1*2, stick_cap_between_rings_color, stick_cap_between_rings_color) -- outer ring should have no outline
		forms.drawEllipse(pb, out_x-ring2, out_y-ring2, ring2*2, ring2*2, stick_cap_ring_color, stick_cap_between_rings_color)
		forms.drawEllipse(pb, out_x-ring3, out_y-ring3, ring3*2, ring3*2, stick_cap_ring_color, stick_cap_between_rings_color)
		forms.drawEllipse(pb, out_x-ring4, out_y-ring4, ring4*2, ring4*2, stick_cap_ring_color, stick_cap_between_rings_color)
		forms.drawEllipse(pb, out_x-1, out_y-1, 2, 2, stick_stem_color)
		--forms.drawPixel(pb, out_x, out_y, stick_stem_color) -- actual stick coordinate (pixel in the middle)
	end
	
	if debug_stick then -- print all the debug info
		forms.drawString(pb, 90, 0, "OUT " .. tostring(math.floor(out_x)) .. "," .. tostring(math.floor(out_y))) 
		forms.drawString(pb, 0, 90, "MAG: " .. tostring(magnitude))
		forms.drawLine(pb, center_x, center_y, out_x, out_y) -- hypotenuse or magnitude
		forms.drawLine(pb, center_x, center_y, out_x, center_y)
		forms.drawLine(pb, out_x, out_y, out_x, center_y)
	end

end

function draw_grid()
	w = 0
	while w < 300 do
		h = 0
		while h < 200 do
			forms.drawBox(pb, w, h, w+10, h+10)
			h = h + 10
		end
		w = w + 10
	end

end

function check_buttons(input)
	-- For ellipses: Top X, Top Y, Width, Height
	-- For boxes: Top X, Top Y, Bottom X, Bottom Y
	if input["A"] then
		forms.drawEllipse(pb, 180, 65, 30, 30, a_color, a_color) -- fill with color if pressed
	else
		forms.drawEllipse(pb, 180, 65, 30, 30, a_color, background_color) -- otherwise just outline
	end

	if input["B"] then
		forms.drawEllipse(pb, 160, 35, 30, 30, b_color, b_color)
	else
		forms.drawEllipse(pb, 160, 35, 30, 30, b_color, background_color)
	end

	if input["Z"] then
		forms.drawBox(pb, 115, 60, 135, 95, z_color, z_color)
	else
		forms.drawBox(pb, 115, 60, 135, 95, z_color, background_color)
	end

	if input["R"] then
		forms.drawBox(pb, 245, 0, 270, 10, r_color, r_color)
	else
		forms.drawBox(pb, 245, 0, 270, 10, r_color, background_color)
	end

	if input["Start"] then
		forms.drawEllipse(pb, 110, 20, 30, 30, start_color, start_color)
	else
		forms.drawEllipse(pb, 110, 20, 30, 30, start_color, background_color)
	end

	if input["C Up"] then
		forms.drawEllipse(pb, 220, 5, 20, 20, c_color, c_color)
	else
		forms.drawEllipse(pb, 220, 5, 20, 20, c_color, background_color)
	end

	if input["C Left"] then
		forms.drawEllipse(pb, 200, 25, 20, 20, c_color, c_color)
	else
		forms.drawEllipse(pb, 200, 25, 20, 20, c_color, background_color)
	end

	if input["C Right"] then
		forms.drawEllipse(pb, 240, 25, 20, 20, c_color, c_color)
	else
		forms.drawEllipse(pb, 240, 25, 20, 20, c_color, background_color)
	end

	if input["C Down"] then
		forms.drawEllipse(pb, 220, 45, 20, 20, c_color, c_color)
	else
		forms.drawEllipse(pb, 220, 45, 20, 20, c_color, background_color)
	end
end

-- init window and picture box
f = create_window();
pb = forms.pictureBox(f, 0, 0, 300, 200);

forms.setDefaultForegroundColor(pb,default_color)
forms.setDefaultBackgroundColor(pb,background_color)

max_pos_axis_x = 1
max_pos_axis_y = 1
max_neg_axis_x = -1
max_neg_axis_y = -1


while true do
	forms.clear(pb, background_color)

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