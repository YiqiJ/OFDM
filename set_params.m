function [N_batch, Nb, Nss, Ns, n_plus, Ns_prefix, N_pilot, N_pilot_prefix, Nsilence, A, Nb2use]=set_params()
N_batch = 5; % number of batches

Nb = 1000; % number of bits per batch Nb=1000

Nss = Nb;

Ns  = 2*Nss+1; % number of symbols per batch Ns=2002

n_plus = 150; % length of prefix 

Ns_prefix = Ns + n_plus; % number of symbols per batch with prefix

N_pilot = Ns; % number of symbols for channel learning, not including the prefix

N_pilot_prefix = Ns + n_plus; %number of symbols for channel learning, including the prefix

Nsilence = 500;%Ns + n_plus;

A = 2.0; % amplitude 

Nb2use=750;
end