function bhat=dec()
[N_batch, Nb, ~, ~, ~, Ns_prefix, ~, N_pilot_prefix, Nsilence, A, Nb2use]=set_params();

rng(2390214921);
theta_k = 2*pi*rand(Nb,1);
gamma_k = A.*exp(i.*theta_k);

[rx, ~]= audioread('rx.wav');
NSamplesPerOFDMSymbol=Nsilence+N_pilot_prefix+N_batch*Ns_prefix;
NOFDMSymbols=ceil(length(rx)/NSamplesPerOFDMSymbol);

nextsample=1;
nextsample_save=[];

bhat=[];

for ii=1:NOFDMSymbols
    nextsample=findStart(rx);
    
    if (nextsample==0)
        bhat = deletezerobits(bhat,Nb,Nb2use); 
        return;
    end
    nextsample_save=[nextsample_save ; nextsample];
    ind_s = nextsample; % start of the signal [remove silence]
    ind_e = nextsample+NSamplesPerOFDMSymbol-1-Nsilence; % end of the signal
    bhatOFDMsymbol=DecodeOFDMSymbol(rx(ind_s:ind_e),gamma_k);
    bhat=[bhat;bhatOFDMsymbol];
    rx=rx(ind_e+100:end); % AT LEAST +1 (+100 to avoid previous search error)
end
bhat=deletezerobits(bhat,Nb,Nb2use);
end

function b=deletezerobits(b0,Nb,Nb2use)
b=[];
for i=[1:Nb:length(b0)]
  ind_e=min(i+Nb2use-1,length(b0));
  b2use=b0(i:ind_e);
  b=[b ; b2use];
end
end

function nextsample=findStart(rx)
windowsize=20;
if windowsize > length(rx)
  nextsample=0;
end
for i=windowsize:length(rx)
  movingaverageofpower=sum(rx(i-windowsize+1:i).^2)/windowsize;
  if movingaverageofpower>0.001
    nextsample=i-windowsize/2+1;
    if nextsample<1
      nextsample=1;
    end
    return;
  end
end
nextsample=0;
end

function bhat=DecodeOFDMSymbol(Y,X_h)
[N_batch, Nb, ~, ~, n_plus, Ns_prefix, ~, N_pilot_prefix, ~, A, ~]=set_params();
ind_s=1;
ind_e=N_pilot_prefix;
y_h=Y(ind_s:ind_e);
Y_h=fft(y_h(n_plus+1:end));
Y_h=Y_h(2:Nb+1);

lambdas = Y_h./X_h;

lambdar=abs(lambdas);
lambdap=exp(i.*angle(lambdas));

bhat=[];
%there are Nbatch batches of information symbols
for ii=1:N_batch
  ind_s=N_pilot_prefix+(ii-1)*Ns_prefix+1;
  ind_e=ind_s+Ns_prefix-1;
  
  Ybatch=Y(ind_s:ind_e);
  Yprime = fft(Ybatch(n_plus+1:end));
  Ys=Yprime(2:Nb+1);
  Ys=Ys./lambdap;
    
  bhatbatch=double(abs(Ys)>=0.5*lambdar*A);
  bhat=[bhat ; bhatbatch];
end
end