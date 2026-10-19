"""Compose the original Level 3 cafe loop. Requires NumPy; game only needs the WAV."""
from pathlib import Path
import wave
import numpy as np
SR = 22050
BEAT = 60 / 96
LENGTH = 32 * BEAT
mix = np.zeros(round(LENGTH * SR), dtype=np.float64)
rng = np.random.default_rng(3003)

def add(start, samples):
    # Wrap decays into the beginning, preserving a continuous loop seam.
    indices = (round(start * SR) + np.arange(len(samples))) % len(mix)
    np.add.at(mix, indices, samples)

def note(beat, midi, duration, gain, bass=False):
    t = np.arange(round(duration * SR)) / SR
    f = 440 * 2 ** ((midi - 69) / 12)
    envelope = np.minimum(t / .007, 1) * np.exp(-t * (4 if bass else 6))
    envelope *= np.minimum((duration-t)/.04, 1)
    tone = np.sin(2*np.pi*f*t) + .23*np.sin(4*np.pi*f*t) + .06*np.sin(6*np.pi*f*t)
    add(beat * BEAT, gain * envelope * tone)

chords = [(48,[60,64,67,71]), (45,[61,64,67,69]), (50,[60,62,65,69]), (43,[59,62,65,69]),
          (40,[59,62,64,67]), (45,[60,64,67,69]), (50,[60,62,65,69]), (43,[59,62,65,67])]
melodies = [[76,79,83,79,76,74,72,0], [73,76,79,81,79,76,73,0],
            [74,77,81,77,76,74,72,0], [71,74,77,81,79,77,74,0],
            [76,79,83,86,83,79,76,0], [76,81,84,83,81,79,76,0],
            [77,81,84,81,79,77,74,0], [74,77,79,77,74,71,72,0]]
for bar,(root,chord) in enumerate(chords):
    for beat,pitch in [(0,root),(2,root+7)]: note(bar*4+beat,pitch,.75,.10,True)
    for beat in [0.65,1.65,2.65,3.65]:
        for j,pitch in enumerate(chord):note(bar*4+beat+j*.018,pitch,.42,.018)
    for i,pitch in enumerate(melodies[bar]):
        if pitch:note(bar*4+i//2+(0.58 if i%2 else 0),pitch,.45,.065)
    for beat in range(4):
        t=np.arange(round(.065*SR))/SR
        noise=rng.normal(0,1,len(t));noise=np.concatenate(([0],np.diff(noise)))
        add((bar*4+beat+.58)*BEAT,noise*np.exp(-t*95)*np.minimum(t/.002,1)*.008)
        if beat in (1,3):
            t=np.arange(round(.14*SR))/SR
            add((bar*4+beat)*BEAT,np.sin(2*np.pi*150*t)*np.exp(-t*45)*np.minimum(t/.003,1)*.025)
mix -= mix.mean()
mix *= .38 / np.max(np.abs(mix))
pcm=np.rint(mix*32767).astype('<i2')
output=Path(__file__).resolve().parents[1]/'data/LEVEL3/full-course-cafe.wav'
with wave.open(str(output),'wb') as wav:
    wav.setparams((1,2,SR,0,'NONE','not compressed'));wav.writeframes(pcm.tobytes())
assert np.max(np.abs(pcm.astype(np.int32))) < 32767
assert abs(int(pcm[-1])-int(pcm[0])) < 500
print(f'{output.name}: {LENGTH:.1f}s, 96 BPM, mono PCM, peak {max(abs(mix)):.2f}, seam {abs(int(pcm[-1])-int(pcm[0]))}')
