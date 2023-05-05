CREATE DATABASE movr_users;

CREATE TABLE movr_users.users (
	id UUID NOT NULL DEFAULT gen_random_uuid(),
	email STRING NOT NULL,
	city STRING NULL,
	last_name STRING NOT NULL,
	first_name STRING NOT NULL,
	phone_numbers STRING[] NOT NULL,
	CONSTRAINT users_pkey PRIMARY KEY (city ASC, id ASC)
);