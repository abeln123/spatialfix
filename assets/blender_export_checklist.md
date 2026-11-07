# Blender export checklist (canonical mesh IDs)

Object names in Blender **must** match these `mesh_id` values exactly before export to glTF / Webots:

| mesh_id | SKU |
|---|---|
| `mesh_chassis_frame` | `SF-EDU-CHASSIS-01` |
| `mesh_carrier_pcb_v4` | `SF-EDU-PCB-V4` |
| `mesh_actuator_fl` | `SF-ACT-BLDC42` |
| `mesh_lidar_turret_vx2` | `SF-OPT-LIDAR-VX2` |
| `mesh_battery_pack_4s` | `SF-PWR-LFP-4S` |
| `mesh_fault_injector_key` | `SF-EDU-INJECT-01` |

Do not invent alternate names (`Chassis`, `pcb_v4`, etc.). Gemini prompts and Three.js picking should also refer only to these identifiers.
