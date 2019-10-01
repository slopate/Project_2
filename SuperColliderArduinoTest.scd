(
p = SerialPort(
   "/dev/cu.SLAB_USBtoUART",
   baudrate: 9600,
   crtscts: true);
)



SerialPort.devices;

p.next;

p.read;

~ampConv = 0.00012207;
~incrY = 0;
~incrX = 0;
~curValY = ~yVal;


(
r = Routine({
    var byte, str;
    99999.do{|i|
       if(p.read==10, {
            str = "";
			while({byte = p.read; byte != 13 }, {
                 str = str++byte.asAscii;
            });
			~valArray = str.split($ );
			~xVal = ~valArray[0].asInteger;
			~yVal = ~valArray[1].asInteger;
			//~incrY.postln;
			if(~xVal <= 800, {~incrX = -4});
			if((~xVal > 800) && (~xVal <= 1500), {~incrX = -2});
			if((~xVal > 1500) && (~xVal <= 1900), {~incrX = 0});
			if((~xVal > 1900) && (~xVal <= 3000), {~incrX = 2});
			if(~xVal > 3000, {~incrX = 4});

			if(~yVal <= 800, {~incrY = -4});
			if((~yVal > 800) && (~yVal <= 1500), {~incrY = -2});
			if((~yVal > 1500) && (~yVal <= 1900), {~incrY = 0});
			if((~yVal > 1900) && (~yVal <= 3000), {~incrY = 2});
			if(~yVal > 3000, {~incrY = 4});
			//~yVal.postln;
       });
    };
}).play;
)

r.stop;
r.reset;

s.boot;
s.freeAll;

(
SynthDef (\pad, {|freq, amp, dur, pan, out|
	var sig, sig1, sig2, sig3, phaser, env, noise, noise2, noiseEnv, filterEnv, filterLFO, buff, verb;
	env = Env([0, 1, 1, 1, 0], [0.6, 0.5, dur, 4], \sin).kr();
	noiseEnv = Env([0, 1, 1, 1, 0], [0.6, 0.5, dur, 4], \sin).kr();
	filterEnv = Env([0, 1, 1, 0.1], [1, dur, 4], \sin).kr();
	filterLFO = SinOsc.ar(0.25, 0, 100);
	sig1 = Pan2.ar(Saw.ar((freq - 2) + SinOsc.kr(5, mul: 3), 0.4), -1) * env;
	sig2 = Pan2.ar(Saw.ar((freq + 2) + SinOsc.kr(5, mul: 3), 0.4), 1) * env;
	sig3 = Saw.ar((freq * 2) + SinOsc.kr(5, mul: 3), 0.4) * env;
	sig = Mix([sig1, sig2, sig3]);
	sig = RLPF.ar(sig, 1000, 1, 0.6);
	noise = Pan2.ar(PinkNoise.ar(0.4) * noiseEnv, -1);
	noise2 = Pan2.ar(DelayL.ar(PinkNoise.ar(0.4) * noiseEnv, 0.3, 0.2), 1);
	noise = Mix([noise, noise2]);
	noise = RLPF.ar(noise, 4000, 1);
	noise = RHPF.ar(noise, 250, 1);
	sig = Mix([sig, noise]);
	sig = RLPF.ar(sig, (700 + filterLFO) * filterEnv, 0.4, 0.1);
	phaser = Mix(Array.fill(4, {AllpassC.ar(sig, 1, SinOsc.ar(0.3, 0, 0.005, 0.0051), 0, 0.8)}));
	sig = sig + phaser;
	sig = FreeVerb.ar(sig, 0.9, 0.9);
	sig = Pan2.ar(sig, pan, 1);
	Out.ar(out, sig * amp) * Env([0, 1, 1, 1, 0], [0.6, 0.5, dur + 3, 4], \sin).kr(doneAction: 2);
}).add;
)



