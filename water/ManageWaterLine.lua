require("Config");
require("Constants");
require("Utility")
require("NetworkDiscovery") -- discovery logic is here

-- IMPORTANT: Read the readme, it documents assumptions and setup requirements

-- Turn everything except the main plant off while we work out what we want to run, this won't interrupt existing cycles, just present a new one from starting
if (PlantControllers.t1 ~= nil) then
    PlantControllers.t1.setWorkAllowed(false)
end
if (PlantControllers.t2 ~= nil) then
    PlantControllers.t2.setWorkAllowed(false)
end
if (PlantControllers.t3 ~= nil) then
    PlantControllers.t3.setWorkAllowed(false)
end
if (PlantControllers.t4 ~= nil) then
    PlantControllers.t4.setWorkAllowed(false)
end
if (PlantControllers.t5 ~= nil) then
    PlantControllers.t5.setWorkAllowed(false)
end
if (PlantControllers.t6 ~= nil) then
    PlantControllers.t6.setWorkAllowed(false)
end

