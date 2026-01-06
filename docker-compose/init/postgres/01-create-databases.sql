-- Create databases for each service
CREATE DATABASE smimekeys_client;
CREATE DATABASE policy;
CREATE DATABASE idagent;
CREATE DATABASE mxengine;

-- Grant privileges (using default postgres user)
GRANT ALL PRIVILEGES ON DATABASE smimekeys_client TO postgres;
GRANT ALL PRIVILEGES ON DATABASE policy TO postgres;
GRANT ALL PRIVILEGES ON DATABASE idagent TO postgres;
GRANT ALL PRIVILEGES ON DATABASE mxengine TO postgres;