(
SynthDef (\morphPad, {|freq, amp1 = 0.5, amp2, amp3, amp4, dur, vibRate = 4, vibDepth = 0.1, pan, out|
	var sig1, sig1a, sig1b, sig1c, sig2, sig3, sig4, env, vib;
	vib = SinOsc.kr(vibRate).range(freq * (1 - vibDepth), freq * (1 + vibDepth));
	env = Env.linen(0.1, dur, 2).kr(doneAction: 2);
	sig1a = Pan2.ar(Saw.ar((freq - 2) + SinOsc.kr(5, mul: 3), 0.1), 0.1) * env;
	sig1b = Pan2.ar(Saw.ar((freq + 2) + SinOsc.kr(5, mul: 3), 0.1), 0.1) * env;
	sig1c = Saw.ar((freq / 2) + SinOsc.kr(5, mul: 3), 0.1) * env;
	sig1 = Mix([sig1a, sig1b, sig1c]);
	Out.ar(out, sig1 * env * LinLin.kr(amp1, 0.1, 4096, 0.1, 1));
}).add;
)

LinLin.kr(SinOsc.kr(440), 0, 1, 0, 100).po;

(
~rou = Routine {
	~test = Synth(\morphPad, [\freq, 440, \amp1, 1, \dur, 100, \pan, 0, \out, 0]);
	loop {
		//~val = LinExp(~yVal, 0, 4096, 0, 0.5).class;
		~curValY = ~curValY + ~incrY;
		~incrY.postln;
		~test.set(\amp1, [~curValY, 4096].minItem);
		0.01.wait;
	}
}.play;
)

~rou.stop;

~incrY.class;

([1, 2]).max;

s.quit;

SynthDef(\apad_mh, {
	arg
	//Standard Values:
	out = 0, pan = 0, freq = 880, amp = 0.5, att = 0.4, dec = 0.5, sus = 0.8, rel = 1.0, gate = 1,
	//Other Controls:
	vibratoRate = 4, vibratoDepth = 0.015, tremoloRate = 5,
	//These controls go from 0 to 1:
	tremoloDepth = 0.5, reverbMix = 0.5, roomSize = 1, damp = 0.5;

	var env, snd, vibrato, tremolo, mod2, mod3;

	env = Env.adsr(att, dec, sus, rel).kr(gate: gate);
	vibrato = SinOsc.kr(vibratoRate).range(freq * (1 - vibratoDepth), freq * (1 + vibratoDepth));
	tremolo = LFNoise2.kr(1).range(0.2, 1) * SinOsc.kr(tremoloRate).range((1 - tremoloDepth), 1);

	snd = SinOsc.ar(freq: [freq, vibrato], mul:(env * tremolo * amp)).distort;
	snd = Mix.ar([snd]);
	snd = FreeVerb.ar(snd, reverbMix, roomSize, damp);

	DetectSilence.ar(snd, 0.0001, 0.2, doneAction: 2);
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata:(
	credit: "Mike Hairston",
	tags: [\pad, \vibrato, \sustained]
	)
).add;

~test1 = Synth(\apad_mh, [\freq, 440]);

~test = Synth(\morphPad, [\freq, 440, \amp1, 1, \dur, 3, \pan, 0, \out, 0]);


~pad2Test = Synth(\pad, [\freq, 500, \amp, 1, \dur, 10, \pan, -1, \out, 0]);
s.numSynths;

(
a = Routine{
	while ({true}, {~pad2Test.set(\freq, ~yVal)});
}.play;
)

(
~rou = Routine {
	~pad2Test = Synth(\pad, [\freq, 500, \amp, 1, \dur, 20, \pan, -1, \out, 0]);
	loop {
		~pad2Test.set(\freq, ~yVal/4);
		1.wait;
	}
}.play;
)

~rou.stop;






(
~pad2Test = Synth(\pad, [\freq, ~yVal/4, \amp, 1, \dur, 20, \pan, -1, \out, 0]);
1000.do{~pad2Test.set(\freq, ~yVal/4); 1.postln};
)



~pad2Test.stop;







