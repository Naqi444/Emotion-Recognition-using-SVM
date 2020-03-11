clc;
clear all;
close all
[J P]=uigetfile('.wav','Select the speech signal');
[I Fs]=wavread(strcat(P,J));
%-------------------------------------------------
%--- End point Detection ----------------------
[E]=endpointdetect(I,Fs);
figure,subplot(211); plot(I);title('before end point detection');xlabel('---Time');ylabel('Amplitude');
subplot(212),plot(E);xlim([0 3e4]);title('After end point detection');xlabel('---Time');ylabel('Amplitude');
W=fix(.04*Fs);                 %Window length is 40 ms
SP=.4;                         %Shift percentage is (10ms) %Overlap-Add method works good with this value(.4)
Seg=segment1(E,W,SP);
%-------------------------------------------------
for nn=1:size(Seg,2)
[F0,T,C]=PitchTrackCepstrum(Seg(:,nn),Fs);
LE=sum(Seg(:,nn).^2);
[F T]=spFormantsTrackLpc(Seg(:,20),Fs,6);
F1(nn)=F(1);F2(nn)=F(2);%F3(nn)=F(3);
[MFC ME] = mfcc(Seg(:,nn),Fs);
FV(:,nn)=[F0 LE F MFC' ME']';
end