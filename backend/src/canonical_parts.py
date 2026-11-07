"""Canonical mesh ↔ SKU mapping for SpatialFix.

These identifiers must stay identical across Blender, Webots, Tiger Cloud,
Gemini, and Three.js. Prefer loading assets/canonical_parts.json in production;
this module mirrors that contract for backend services.
"""

from __future__ import annotations

from typing import Final, TypedDict


class Part(TypedDict):
    mesh_id: str
    sku: str
    name: str


CANONICAL_PARTS: Final[tuple[Part, ...]] = (
    {"mesh_id": "mesh_chassis_frame", "sku": "SF-EDU-CHASSIS-01", "name": "Chassis Frame"},
    {"mesh_id": "mesh_carrier_pcb_v4", "sku": "SF-EDU-PCB-V4", "name": "Carrier PCB v4"},
    {"mesh_id": "mesh_actuator_fl", "sku": "SF-ACT-BLDC42", "name": "Front-Left Actuator"},
    {"mesh_id": "mesh_lidar_turret_vx2", "sku": "SF-OPT-LIDAR-VX2", "name": "LiDAR Turret VX2"},
    {"mesh_id": "mesh_battery_pack_4s", "sku": "SF-PWR-LFP-4S", "name": "Battery Pack 4S"},
    {"mesh_id": "mesh_fault_injector_key", "sku": "SF-EDU-INJECT-01", "name": "Fault Injector Key"},
)

MESH_TO_SKU: Final[dict[str, str]] = {p["mesh_id"]: p["sku"] for p in CANONICAL_PARTS}
SKU_TO_MESH: Final[dict[str, str]] = {p["sku"]: p["mesh_id"] for p in CANONICAL_PARTS}
