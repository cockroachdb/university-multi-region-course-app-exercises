CREATE DATABASE movr_users;

CREATE TABLE movr_users.users (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	email STRING NOT NULL,
	city STRING NULL,
	last_name STRING NOT NULL,
	first_name STRING NOT NULL,
	phone_numbers STRING[] NOT NULL
);

ALTER DATABASE movr_users SET PRIMARY REGION "us-east";
ALTER DATABASE movr_users ADD REGION "us-central";
ALTER DATABASE movr_users ADD REGION "us-west";