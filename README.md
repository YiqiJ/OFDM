# MATLAB OFDM Transmitter and Receiver

This is a communication system that use Orthogonal Frequency Division Multiplexing (OFDM) and On-Off Keying (OOK) (one bit sent on each complex-valued component). An OFDM symbol can be described as 

![Image of an OFDM Symbol](OFDM_symbol.png)

where silence signal is used to differentiate symbols; pilot signal is used to determine the channel's impulse response; and each batch includs symbols for each bit and cyclic prefix.

## The Transmitter 
The input to the encoder is a vector of 0/1. The ouput is a .wav file named *tx.wav* with sampling frequency equal to 44.1kHz and amplitude resolution of 24 bits per sample. This file is then transmitted through a physical channel to obtain a *rx.wav* file, from which the receiver will decode the file to get the transmitted data. 

The length of the silent signal is 2,151. The length of the silence signal should be at least equal to length of the impulse response, 150 (for the physical channel I tested on), to avoid interference between two OFDM symbols. The silence signal helps us to distinguish two OFDM symbols and to find the starting index of the next OFDM symbol.

The pilot signal is used to learn the physical channel in the decoder. The reason we add pilot signals in front of each OFDM symbol, instead of just sending one pilot signal at the very beginning of the transmission, is because the impulse response of the channel changes throughout the time. For example, intensive communication through the channel could cause the resistors of the RLC filter to heat up, which causes variation of the impulse response of the channel.

We define the pilot signal as 

![eq 1](https://render.githubusercontent.com/render/math?math=x_{pilot}=IFFT([0,X_{pilot},%20flip(conj(X_{pilot}))]))

where 

![eq 2](https://render.githubusercontent.com/render/math?math=X_{pilot}=Ae^{j\theta_k}) and ![eq 3](https://render.githubusercontent.com/render/math?math=\{\theta_k\}) is a sequence of angle generated with a specific seed of random number generator. 

For the cyclic prefix, we use ![eq 3](https://render.githubusercontent.com/render/math?math=n_{%2B}=150) and ![eq 3](https://render.githubusercontent.com/render/math?math=n_{-}=0) since the physical channel must be casual. 

## The Receiver
The receiver open the *rx.wav* file and output a vector, which has the same length as the input 0/1 vector, as the decoded 0/1 bit. 

A major component of the decoder is to search for the first sample point that is not purely noise. That sample point is the starting point of a OFDM symbol. At high SNR, the instantaneous received power will increase dramatically at the moment the samples begin to capture transmitted ones. We utilized a moving-average of the received power to identify the starting point. Define the moving-average of the instantaneous received power as

![eq 4](https://render.githubusercontent.com/render/math?math=S[k]=\frac{1}{J}\sum_{i=0}^{J-1}Y^2[k-i])

The signal *S* will be near zero until *Y* begins to register energy from the transmission. 

The starting sample point is 

![eq 5](https://render.githubusercontent.com/render/math?math=L_1=\{\min_k%20S[k]%3EP_{threshold}\}-\tau)

where *J* is the length sample used to calculate the average power, ![P threshold](https://render.githubusercontent.com/render/math?math=P_{threshold}) is the power threshold, and ![tau](https://render.githubusercontent.com/render/math?math=\tau) is the “backed-up” constant. For the specific physical channel, I used ![param set](https://render.githubusercontent.com/render/math?math=J=20,%20P_{threshold}=0.001,%20\tau=9)

## Performance
Randomly generated a vector of 200,000 bits, the number of incorrect bits is approximately 400. 
