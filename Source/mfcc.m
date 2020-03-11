function [v me]= mfcc(s,fs)
    % The function computed the mfcc output of the input signal s sampled at fs
%    s:    No of points
%    fs:   Sampling rate
 N=numel(s);                      % size of each frame
 nof=13;                     % number of filters
% computes the hamming window coefficients
h= hamming(N);             % windowing 
% applies the hamming window to each frame
b=s.* h;
% computes the mel filter bank coeffs
 m=melfilterbank(nof,N-1,fs);         % normailising to mel freq
 y=fft(b);
 ms=m*abs(y(1:N/2)).^2;
 me=(ms(1:5).^2);
 v=dct(log(ms));
 

