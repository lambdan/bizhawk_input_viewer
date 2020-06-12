controller_port = 1 -- which controller
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
	-- For boxes: Top X, Top Y, Bottom X, Bottom Y
	if input["Up"] then
		forms.drawBox(pb, 30, 20, 50, 40, "gray", "white") -- fill if pressed
	else
		forms.drawBox(pb, 30, 20, 50, 40, "gray", "black") -- just outline if not
	end
	if input["Down"] then
		forms.drawBox(pb, 30, 60, 50, 80, "gray", "white")
	else
		forms.drawBox(pb, 30, 60, 50, 80, "gray", "black")
	end

	if input["Left"] then
		forms.drawBox(pb, 10, 40, 30, 60, "gray", "white")
	else
		forms.drawBox(pb, 10, 40, 30, 60, "gray", "black")
	end

	if input["Right"] then
		forms.drawBox(pb, 50, 40, 70, 60, "gray", "white")
	else
		forms.drawBox(pb, 50, 40, 70, 60, "gray", "black")
	end

	if input["B"] then
		forms.drawEllipse(pb, 190, 40, 30, 30, "red", "red")
	else
		forms.drawEllipse(pb, 190, 40, 30, 30, "red", "black")
	end

	if input["A"] then
		forms.drawEllipse(pb, 230, 40, 30, 30, "red", "red")
	else
		forms.drawEllipse(pb, 230, 40, 30, 30, "red", "black")
	end

	if input["Select"] then
		forms.drawBox(pb, 90, 60, 120, 70, "gray", "white")
	else
		forms.drawBox(pb, 90, 60, 120, 70, "gray", 0xFF333333)
	end

	if input["Start"] then
		forms.drawBox(pb, 140, 60, 170, 70, "gray", "white")
	else
		forms.drawBox(pb, 140, 60, 170, 70, "gray", 0xFF333333)
	end

end

-- init window and picture box
f = create_window();
pb = forms.pictureBox(f, 0, 0, 300, 200);

forms.setDefaultForegroundColor(pb,"white")
forms.setDefaultBackgroundColor(pb,"black")

while true do
	forms.clear(pb, "black")

	if show_grid then
		draw_grid() -- useful for placing buttons
	end
	
	local inputs = get_inputs(controller_port)

	check_buttons(inputs)

	-- update forms and advance emulator
	forms.refresh(pb)
	emu.frameadvance()
end