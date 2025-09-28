# GTNH Open Computers Projects

IMPORTANT ASSUMPTIONS
1. Adapter + MFU to every controller in the line
2. EXACTLY one transposer per purification unit, connected to non-ME input hatch/bus for most, connected to an ingredient buffer for T4/T5
3. Machines with both fluid and solid inputs have all fluids in type-locked tanks, all solids present
4. All item buffers are ME interfaces
5. All fluid buffers have size specified in config
6. All fluids other than transposer buffers (transposer buffers should be exported, not storage bused) stored in AE network with Adapter + MFU controller connection

I would have used dual interfaces for ALL fluid buffers instead of just some, but that would have severely limited throughput on ozone

Install:

```
wget https://raw.githubusercontent.com/code-upload-account-temp/GTNH-Open-Computers-Projects/refs/heads/main/water/Setup.lua && Setup
```