function [F, T] = spFormantsTrackLpc(x, fs, ncoef, frame_length, frame_overlap, window, show)
 % Initialization
 N = length(x);
 if ~exist('frame_length', 'var') || isempty(frame_length)
     frame_length = 30;
 end
 if ~exist('frame_overlap', 'var') || isempty(frame_overlap)
     frame_overlap = 20;
 end
 if ~exist('window', 'var') || isempty(window)
     window = 'hamming';
 end
 if ~exist('show', 'var') || isempty(show)
     show = 0;
 end
 if ~exist('ncoef', 'var')
     ncoef = [];
 end
 nsample = round(frame_length  * fs / 1000); % convert ms to points
 noverlap = round(frame_overlap * fs / 1000); % convert ms to points
 window   = eval(sprintf('%s(nsample)', window)); % e.g., hamming(nfft)

 pos = 1; t = 1;
 F = []; % formants
 T = []; % time (s) at the frame
 mid = round(nsample/2);
 while (pos+nsample <= N)
     frame = x(pos:pos+nsample-1);
     frame = frame - mean(frame);
     a = lpcn(frame, fs, ncoef);
     fm = FormantsLpc(a, fs);
     for i=1:length(fm)
        F = [F fm(i)]; % number of formants are not same for each frame
        T = [T (pos+mid)/fs];
     end
     pos = pos + (nsample - noverlap);
     t = t + 1;
 end

 if show
     % plot waveform
     t=(0:N-1)/fs;
     subplot(2,1,1);
     plot(t,x);
     legend('Waveform');
     xlabel('Time (s)');
     ylabel('Amplitude');
     xlim([t(1) t(end)]);

     % plot formants trace
     subplot(2,1,2);
     plot(T, F, '.');
     hold off;
     legend('Formants');
     xlabel('Time (s)');
     ylabel('Frequency (Hz)');
     xlim([t(1) t(end)]);
 end
 %--------------------------------------
 function [F] = FormantsLpc(a, fs)
  r = roots(a);
  r = r(imag(r)>0.01);
  F = sort(atan2(imag(r),real(r))*fs/(2*pi));
  %----------------------------------
  function [a P e] = lpcn(x, fs, ncoef)
 if ~exist('ncoef', 'var') || isempty(ncoef)
     ncoef = 2 + round(fs / 1000); % rule of thumb for human speech
 end
 [a P] = lpc(x, ncoef);
 if nargout > 2,
    est_x = filter([0 -a(2:end)],1,x);    % Estimated signal
    e = x - est_x;                        % Residual signal
 end 


