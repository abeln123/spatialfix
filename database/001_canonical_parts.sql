-- Canonical mesh ↔ SKU mapping for SpatialFix (Tiger Cloud / Timescale).
-- Mesh identifiers must stay identical across Blender, Webots, Gemini, and Three.js.

CREATE TABLE IF NOT EXISTS parts (
  mesh_id   TEXT PRIMARY KEY,
  sku       TEXT NOT NULL UNIQUE,
  name      TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO parts (mesh_id, sku, name) VALUES
  ('mesh_chassis_frame',      'SF-EDU-CHASSIS-01', 'Chassis Frame'),
  ('mesh_carrier_pcb_v4',     'SF-EDU-PCB-V4',     'Carrier PCB v4'),
  ('mesh_actuator_fl',        'SF-ACT-BLDC42',     'Front-Left Actuator'),
  ('mesh_lidar_turret_vx2',   'SF-OPT-LIDAR-VX2',  'LiDAR Turret VX2'),
  ('mesh_battery_pack_4s',    'SF-PWR-LFP-4S',     'Battery Pack 4S'),
  ('mesh_fault_injector_key', 'SF-EDU-INJECT-01',  'Fault Injector Key')
ON CONFLICT (mesh_id) DO UPDATE
SET sku  = EXCLUDED.sku,
    name = EXCLUDED.name;
