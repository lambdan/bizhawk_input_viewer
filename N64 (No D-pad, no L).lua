controller_port = 1 -- which controller
debug_stick = false -- useful for debugging, shows x y coords and pythagorean theorem triangle etc
show_grid = false -- draw a 10x10 pixel grid, useful for placing buttons

forms.destroyall() -- close all Lua windows. this is probably mean to do because i think it closes other Lua scripts' windows too?

function create_window()
	local form = forms.newform(287, 142, "Input Viewer")
	return form
end

function get_inputs(controller_index)
	local input_array = joypad.get(controller_index);
	return input_array
end

function update_stick(x,y)
	-- this should probably be separated into 2 functions, like calculate_stick_draw() and draw_stick()
	top_corner_x = 20
	top_corner_y = 20
	size = 64
	radius = (size/2)
	stick_cap_size = (size/4)

	center_x = top_corner_x + radius
	center_y = top_corner_y + radius

	-- set scale by looking at max value that stick gives
	-- i just improvised this but *seems* to work fine?
	if x > max_axis then
		max_axis = x
	elseif y > max_axis then
		max_axis = y
	end
	scale_factor = (max_axis/size)

	if x ~= 0 then -- to prevent divide by 0
		x = x/scale_factor
	end
	if y ~= 0 then
		y = y/scale_factor
	end

	-- check if inside circle
	hypo = math.sqrt((x^2)+(y^2))
	while hypo > radius do
		if x > 0 then
			x = x - 1
		else
			x = x + 1
		end

		if y > 0 then
			y = y - 1
		else
			y = y + 1
		end

		hypo = math.sqrt((x^2)+(y^2))
	end

	if debug_stick then
		forms.drawString(pb, 90, 0, "X=" .. tostring(x), "white") 
		forms.drawString(pb, 90, 10, "Y=" .. tostring(y), "white")
		forms.drawString(pb, 90, 42, "HYPO: " .. tostring(hypo), "yellow")
	end

	-- add center offset (so neutral stick rests at the center and not 0,0 etc)
	x = x + center_x
	y = (-y) + center_y
		
	forms.drawEllipse(pb, top_corner_x, top_corner_y, size, size, "gray") -- outer ring
	forms.drawEllipse(pb, x-stick_cap_size, y-stick_cap_size, stick_cap_size*2, stick_cap_size*2, "gray", "gray") -- actual stick
	forms.drawPixel(pb, x, y, "black") -- middle of stick

	if debug_stick then
		forms.drawLine(pb, center_x, center_y, x, y, "yellow") -- from center to point (hypotenuse)
		forms.drawLine(pb, center_x, center_y, x, center_y)
		forms.drawLine(pb, x, y, x, center_y)
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

max_axis = 64

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