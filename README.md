darktable group-view
===============================
This adds a shortcut and a "Toogle group-view" button in darktable's lighttable selection module.
In group-view mode, only images that are grouped together are shown.

To achieve this, a temporary tag "group-view" becomes attached to affected images and a collection module preset of the same name becomes activated. Once `group-view` mode is left, all attached `group-view` tags become cleaned up.

Installation
------------
### Using script_manager

* open `action` `install/update scripts`
* in the URL box enter `https://github.com/micharambou/darktable-group-view.git`
* in the category box enter `dt-group-view`
* click the `Install additional scripts` button
  
### Create collection preset `group-view`

* In Collection module add a new collection preset and name it `group-view`. Select `tag` as filter criteria. You may have to create the corresponding tag once by yourself to be able to select it as a value for your preset.

Usage
-----
Select a single image and hit `Toogle group-view` button or press assigned shortcut to enable group-view mode.
To get back to your previous collection, hit the button again. 