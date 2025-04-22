close all   
clearvars   
clc         

%carico il segnale audio y
load audio2.mat;

%ascolto il segnale y
player = audioplayer(y,Ff);
play(player);
pause(15);
stop(player);

%creo il segnale y_sampled prendendo un campione ogni quattro da y, questo
%per il fatto che la frequenza di campionamento Fs è un quarto di Ff
Fs = Ff/4;
y_sampled = y(1:4:end);

%ascolto il segnale campionato e mi accorgo che c'è un disturbo
player = audioplayer(y_sampled,Fs);
play(player);
pause(15);
stop(player);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%faccio la trasformata di Fourier di y_sampled
N = length(y_sampled);
Ts = 1/Fs; 

w = 2*pi/(N*Ts)*(-N/2:N/2-1);
Y_sampled = fftshift(fft(y_sampled))*Ts; %questa formula dovrebbe essere moltiplicata per il termine exp(-1j*w2*t2(1)) ma questo temine è 1 quindi viene omesso

figure
f = w/(2*pi);
plot(f,abs(Y_sampled))
xlim([f(1),f(end)])
title("Trasformata di Fourier di y-sampled");
xlabel("f [Hz]");
ylabel("|Y-sampled(f)|");
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creo un filtro passa-basso che lascia passare le frequenze inferiori agli
% 3.8kHz che si osservi essere la frequenza alla quale c'è un picco sullo
% spettro di y_sampled
f_stop = 3800;
h = LPF_design(f_stop,Fs);
y_filt = filter(h,y_sampled);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ascolto il segnale filtrato e mi accorgo che non ci sono rumori
player = audioplayer(y_filt,Fs);
play(player);
pause(15);
stop(player);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plotto nello stesso grafico gli spettri di y_filt e y_sampled
N = length(y_filt);
Ts = 1/Fs;

w = 2*pi/(N*Ts)*(-N/2:N/2-1);
Y_filt = fftshift(fft(y_filt))*Ts;

figure
hold on
f = w/(2*pi);
plot(f,abs(Y_sampled))
plot(f,abs(Y_filt),'r:')
xlim([f(1),f(end)])
legend('trasformata di y-sampled','trasformata di y-filt')
title('confronto  degli spettri di y-sampled e y-filt');
xlabel("f [Hz]");
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Design a low−pass filter
% f_stop = stopband frequency of the filter [Hz]
% Fs = sample rate of the signal to be filtered [Hz]
function LPF = LPF_design(f_stop,Fs)
    % Passband frequency
    f_pass = f_stop - 1000;
    % Tolerances in passband (deltap) and stopband (delats)
    deltap=0.01;
    deltas=0.001;
    % Tolerances expressed in dB
    Ap = 20*log10(1+deltap)-20*log10(1-deltap); % (approximate)
    Ast = -20*log10(deltas);
    % Filter implementation
    SPEC = 'Fp,Fst,Ap,Ast';
    LP_spec = fdesign.lowpass(SPEC,f_pass,f_stop,Ap,Ast,Fs);
    LPF = design(LP_spec,'equiripple');
    % Plot of the frequency response
    % The red dotted line represents the tolerance in the passband tolerance,
    % the transition band and the stopband while the blue line represents the
    % frequency response of the designed filter
    fvtool(LPF);
end