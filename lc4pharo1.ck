// Domenico Cipriani 2022
// OSC receiver intended to be programmed on the fly with the LiveCOding Package for Pharo
// https://github.com/lucretiomsp/PharoLiveCoding
// a basic drum machines and a few synths receiving on port 8000


// the OpenSoundControl thing

OscIn oin;
8000 => oin.port;
OscMsg msg;

// the messages
"/KickGate" => oin.addAddress;
"/SnareGate" => oin.addAddress; 
"/ClapGate" => oin.addAddress;
"/TomGate" => oin.addAddress;
"/ChGate" => oin.addAddress;
"/OhGate" => oin.addAddress;
"/RideGate" => oin.addAddress;

/// the sounds
SndBuf kick => dac;
SndBuf snare => dac;
SndBuf clap => dac;
SndBuf ch => dac;
SndBuf oh => dac;
SndBuf tom => dac;
SndBuf ride => dac;

me.dir()+"samples/909bdlong.wav" => kick.read;
me.dir()+"samples/SD_preda808.aiff" => snare.read;
me.dir()+"samples/CP_full909.aiff" => clap.read;
me.dir()+"samples/CH_std909.aiff" => ch.read;
me.dir()+"samples/OH_proper909.aiff" => oh.read;
me.dir()+"/samples/TomDisko.wav" => tom.read;
me.dir()+"/samples/RC_thin909.aiff" => ride.read;

// read samples from the beginning
kick.samples() => kick.pos;
snare.samples() => snare.pos;
clap.samples() => clap.pos;
ch.samples() => ch.pos;
oh.samples() => oh.pos;
tom.samples() => tom.pos;
ride.samples() => ride.pos;

// convenience function
fun void playSampleWithOSC(string address, SndBuf snd)
{
    // if the message is a Gate
    if (msg.address == address + "Gate")
    {
        if(msg.getFloat(0) == 1.0)    
            0 => snd.pos;
    }
}
// here we do the thing
while (true)
{   oin => now; // sleep until OSC is received

// when event(s) received, process them
while (oin.recv(msg) != 0)
{
    playSampleWithOSC("/Kick", kick);
    playSampleWithOSC("/Snare", snare);
    playSampleWithOSC("/Clap", clap);
    playSampleWithOSC("/Ch", ch);
    playSampleWithOSC("/Oh", oh);
    playSampleWithOSC("/Tom", tom);
    playSampleWithOSC("/Ride", ride);
    
  <<< "KickGate" +"Gate" >>>;
}

}