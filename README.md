#godot-voxel
A simple voxel model editor for layer-based editing in Godot.

## Status
Initial version focused on:
- Editing cell color per layer.
- Layer selection.
- Copy/Paste between layers.
- Model resource saving.

## Quick Start
2. Open the scene [src/editor/editor.tscn](src/editor/editor.tscn).
3. Use LayerPicker to select the active layer.
4. Edit colors in the grid.
5. Use Copy to copy the active layer.
6. Switch to another layer and use Paste to paste the colors.
7. Use Save to persist the model resource at its current path.

## Editing Resources
The editor scene points by default to [tests/apple/apple.tres](tests/apple/apple.tres).

To edit a different model:
1. Select the Editor root node in the scene.
2. Change the model property to a different VoxelModel resource.
3. Save from the Save button to persist changes.

## Color Shortcuts (Input Map)
Actions are defined in [project.godot](project.godot) and can be remapped in Project Settings → Input Map:
- darker
- lighter
- last_color
- copy
