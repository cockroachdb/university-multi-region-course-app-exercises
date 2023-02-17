CREATE DATABASE movr_pricing;

ALTER DATABASE movr_pricing SET PRIMARY REGION "us-west";
ALTER DATABASE movr_pricing ADD REGION "us-central";
ALTER DATABASE movr_pricing ADD REGION "us-east";

CREATE TABLE movr_pricing.promo_codes (
    code STRING PRIMARY KEY,
    description STRING NOT NULL, 
    creation_time TIMESTAMP NOT NULL, 
    expiration_time TIMESTAMP NOT NULL, 
    rules JSONB NOT NULL
);

CREATE TABLE movr_pricing.vip_rates (
    rate_code STRING PRIMARY KEY,
    market STRING NOT NULL,
    description STRING NOT NULL, 
    creation_time TIMESTAMP NOT NULL 
);

ALTER TABLE movr_pricing.promo_codes SET locality GLOBAL;

ALTER TABLE movr_pricing.vip_rates SET LOCALITY REGIONAL BY TABLE IN "us-west";
