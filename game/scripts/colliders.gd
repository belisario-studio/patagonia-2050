# lint-ignore-file: One-shot batch tool for generating .tscn collider scenes from .glb assets
@tool
extends EditorScript

const SOURCE_FACTORY := "res://assets/FPS_Factory_Area"
const DEST_FACTORY := "res://assets/FPS-Factory-Area"
const SOURCE_WAREHOUSE := "res://assets/FPS_Warehouse_Environment"
const DEST_WAREHOUSE := "res://assets/FPS-Warehouse-Environment"


func _run():
	_process_directory(SOURCE_FACTORY, DEST_FACTORY)
	_process_directory(SOURCE_WAREHOUSE, DEST_WAREHOUSE)


func _process_directory(source_dir: String, dest_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(dest_dir)
	var glb_paths := _collect_glbs(source_dir)
	print("Found %d glb files in %s" % [glb_paths.size(), source_dir])
	for glb_path in glb_paths:
		_convert_glb(glb_path, dest_dir)


func _collect_glbs(path: String) -> Array:
	var results: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("Could not open directory %s" % path)
		return results

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var full_path := path.path_join(entry)
		_collect_entry(full_path, dir.current_is_dir(), results)
		entry = dir.get_next()
	dir.list_dir_end()
	return results


func _collect_entry(full_path: String, is_dir: bool, results: Array) -> void:
	if is_dir:
		results.append_array(_collect_glbs(full_path))
		return
	if full_path.ends_with(".glb"):
		results.append(full_path)


func _convert_glb(glb_path: String, dest_dir: String) -> void:
	var packed_source := load(glb_path)
	if packed_source == null:
		push_warning("Could not load %s" % glb_path)
		return

	var instance: Node = packed_source.instantiate()
	_add_colliders(instance)
	_set_owners(instance, instance)

	var packed := PackedScene.new()
	var err := packed.pack(instance)
	if err != OK:
		push_warning("Could not pack %s (err %d)" % [glb_path, err])
		return

	var file_name := glb_path.get_file().get_basename()
	var dest_path := dest_dir.path_join(file_name + ".tscn")
	var save_err := ResourceSaver.save(packed, dest_path)
	if save_err != OK:
		push_warning("Could not save %s (err %d)" % [dest_path, save_err])
		return
	print("Saved %s" % dest_path)


func _add_colliders(node: Node) -> void:
	if node is MeshInstance3D:
		node.create_trimesh_collision()
	for child in node.get_children():
		_add_colliders(child)


func _set_owners(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		_set_owners(child, root)
