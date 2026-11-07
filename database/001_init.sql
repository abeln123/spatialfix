-- Enable native BM25 search extension
CREATE EXTENSION IF NOT EXISTS pg_textsearch;

-- 1. Relational B2B & Education Parts Catalog
CREATE TABLE IF NOT EXISTS marketplace_parts (
    part_sku TEXT PRIMARY KEY,
    hardware_model_id TEXT NOT NULL,
    mesh_node_name TEXT NOT NULL UNIQUE,
    part_name TEXT NOT NULL,
    technical_specs TEXT NOT NULL,
    tier_focus TEXT NOT NULL, -- 'b2b_service' or 'edu_kit'
    unit_price_cents INTEGER NOT NULL CHECK (unit_price_cents >= 0),
    stock_available INTEGER NOT NULL CHECK (stock_available >= 0),
    glb_preview_url TEXT NOT NULL,
    repair_steps_markdown TEXT NOT NULL
);

-- Native BM25 indexes for sub-10ms Gemini tool lookups
-- pg_textsearch BM25 does not support multicolumn indexes; one index per column.
CREATE INDEX IF NOT EXISTS idx_marketplace_parts_bm25_name
ON marketplace_parts USING bm25 (part_name) WITH (text_config = 'english');

CREATE INDEX IF NOT EXISTS idx_marketplace_parts_bm25_specs
ON marketplace_parts USING bm25 (technical_specs) WITH (text_config = 'english');

CREATE INDEX IF NOT EXISTS idx_marketplace_parts_bm25_mesh
ON marketplace_parts USING bm25 (mesh_node_name) WITH (text_config = 'english');

-- 2. Idempotent Command Log & B2B/Campus Requisition Orders
CREATE TABLE IF NOT EXISTS marketplace_orders (
    command_id UUID PRIMARY KEY,
    session_id TEXT NOT NULL,
    part_sku TEXT NOT NULL REFERENCES marketplace_parts(part_sku),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    use_case_tier TEXT NOT NULL CHECK (use_case_tier IN ('smb_service', 'education_lab')),
    total_cents INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. High-Frequency Webots & Vision Telemetry Hypertable with Hypercore
CREATE TABLE IF NOT EXISTS diagnostic_telemetry (
    time TIMESTAMPTZ NOT NULL DEFAULT now(),
    origin_time TIMESTAMPTZ NOT NULL,
    session_id TEXT NOT NULL,
    device_id TEXT NOT NULL,
    use_case_tier TEXT NOT NULL,
    detected_fault_mesh TEXT NULL,
    fault_code TEXT NOT NULL,
    voltage_mv DOUBLE PRECISION NOT NULL,
    current_ma DOUBLE PRECISION NOT NULL,
    temperature_c DOUBLE PRECISION NOT NULL,
    ai_confidence DOUBLE PRECISION NOT NULL
) WITH (
    tsdb.hypertable,
    tsdb.chunk_interval = '1 day',
    tsdb.enable_columnstore = true,
    tsdb.segmentby = 'device_id',
    tsdb.orderby = 'time DESC'
);

-- 4. Continuous Aggregate for Fleet MTBF & Classroom Lab Dashboards
CREATE MATERIALIZED VIEW IF NOT EXISTS telemetry_per_minute
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 minute', time) AS ts,
    device_id,
    use_case_tier,
    count(*) AS sample_count,
    avg(temperature_c) AS avg_temp_c,
    max(current_ma) AS peak_current_ma,
    min(voltage_mv) AS min_voltage_mv
FROM diagnostic_telemetry
GROUP BY 1, 2, 3
WITH NO DATA;

-- 5. Seed the 6 Canonical Rover-EDU1 / Commercial Rover Components
INSERT INTO marketplace_parts (
    part_sku, hardware_model_id, mesh_node_name, part_name, technical_specs, 
    tier_focus, unit_price_cents, stock_available, glb_preview_url, repair_steps_markdown
) VALUES
(
    'SF-ACT-BLDC42', 'ROVER-EDU1', 'mesh_actuator_fl', 
    'Smart Brushless Drive Actuator (42mm BLDC)', 
    '24V closed-loop servo hub motor, planetary gearbox 12:1, integrated hall encoder and thermal thermistor. Stall current 4.8A.',
    'smb_service', 14500, 42, '/models/rover_edu1.glb',
    '1. Isolate 24V motor bus via Fault-Injector or BMS toggle.\n2. Disconnect 4-pin Molex phase lead.\n3. Unbolt 4x M3 chassis mount screws.\n4. Swap actuator and run encoder zero-calibration.'
),
(
    'SF-OPT-LIDAR-VX2', 'ROVER-EDU1', 'mesh_lidar_turret_vx2', 
    '360 Solid-State LiDAR & Depth Turret (VX2)', 
    '10Hz optical time-of-flight laser scanner, 12m range, 24-pin FPC high-speed MIPI ribbon interface, 5V 600mA.',
    'smb_service', 28900, 18, '/models/rover_edu1.glb',
    '1. Power down 5V auxiliary rail.\n2. Flip zero-insertion-force (ZIF) bail on carrier PCB.\n3. Reseat or replace 24-pin FPC ribbon cable.\n4. Verify 10Hz turret spin lock.'
),
(
    'SF-EDU-PCB-V4', 'ROVER-EDU1', 'mesh_carrier_pcb_v4', 
    'Main Compute & Power Carrier Board V4', 
    'Dual synchronous 5V/12V buck converter rail, STM32 motor co-processor, exposed oscilloscope test points, hot-swap regulator socket.',
    'education_lab', 11000, 65, '/models/rover_edu1.glb',
    '1. Probe TP4 (5V Rail) to confirm voltage droop below 3.5V.\n2. Pull faulted 5V synchronous buck regulator module from socket U2.\n3. Insert replacement regulator module and verify green rail LED.'
),
(
    'SF-PWR-LFP-4S', 'ROVER-EDU1', 'mesh_battery_pack_4s', 
    'Hot-Swappable LiFePO4 Smart Battery Pack (4S 12.8V)', 
    '6000mAh LiFePO4 chemistry, integrated CAN-bus BMS, graphite thermal interface pad.',
    'smb_service', 9500, 30, '/models/rover_edu1.glb',
    '1. Release rear battery latch.\n2. Slide out depleted/faulted 4S pack.\n3. Inspect graphite thermal pad and slide in balanced replacement pack.'
),
(
    'SF-EDU-INJECT-01', 'ROVER-EDU1', 'mesh_fault_injector_key', 
    'Instructor Classroom Fault-Injector Dongle', 
    'Digital-physical lab switchboard allowing instructors to inject open-circuit, thermal runaway, and bus droop faults safely.',
    'education_lab', 6500, 50, '/models/rover_edu1.glb',
    '1. Connect dongle to J9 diagnostic header.\n2. Select lab fault profile via HUD or Webots Supervisor.\n3. Clear fault state once student completes diagnosis.'
),
(
    'SF-EDU-CHASSIS-01', 'ROVER-EDU1', 'mesh_chassis_frame', 
    'Anodized 6061-T6 Aluminum Modular Rover Chassis', 
    'CNC-machined structural baseplate with integrated heat-dissipation channels and DIN mounting rails.',
    'education_lab', 8500, 25, '/models/rover_edu1.glb',
    '1. Inspect frame grounding strap.\n2. Torque corner suspension mounts to 1.8 Nm.'
)
ON CONFLICT (part_sku) DO NOTHING;
