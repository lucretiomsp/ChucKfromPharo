// comand + . will start the virtual machine
// you will be able to see incoming messages on the
// console monitor

// the midi input
MidiIn min;
// the midi msg
MidiMsg msg;

// command + 2 shows you the device browser
// 1 is the IAC Driver Bus on my mac
1 => int device;
// if device doesnt work it stops the program.
if (!min.open(device)) me.exit();

// infinite loop
while (true)
{
    // wait for midi event to do something
    min => now;
// get the message(s)
while( min.recv(msg) )
{
    // print out midi message
    <<< "Midi Message coming in" >>>;
    <<< msg.data1, msg.data2, msg.data3 >>>;
    }
}
