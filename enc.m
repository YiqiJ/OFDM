function enc(bits)
% bits=input information contains 200,000 0/1 bit
assert(length(bits)==200000, "length of bits is not 200,000");
[N_batch, Nb, ~, ~, ~, ~, ~, ~, ~, A, Nb2use]=set_params();

% only use the High SNR bits - put zeros on the low SNR channels
bits=insertzeros(bits,Nb,Nb2use);

NbitsPerOFDMSymbol=N_batch*Nb;

NOFDMSymbols=ceil(length(bits)/NbitsPerOFDMSymbol);

if NbitsPerOFDMSymbol*NOFDMSymbols~=length(bits)
  bits=[bits ; zeros(NbitsPerOFDMSymbol*NOFDMSymbols-length(bits),1)];
end

fprintf(1,'enc: lengthened b, length(b) %d\n',length(bits));

rng(2390214921);
theta_k = 2*pi*rand(Nb,1);
gamma_k = A.*exp(i.*theta_k);

tx=[];

for OFDM_symbol=1:NOFDMSymbols
  OFDMbits = bits((OFDM_symbol-1)*NbitsPerOFDMSymbol+1:OFDM_symbol*NbitsPerOFDMSymbol);
  assert(length(OFDMbits)==NbitsPerOFDMSymbol, "length of OFDM symbol is incorrect");
    
  X_OFDM = EncodeOneOFDMSymbol(OFDMbits, gamma_k);
  tx=[tx;X_OFDM];  
end

tx_max = max(abs(tx));
if tx_max>1
    tx=tx/tx_max;
end
audiowrite('tx.wav', [zeros(50000,1); tx; zeros(50000,1)], 44100, 'BitsPerSample', 24);
end

function b0=insertzeros(b,Nb,Nb2use)

zerobits=zeros(Nb-Nb2use,1);
b0=[];
for i=[1:Nb2use:length(b)]
  ind_e = min(i+Nb2use-1,length(b));
  b2use=b(i:ind_e);
  if length(b2use)==Nb2use
    b0=[b0 ; b2use ; zerobits];
  else
    b0=[b0 ; b2use];
  end
end
end

function X_OFDM=EncodeOneOFDMSymbol(OFDMbits,gamma_k)
[N_batch, Nb, ~, ~, ~, ~, ~, ~, Nsilence, ~, ~]=set_params();
X=zeros(Nsilence,1);

X_pilot = EncodeOneBatch(ones(Nb,1), gamma_k);

X_OFDM=[zeros(Nsilence,1); X_pilot];

for batch=1:N_batch
    batchbits = OFDMbits((batch-1)*Nb+1:batch*Nb);
    assert(length(batchbits)==Nb, "length of encoded bits in one batch is not Nb");
    X_batch = EncodeOneBatch(batchbits, gamma_k);
    X_OFDM=[X_OFDM; X_batch];
end
end


function Xunderbar=EncodeOneBatch(batchbits, gamma_k)
[~, ~, ~, Ns, n_plus, ~, ~, ~, ~, ~, ~]=set_params();

Xs = batchbits.*gamma_k;

Xprime  = [0;Xs;flip(conj(Xs))];
assert(length(Xprime)==Ns, "length of Xprime is not Ns");

X=ifft(Xprime);
assert(all(isreal(X)), "X is not all real");
assert(length(X)==Ns, "the length of X is not Ns");

% Generate Prefix
M = length(X);
X_pre= X(M - n_plus + 1 : M);
% End of Prefix

Xunderbar=[X_pre; X];
end