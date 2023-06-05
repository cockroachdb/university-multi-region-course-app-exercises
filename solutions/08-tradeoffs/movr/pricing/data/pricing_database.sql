CREATE DATABASE movr_pricing;

ALTER DATABASE movr_pricing SET PRIMARY REGION "us-east";
ALTER DATABASE movr_pricing ADD REGION "us-central";
ALTER DATABASE movr_pricing ADD REGION "us-west";
ALTER DATABASE movr_pricing ADD REGION "eu-west";

CREATE TABLE movr_pricing.promo_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code STRING NOT NULL,
    description STRING NOT NULL, 
    creation_time TIMESTAMP NOT NULL, 
    expiration_time TIMESTAMP NOT NULL, 
    rules JSONB NOT NULL
);

CREATE TABLE movr_pricing.vip_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rate_code STRING NOT NULL,
    market STRING NOT NULL,
    description STRING NOT NULL, 
    creation_time TIMESTAMP NOT NULL 
);

ALTER TABLE movr_pricing.promo_codes SET locality GLOBAL;
ALTER TABLE movr_pricing.vip_rates SET LOCALITY REGIONAL BY TABLE IN "us-west";

ALTER DATABASE movr_pricing PLACEMENT DEFAULT;
ALTER DATABASE movr_pricing ADD SUPER REGION "usa" VALUES "us-east", "us-central", "us-west";