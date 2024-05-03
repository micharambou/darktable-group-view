local dt = require("darktable")
local du = require("lib/dtutils")

local MODULE = "group-view"

du.check_min_api_version("9.1.0", MODULE)

local group_view_active = false
local collection_rules = {}
local selected_images = {}

local function tablelength(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

local function cleanup()
	dt.gui.libs.collect.filter(collection_rules)
end

cleanup()

local function toogle_group_view(_, _)
	if not group_view_active then
		group_view_active = true
		local image = table.unpack(dt.gui.selection())
		collection_rules = dt.gui.libs.collect.filter()
		local filter_rule = dt.gui.libs.collect.new_rule()
		filter_rule.mode = "DT_LIB_COLLECT_MODE_AND"
		filter_rule.data = tostring(image.group_leader.id)
		filter_rule.item = "DT_COLLECTION_PROP_GROUP_ID"
		table.insert(collection_rules, filter_rule)
		collection_rules = dt.gui.libs.collect.filter(collection_rules)
		return { image }
	else
		group_view_active = false
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
