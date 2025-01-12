# System Architecture

As with most of the undertone projects, underack is built with LFE/Erlang OTP. Of all its sibling projects, however, underack relies most heavily on OTP, gen_servers, supervision trees, and Erlang VM process management. Modular synthesis not only rests solidly in the realm of soft real-time programming, it is an intensely state-driven endeavour.

The top-level OTP gen_server represents a Eurorack assembly: power, bus board, modules, and patch cables. Each module that is added to the rack is a child gen_server with the ability to ask the top-level gen_server to update is state with info the child has (e.g., sharing current BPM). Each module, in turn, will create its own child process when an input is added to it. The results of this process' evaluated output will then be available to the rest of the rack wherever inputs are accepted.

Whereas Eurorack modules take voltages as inputs and provide them as outputs, underack instead takes integers as inputs and provides these as outputs. The integers are (by default) in the range of valid MIDI values (for MIDI 1.0 this is usually 0-127). A final output module is needed to:
* convert a set of MIDI values to specific MIDI message types, and
* send these messages to the desired MIDI deivce (hardware or software).
