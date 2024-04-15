local dt = require("darktable")
local du = require("lib/dtutils")

local MODULE = "group-view"

du.check_min_api_version("9.1.0", MODULE)

if dt.tags.find("group-view") == nil then
	dt.tags.create("group-view")
end
local filter_tag = dt.tags.find("group-view")

local group_view_active = false
local previous = nil

local filter_rule = dt.gui.libs.collect.new_rule()
filter_rule.mode = "DT_LIB_COLLECT_MODE_AND"
filter_rule.data = "group-view"
filter_rule.item = "DT_COLLECTION_PROP_TAG"

local function tablelength(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

local function cleanup()
	for _, image in pairs(dt.tags.get_tagged_images(filter_tag)) do
		dt.tags.detach(filter_tag, image)
	end
end

cleanup()

local function append_filter_rule_to_collection()
	previous = dt.gui.libs.collect.filter()
	local current = {}
	for _, prev_rule in pairs(previous) do
		table.insert(current, prev_rule)
	end
	table.insert(current, filter_rule)
	dt.gui.libs.collect.filter(current)
end

local selected_images = {}

local function toogle_group_view(_, _)
	if not group_view_active then
		group_view_active = true
		local image = table.unpack(dt.gui.selection())
		local t_image_group = image:get_group_members()
		for _, image in pairs(t_image_group) do
			dt.tags.attach(filter_tag, image)
		end
		-- dt.gui.action("lib/collect/preset/group-view", 1, 000)
        append_filter_rule_to_collection()
		return { image }
	else
		group_view_active = false
		dt.gui.action("lib/collect/jump back to previous collection", 1, 000)
		cleanup()
		return selected_images
	end
end

local function destroy()
	cleanup()
	dt.gui.libs.select.destroy_selection(MODULE)
	dt.destroy_event("group-view: image selection changed", "selection-changed")
end

dt.gui.libs.select.register_selection(
	MODULE,
	"Toogle group-view",
	toogle_group_view,
	"toogle group view to show only group members of currently selected image"
)

dt.gui.libs.select.set_sensitive(MODULE, false)

dt.register_event("group-view: image selection changed", "selection-changed", function(_)
	if next(dt.gui.selection()) == nil and not group_view_active then
		dt.gui.libs.select.set_sensitive(MODULE, false)
		selected_images = nil
		cleanup()
	end
	if tablelength(dt.gui.selection()) == 1 then
		dt.gui.libs.select.set_sensitive(MODULE, true)
		selected_images = dt.gui.selection()
	end
	if tablelength(dt.gui.selection()) > 1 and not group_view_active then
		dt.gui.libs.select.set_sensitive(MODULE, false)
		selected_images = dt.gui.selection()
	end
end)

dt.register_event("toogle group view", "shortcut", function()
	if next(dt.gui.selection()) == nil and not group_view_active then
		dt.gui.libs.select.set_sensitive(MODULE, false)
		selected_images = nil
		cleanup()
	end
	if next(dt.gui.selection()) == nil and group_view_active then
		selected_images = nil
		toogle_group_view()
	end
	if tablelength(dt.gui.selection()) == 1 then
		dt.gui.libs.select.set_sensitive(MODULE, true)
		selected_images = dt.gui.selection()
		toogle_group_view()
	end
	if tablelength(dt.gui.selection()) > 1 and not group_view_active then
		dt.gui.libs.select.set_sensitive(MODULE, false)
		selected_images = dt.gui.selection()
	end
end, "toogle group view")

local script_data = {}
script_data.destroy = destroy
return script_data
