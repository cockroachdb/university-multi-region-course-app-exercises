CREATE DATABASE movr_users;

CREATE TABLE movr_users.users (
	email STRING PRIMARY KEY,
	city STRING NULL,
	last_name STRING NOT NULL,
	first_name STRING NOT NULL,
	phone_numbers STRING[] NOT NULL
);

ALTER DATABASE movr_users SET PRIMARY REGION "us-east";
ALTER DATABASE movr_users ADD REGION "us-central";
ALTER DATABASE movr_users ADD REGION "us-west";

ALTER TABLE movr_users.users SET LOCALITY REGIONAL BY ROW;

INSERT INTO movr_users.users (email,city,last_name,first_name,phone_numbers,crdb_region)
VALUES
  ('in.felis.nulla@protonmail.edu','Zaria','Daugherty','Tamara', ARRAY['505-505-5050'],'us-east'),
  ('etiam.laoreet@aol.couk','San Rafael','Tucker','Kareem',ARRAY['505-505-5051'],'us-west'),
  ('nullam.ut@yahoo.com','Bremerhaven','Nolan','Seth',ARRAY['505-505-5052'],'us-east'),
  ('elit.pellentesque@aol.couk','Ciplet','Daniels','Carolyn',ARRAY['505-505-5053'],'us-west'),
  ('ut.eros@outlook.couk','Torrevieja','Morton','Simon',ARRAY['505-505-5054'],'us-east'), 
  ('neque.tellus@google.com','Rastatt','Howard','Penelope',ARRAY['505-505-5055'],'us-west'),
  ('mi@aol.com','Roodepoort','Jacobson','Mason',ARRAY['505-505-5056'],'us-central'),
  ('morbi.accumsan@yahoo.com','Landeck','Harper','Theodore',ARRAY['505-505-5057'],'us-west'),
  ('elit.a.feugiat@protonmail.net','Uruapan','Shelton','Violet',ARRAY['505-505-5058'],'us-central'),
  ('magna.a.neque@google.net','Adana','Jensen','Hayes',ARRAY['505-505-5059'],'us-central');