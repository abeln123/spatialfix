"""Canonical mesh ↔ SKU mapping for the Webots rover supervisor.

DEF names / Solid names in the .wbt world must match mesh_id exactly.
"""

CANONICAL_PARTS = (
    {"mesh_id": "mesh_chassis_frame", "sku": "SF-EDU-CHASSIS-01", "name": "Chassis Frame"},
    {"mesh_id": "mesh_carrier_pcb_v4", "sku": "SF-EDU-PCB-V4", "name": "Carrier PCB v4"},
    {"mesh_id": "mesh_actuator_fl", "sku": "SF-ACT-BLDC42", "name": "Front-Left Actuator"},
    {"mesh_id": "mesh_lidar_turret_vx2", "sku": "SF-OPT-LIDAR-VX2", "name": "LiDAR Turret VX2"},
    {"mesh_id": "mesh_battery_pack_4s", "sku": "SF-PWR-LFP-4S", "name": "Battery Pack 4S"},
    {"mesh_id": "mesh_fault_injector_key", "sku": "SF-EDU-INJECT-01", "name": "Fault Injector Key"},
)

MESH_TO_SKU = {p["mesh_id"]: p["sku"] for p in CANONICAL_PARTS}
SKU_TO_MESH = {p["sku"]: p["mesh_id"] for p in CANONICAL_PARTS}
