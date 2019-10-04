// INITIALIZE EVERYTHING
s.waitForBoot({

~masterRoutine = Routine {

p = SerialPort(
   "/dev/cu.SLAB_USBtoUART",
   baudrate: 9600,
   crtscts: true
);

1.postln;
0.5.wait;

~incrYR = 0;
~incrXR = 0;
~incrYL = 0;
~incrXL = 0;

r = Routine({
    var byte, str;
    99999.do{|i|
       if(p.read==10, {
            str = "";
			while({byte = p.read; byte != 13 }, {
                 str = str++byte.asAscii;
            });

			~valArray = str.split($ ).postln;

            if (~valArray.size == 8, {
                ~xValR = ~valArray[0].asInteger;
                ~yValR = ~valArray[1].asInteger;
                ~buttonValR = ~valArray[2].asInteger;
                ~switchValR = ~valArray[3].asInteger;
                ~xValL = ~valArray[4].asInteger;
                ~yValL = ~valArray[5].asInteger;
                ~buttonValL = ~valArray[6].asInteger;
                ~switchValL = ~valArray[7].asInteger});


			if(~xValR <= 1200, {~incrXR = -3});
			if((~xValR > 1200) && (~xValR <= 1800), {~incrXR = -1.5});
			if((~xValR > 1800) && (~xValR <= 1850), {~incrXR = 0});
			if((~xValR > 1850) && (~xValR <= 3800), {~incrXR = 1.5});
			if(~xValR > 3800, {~incrXR = 3});

			if(~yValR <= 700, {~incrYR = -3});
			if((~yValR > 700) && (~yValR <= 1900), {~incrYR = -1.5});
			if((~yValR > 1900) && (~yValR <= 1950), {~incrYR = 0});
			if((~yValR > 1950) && (~yValR <= 3000), {~incrYR = 1.5});
			if(~yValR > 3000, {~incrYR = 3});

            if(~xValL <= 800, {~incrXL = -3});
			if((~xValL > 800) && (~xValL <= 1775), {~incrXL = -1.5});
			if((~xValL > 1775) && (~xValL <= 1825), {~incrXL = 0});
			if((~xValL > 1825) && (~xValL <= 4000), {~incrXL = 1.5});
			if(~xValL > 4000, {~incrXL = 3});

			if(~yValL <= 700, {~incrYL = -3});
			if((~yValL > 700) && (~yValL <= 1500), {~incrYL = -1.5});
			if((~yValL > 1950) && (~yValL <= 2000), {~incrYL = 0});
			if((~yValL > 2000) && (~yValL <= 3300), {~incrYL = 1.5});
			if(~yValL > 3300, {~incrYL = 3});

       });
    };
}).play;

2.postln;


~curValYL = ~yValL;
~curValXL = ~xValL;
~curValYR = ~yValR;
~curValXR = ~xValR;


SynthDef (\morphPad, {|freq=1000, ampMaster=1900, amp1, amp2, amp3, amp4, dur, vibRate = 4, vibDepth = 0.1, blendX=1900, blendY=1900, pan, out, lpfCut=1900, hpfCut=1900, phaseRate=100, verb=1900|
	var sig, sig1, sig1a, sig1b, sig1c, sig2, sig2a, sig2b, sig3, sig3a, sig3b, sig3c, sig4a, sig4b, sig4, vib, filterLFO, phaser;
	vib = SinOsc.kr(vibRate).range(freq * (1 - vibDepth), freq * (1 + vibDepth));
	//env = Env.linen(0.1, dur, 2).kr(doneAction: 2);
	filterLFO = SinOsc.kr(0.5, 0, 1000);

    sig1a = Pan2.ar(Saw.ar(((freq).linexp(0, 4096, 1000, 100) - 2).lag(5) + SinOsc.kr(5, mul: 3), 0.8));
    sig1b = Pan2.ar(Saw.ar(((freq).linexp(0, 4096, 1000, 100) + 2).lag(5) + SinOsc.kr(5, mul: 3), 0.8));
    sig1c = Saw.ar(((freq).linexp(0, 4096, 1000, 100) / 2).lag(5) + SinOsc.kr(5, mul: 3), 0.8);
	sig1 = Mix([sig1a, sig1b, sig1c]);
    sig1 = sig1 * (blendX).linlin(0, 4096, 0, 1).lag(5);

	sig2a = PinkNoise.ar(0.7);
	sig2b = DelayL.ar(PinkNoise.ar(0.7), 0.3, 0.2);
	sig2 = Mix([sig2a, sig2b]) !2;
	sig2 = sig2 * (blendX).linlin(0, 4096, 1, 0).lag(5);

    sig3a = Pan2.ar(SinOsc.ar(((freq).linexp(0, 4096, 1000, 100) - 2).lag(5) + SinOsc.kr(1, mul: 10), mul: 0.8), -0.5) ;
	sig3b = Pan2.ar(SinOsc.ar(((freq).linexp(0, 4096, 1000, 100) + 2).lag(5) + SinOsc.kr(1, mul: 10), mul: 0.8), 0.5);
	sig3c = SinOsc.ar(((freq).linexp(0, 4096, 1000, 100) * 2).lag(5) + SinOsc.kr(1, mul: 10), mul: 0.8);
	sig3 = Mix([sig3a, sig3b, sig3c]);
    sig3 = AllpassL.ar(sig3, 4, SinOsc.ar((phaseRate).linexp(0, 4096, 0.5, 1000).lag(5), 0, 0.005, 0.01), 0, 0.7);
	sig3 = sig3 * (blendY).linlin(0, 4096, 0, 1).lag(5);

    sig4a = { Pulse.ar([(freq).linexp(0, 4096, 1000, 100).lag(5), (freq).linexp(0, 4096, 1000, 100).lag(5) *2.5], 0.5, 0.3) };
    sig4b = { Pulse.ar([(freq).linexp(0, 4096, 1000, 100).lag(5) *2, (freq).linexp(0, 4096, 1000, 100).lag(5) *4], 0.5, 0.3)};
    sig4 = Mix([sig4a, sig4b]);
    sig4 = sig4 * (blendY).linlin(0, 4096, 1, 0).lag(5);

    sig = RLPF.ar(Mix([sig1, sig2, sig3, sig4]), (lpfCut).linexp(0, 4096, 700, 18000).lag(5), 0.5);
    sig = RHPF.ar(sig, (hpfCut).linexp(0, 4096, 20, 500).lag(5), 0.5);
    sig = FreeVerb.ar(sig, (verb).linlin(0, 4096, 0, 1).lag(5), 0.8);


    Out.ar(out, sig * LinLin.kr(ampMaster, 0, 4096, 0, 1).lag(4));
}).add;

s.sync;
~noisey = Synth(\morphPad, [\freq, 1000, \amp1, 1, \dur, 1, \pan, 0, \out, 0, \ampMaster, 0]);


~winenv = Env([0, 0.8, 0.2,0.8, 0.2, 0.8, 0], 0.5 ! 6, [6, -4, 4, -4, 4, 6]);
y = Buffer.sendCollection(s, ~winenv.discretize, 1);

SynthDef(\grain_synths, {|gate=1, rate=1900, amp=1900, gSize=1900, carFreq=1900, modFreq=1900, chaos=1900, random=0, envbuf, subFreq=1900, lpfCut=1900, hpfCut=1900|
    var env, sig, sig1, sig2, sig3, freqdev, w, x, y, z, trig;
    env = EnvGen.kr(
        Env([0, 1, 0], [1, 1], \sin, 1),
        gate,
        doneAction: 2);

            sig1 = GrainIn.ar(2, Impulse.kr(rate.linexp(0, 4096, 5, 20).lag(5)), 0.1 * env,
                LFTri.ar(subFreq.linlin(0, 4096, 100, 20).lag(5) + Saw.ar(rate.linlin(0, 4096, 0.5, 3).lag(5), mul: 20), mul: 0.5), 0, envbuf);

            freqdev = LFNoise1.kr(50).range(0, random.linexp(0, 4096, 0.001, 1000).lag(5));
            sig2 = FMGrain.ar(Impulse.ar(rate.linexp(0, 4096, 3, 30).lag(5)), gSize.linlin(0, 4096, 0.05, 0.4).lag(5), carFreq.linexp(0, 4096, 2000, 80).lag(5) + freqdev, carFreq.linexp(0, 4096, 80, 2000).lag(5) / 2,
                LFNoise1.kr(chaos.linlin(0, 4096, 1, 5).lag(5)).range(1, 10),
            EnvGen.kr(
                Env([0, 1, 0], [1, 1], \sin, 1),
                gate,
                levelScale: 0.2,
                doneAction: 2)
        );

            trig = Impulse.kr((rate).linexp(0, 4096, 5, 30).lag(5));
    #w, x, y, z = SinGrainBBF.ar(trig, 0.05, carFreq.linexp(0, 4096, 2000, 80).lag(5), envbuf,
        WhiteNoise.kr.range(-0.25pi, 0.25pi), 0, 1,
            EnvGen.kr(
                Env([0, 1, 0], [1, 1], \sin, 1),
                gate,
                doneAction: 2)
            );
    sig3 = DecodeB2.ar(4, w, x, y);

            sig = RLPF.ar(Mix([sig1, sig2, sig3]), (lpfCut).linexp(0, 4096, 700, 20000).lag(5), 0.5);
            sig = RHPF.ar(sig, (hpfCut).linexp(0, 4096, 20, 500).lag(5), 0.5);

    sig = FreeVerb.ar(sig, 0.4, 0.7);

            Out.ar([0 , 1], sig * (amp).linlin(0, 4096, 0, 1).lag(5));

}).add;

s.sync;


~grainSynth = Synth(\grain_synths, [\rate, ~curValXR, \chaos, ~curValXR, \carFreq, ~curValYL, \modFreq, ~curValXL, \random, 0, \subFreq, ~curValYL, \amp, 0, \envbuf, y]);

3.wait;

~rou = Routine {

                ~curValXR = ~xValR;
                ~curValXL = ~xValL;
                ~curValYR = ~yValR;
                ~curValYL = ~yValL;
                loop {
                    ~curValYR = [[~curValYR + ~incrYR, 4096].minItem, 0].maxItem;
                    ~curValXR = [[~curValXR + ~incrXR, 4096].minItem, 0].maxItem;

                    ~curValYL = [[~curValYL + ~incrYL, 4096].minItem, 0].maxItem;
                    ~curValXL = [[~curValXL + ~incrXL, 4096].minItem, 0].maxItem;


                    if (~buttonValR == 0, {~noisey.set(\blendY, ~curValYR, \blendX, ~curValXR)},
                        {~noisey.set(\lpfCut, ~curValYR, \hpfCut, ~curValXR)});

                    if (~buttonValL == 0, {~noisey.set(\ampMaster, (~curValXL * ~switchValR * (~switchValL - 1).abs), \freq, ~curValYL)},
                        {~noisey.set(\phaseRate, ~curValXL, \verb, ~curValYL)});

                    0.005.wait;
        }
    }.play;

~grainR = Routine {
                ~curValXR = ~xValR;
                ~curValXL = ~xValL;
                ~curValYR = ~yValR;
                ~curValYL = ~yValL;
                loop {
                    ~curValYR = [[~curValYR + ~incrYR, 4096].minItem, 0].maxItem;
                    ~curValXR = [[~curValXR + ~incrXR, 4096].minItem, 0].maxItem;

                    ~curValYL = [[~curValYL + ~incrYL, 4096].minItem, 0].maxItem;
                    ~curValXL = [[~curValXL + ~incrXL, 4096].minItem, 0].maxItem;

                    if (~buttonValR == 0, {~grainSynth.set(\rate, ~curValYR, \gSize, ~curValXR, \chaos, ~curValXR)},
                        {~grainSynth.set(\lpfCut, ~curValYR, \hpfCut, ~curValXR)});

                    if (~buttonValL == 0, {~grainSynth.set(\amp, (~curValXL * ~switchValR * ~switchValL), \carFreq, ~curValYL)},
                        {~grainSynth.set(\random, ~curValXL, \subFreq, ~curValYL)});

                    0.005.wait;
                }
            }.play;
}.play;

});






