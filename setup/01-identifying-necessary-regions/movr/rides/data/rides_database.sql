CREATE DATABASE movr_rides;

CREATE TABLE movr_rides.rides (
	id UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
	vehicle_id UUID NOT NULL,
	user_email STRING NOT NULL,
	start_ts TIMESTAMP NOT NULL,
	end_ts TIMESTAMP DEFAULT NULL
);

CREATE TABLE movr_rides.events (
    id UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    ts TIMESTAMP DEFAULT now() NOT NULL,
    event_type STRING NOT NULL,
    event_data JSON NOT NULL
);