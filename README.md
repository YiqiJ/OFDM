# MATLAB OFDM Transmitter and Receiver

This is a communication system that use Orthogonal Frequency Division Multiplexing (OFDM) and On-Off Keying (OOK) (one bit sent on each complex-valued component). An OFDM symbol can be described as 

![Image of an OFDM Symbol](OFDM_symbol.png)

where silence signal is used to differentiate symbols; pilot signal is used to determine the channel's impulse response; and each batch includs symbols for each bit and cyclic prefix.

## The Transmitter 
The input to the encoder is a vector of 0/1. The ouput is a .wav file named *tx.wav* with sampling frequency equal to 44.1kHz and amplitude resolution of 24 bits per sample. This file is then transmitted through a physical channel to obtain a *rx.wav* file, from which the receiver will decode the file to get the transmitted data. 

## The Receiver
The receiver open the *rx.wav* file and output a vector, which has the same length as the input 0/1 vector, as the decoded 0/1 bit. 

A major component of the decoder is to search for the first sample point that is not purely noise. That sample point is the starting point of a OFDM symbol. At high SNR, the instantaneous received power will increase dramatically at the moment the samples begin to capture transmitted ones. We utilized a moving-average of the received power to identify the starting point.
