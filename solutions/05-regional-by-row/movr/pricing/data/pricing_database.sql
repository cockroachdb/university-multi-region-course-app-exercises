CREATE DATABASE movr_pricing;

ALTER DATABASE movr_pricing SET PRIMARY REGION "us-east";
ALTER DATABASE movr_pricing ADD REGION "us-central";
ALTER DATABASE movr_pricing ADD REGION "us-west";

CREATE TABLE movr_pricing.promo_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code STRING NOT NULL,
    description STRING NOT NULL, 
    creation_time TIMESTAMP NOT NULL, 
    expiration_time TIMESTAMP NOT NULL, 
    rules JSONB NOT NULL
);

ALTER TABLE movr_pricing.promo_codes SET locality GLOBAL;
