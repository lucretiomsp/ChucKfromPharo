// Domenico Cipriani 2022
// OSC receiver intended to be programmed on the fly with the LiveCoding Package for Pharo
// https://github.com/lucretiomsp/PharoLiveCoding
// a basic drum machines and a few synths receiving on port 8000


// the OpenSoundControl thing

OscIn oin;
8000 => oin.port;
OscMsg msg;

// the acid chugraph
// you can learn more about chubgraph at:
/// https://chuck.stanford.edu/extend/#chugraphs

class monoAcid extends Chugraph
{
    SawOsc acid => ADSR env => LPF filter => outlet;
    
    // set a default freq and gain and a short envelope
    0.4 =>acid.gain;
    220 => acid.freq;
    (1::ms, 280::ms,0, 140::ms) => env.set;
    //
    800 => filter.freq;
    3 => filter.Q; // high resonance!
    
    // set the frequency of the synth in MIDI noteNumber
    fun float setNote(float noteNumber)
    {
        Std.mtof(noteNumber) => acid.freq;
    }
    
    // play the synth when it receives a 1.0
    fun void playNote (float gate)
    {
        if (gate == 1.0)
        { 1 => env.keyOn;}
        if (gate == 0.0)
        { 1 => env.keyOff;}
    }
    
    fun void setCutoff (float cutoff)
    {
        cutoff => filter.freq;
    }
}

// the messages
// you need to register all the messages you want to parse
// from those received from Pharo
"/test" => oin.addAddress;
"/kick" => oin.addAddress;
"/snare" => oin.addAddress; 
"/clap" => oin.addAddress;
"/tom" => oin.addAddress;

"/ch" => oin.addAddress;
"/oh" => oin.addAddress;
"/ride" => oin.addAddress;
"/acid" => oin.addAddress;
"/acidCutoff" => oin.addAddress;

/// the sounds
    // the drums
SndBuf kick => dac;
SndBuf snare => dac;
SndBuf clap => dac;
SndBuf ch => dac;
SndBuf oh => dac;
SndBuf tom => dac;
SndBuf ride => dac;
  // the synths
monoAcid mono1 => dac;
  
 

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

// a little bit of mixing
0.7 => kick.gain; 0.6 => snare.gain; 0.5 => clap.gain;  0.32 => ch.gain; 0.3 => oh.gain;
0.26 => tom.gain; 0.37 => ride.gain;


// cnveience function to play mono synths
fun void playMonoWithOSC(string address, monoAcid synth)
{
    if (msg.address == address)
    {
        msg.getFloat(0) => synth.setNote;
        msg.getFloat(1) => synth.playNote;
    } 
    if (msg.address == address+"Cutoff")
    {
        msg.getFloat(0) => synth.setCutoff;
    }
}

// convenience function to play samples
fun void playSampleWithOSC(string address, SndBuf snd)
{
    // if the message is a Gate
    if (msg.address == address)
    {
        // the gate is the second argument in the OSC message
        if(msg.getFloat(1) == 1.0)    
            0 => snd.pos;
   
   
        // convert midiNoteNumber to ratio rate
        // the noteNumber is the first argument in the OSC message
        Math.pow(2.0, (msg.getFloat(0) - 60.0) / 12.0) =>snd.rate;
        
    }
}
// here we do the thing
while (true)
{   oin => now; // sleep until OSC is received

// when event(s) received, process them
while (oin.recv(msg) != 0)
{
    playSampleWithOSC("/kick", kick);
    playSampleWithOSC("/snare", snare);
    playSampleWithOSC("/clap", clap);
    playSampleWithOSC("/ch", ch);
    playSampleWithOSC("/oh", oh);
    playSampleWithOSC("/tom", tom);
    playSampleWithOSC("/ride", ride);
    playMonoWithOSC("/acid", mono1);
    
// <<< msg.address , " " , msg.getFloat(0), msg.getFloat(1)>>>;
}

}