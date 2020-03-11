function [F0, T, C] = PitchTrackCepstrum(x, fs, frame_length, frame_overlap, window, show)
 %% Initialization
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
 nsample = round(frame_length  * fs / 1000); % convert ms to points
 noverlap = round(frame_overlap * fs / 1000); % convert ms to points
 if ischar(window)
     window   = eval(sprintf('%s(nsample)', window)); % e.g., hamming(nfft)
 end
 %% Pitch detection for each frame
 pos = 1; i = 1;
 while (pos+nsample < N)
     frame = x(pos:pos+nsample-1);
     C(:,i) = spCepstrum(frame, fs, window);
     F0(i) = spPitchCepstrum(C(:,i), fs);
     pos = pos + (nsample - noverlap);
     i = i + 1;
 end
 T = (round(nsample/2):(nsample-noverlap):N-1-round(nsample/2))/fs;

if show 
    % plot waveform
    subplot(2,1,1);
    t = (0:N-1)/fs;
    plot(t, x);
    legend('Waveform');
    xlabel('Time (s)');
    ylabel('Amplitude');
    xlim([t(1) t(end)]);

    % plot F0 track
    subplot(2,1,2);
    plot(T,F0);
    legend('pitch track');
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    xlim([t(1) t(end)]);
end

%---------------------------
function [c, y] = spCepstrum(x, fs, window, show)
 %% Initialization
 N = length(x);
 x = x(:); % assure column vector
 if ~exist('show', 'var') || isempty(show)
     show = 0;
 end
 if ~exist('window', 'var') || isempty(window)
     window = 'rectwin';
 end
 if ischar(window);
     window = eval(sprintf('%s(N)', window)); % hamming(N)
 end

 %% do fourier transform of a windowed signal
 x = x(:) .* window(:);
 y = fft(x, N);

 %% Cepstrum is IDFT (or DFT) of log spectrum
 c = ifft(log(abs(y)+eps));

 if show
     ms1=fs/1000; % 1ms. maximum speech Fx at 1000Hz
     ms20=fs/50;  % 20ms. minimum speech Fx at 50Hz

     %% plot waveform
     t=(0:N-1)/fs;        % times of sampling instants
     subplot(2,1,1);
     plot(t,x);
     legend('Waveform');
     xlabel('Time (s)');
     ylabel('Amplitude');

     %% plot cepstrum between 1ms (=1000Hz) and 20ms (=50Hz)
     %% DC component c(0) is too large
     q=(ms1:ms20)/fs;
     subplot(2,1,2);
     plot(q,abs(c(ms1:ms20)));
     legend('Cepstrum');
     xlabel('Quefrency (s) 1ms (1000Hz) to 20ms (50Hz)');
     ylabel('Amplitude');
 end

%----------------------
function [f0] = spPitchCepstrum(c, fs)
 % search for maximum  between 2ms (=500Hz) and 20ms (=50Hz)
 ms2=floor(fs*0.002); % 2ms
 ms20=floor(fs*0.02); % 20ms
 [maxi,idx]=max(abs(c(ms2:ms20)));
 f0 = fs/(ms2+idx-1);
