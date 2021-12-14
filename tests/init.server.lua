-- Lest chokes on .server.lua files so we pass the `spec` module to it and mount
-- this file in our project so we can run tests in Studio.
require(script.spec)
