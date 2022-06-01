// simple patch that expose parameter to be controlled by
// MIDI control change message
// ADSR is triggered by noteON messages, and oscillators frequency is set by 
// the MIDI note number received

MidiIn min; // midi receiver
MidiMsg msg; // the msg
min.open(2); //select the right MIDI input checking the Device Browser/MIDI
if (!min.open(2)) {me.exit();} // exit the program if MIDI cant be opened

Gain g; // gain unit, works as mixer
ADSR env; // envelope generator
SawOsc s1 => g; // first oscillator

// makes some noise
// LPF is our lowpass filter, we will control it with CONTROL CHANGE messages
g => env => LPF lpf => dac;

0.4 => g.gain; // intial gain
600 => lpf.freq; // initial filter cutoff
2.0 => lpf.q; // initial resonance
(1::ms, 100::ms, 0.0, 160::ms) => env.set; // initial gilter parameters

// forever
while(true)
{
    min => now;
    while (min.recv(msg)) {
        <<<msg.data1, msg.data2, msg.data3 >>>;
        
        // the synth is thought to receive on channel 1
        // so status byte (data1) is 144 for noteON and 128 for noteOff
        if (msg.data1 == 144)
        {
            Std.mtof(msg.data2) => s1.freq; // data2 is the note number, we convert it to hertz
            1 => env.keyOn; // trig the envelope
           
        }
        // a noteOff message can also be a noteOn message with velocity == 0
        if ((msg.data1 == 128) || (msg.data3 == 0))
        { 1 => env.keyOff; }
        
        // 176 is the status byte for CC messages
        // this is our CCs control structure
        if (msg.data1 == 176)
        {
        
         // we decide that CC74 is for filter cutoff (it's an arbitrary choice)
         if (msg.data2 == 74)
         {
             // there is no "map" function in ChucK so we must do the map ourselves
             // our range will be [0, 127*200]
             (msg.data3) * 200 => lpf.freq;
         }
        
        }
    }
}
