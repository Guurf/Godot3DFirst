# MIT License
#
# Copyright (c) 2023 Mark McKay
# https://github.com/blackears/cyclopsLevelBuilder
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends SpinBox
class_name LineEditorInt

var resource:Resource:
	get:
		return resource
	set(value):
		resource = value
		dirty = true
		
var prop_name:String:
	get:
		return prop_name
	set(value):
		prop_name = value
		dirty = true

var dirty = true

func update_from_resource():
	#print("update_from_resource()")
	if resource:
		#print("resource %s" % resource)
		#print("prop_name %s" % prop_name)
		var result = resource.get(prop_name)
		#print("result %s" % result)
		if result != null:
			value = result

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dirty:
		update_from_resource()
		dirty = false


func _on_value_changed(value):
#	print("_on_value_changed(value)")
	if resource:
#		print("prop_name %s" % prop_name)
#		print("value %s" % value)
		resource.set(prop_name, value)
