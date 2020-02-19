# Direct-mapped-cache-memory

Implemented a direct mapped cache. The cache has one interface (input/output ports) on the processor side, and one on the memory side.

On the processor side, signals are: PRead_request (input), PWrite_request (input), PWrite_data (input), PRead_data (output), PRead_ready (output), PWrite_done (output), PAddress (input)
On the memory side, signals are: MRead_request (output), MWrite_request (output), MWrite_data (output), MRead_data (input), MRead_ready (input), MWrite_done (input), MAddress (output)
Apart from these, cache also has clock (input) and reset (input) signals.

Data from processor side is 8 bits (read and write). Data written to memory is 8 bits, but data read from memory is 32 bits (one cache block). There is an 8 bit address space, and that cache contains 8 blocks (each 32 bits). Whenever a processor requests something, cache responds in the following clock cycle (if it is a hit), or whenever data has arrived from memory if it is a miss.Read_request and write_request signals (from both processor and cache) always go back down to “0” before the next access can begin. In this, I implemented blocks and tags, plus a valid bit for each tag using a state machine to drive cache behaviour. If processor writes and it’s a cache hit, both cache and memory must be updated (write-through). If processor writes and it’s a cache miss, only memory is updated (no allocate-on-miss).
