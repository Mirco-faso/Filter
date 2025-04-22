close all   
clearvars   
clc         

%carico il file con il segnale audio
load audio1.mat;

%ascolto il segnale audio
player = audioplayer(x,Fs);
play(player);
pause(15);
stop(player);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%faccio la trasformata di fourier del segnale x(t)
N = length(x);
Ts = 1/Fs;

w = 2*pi/(N*Ts)*(-N/2:N/2-1);
X = fftshift(fft(x))*Ts;

figure
f = w/(2*pi);
plot(f,abs(X))
xlim([f(1),f(end)])
title("Trasformata di Fourier di x");
xlabel("f [Hz]");
ylabel("|X(f)|");
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%creo e applico il primo filto filtro per eliminare il rumore alla
%frequenza 6kHz
f1= 6000;
h1 = NF_design(f1,Fs);
x_filt1 = filter(h1,x);

%creo e applico il primo filto filtro per eliminare il rumore alla
%frequenza 6kHz
f2= 3000;
h2 = NF_design(f2,Fs);
x_filt2 = filter(h2,x_filt1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%faccio la trasformata di Fourier del segnale filtrato x_filt2
N = length(x_filt2);
Ts = 1/Fs; 

w = 2*pi/(N*Ts)*(-N/2:N/2-1);
X_filt2 = fftshift(fft(x_filt2))*Ts;

figure
f = w/(2*pi);
plot(f,abs(X_filt2))
xlim([f(1),f(end)])
title("Trasformata di Fourier di x-filt2");
xlabel("f [Hz]");
ylabel("|X-filt2(f)|");
grid on;

%ascolto il segnale filtrato x_filt e confermo che non ci siano rumori
player = audioplayer(x_filt2,Fs);
play(player);
pause(15);
stop(player);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Design a notch filter
% f0 = center frequency of the filter [Hz]
% Fs = sample rate of the signal to be filtered [Hz]
function NF = NF_design(f0,Fs)
    N = 6; % filter order
    Q = 30; % quality factor of the filter
    % Tolerances in passband (deltap) and stopband (delats)
    deltap = 0.01;
    deltas = 0.001;
    % Tolerances expressed in dB
    Ap = 20*log10(1+deltap)-20*log10(1-deltap); % (approximate)
    Ast = -20*log10(deltas);
    % Filter implementation
    SPEC = 'N,F0,Q,Ap,Ast';
    NF_spec = fdesign.notch(SPEC,N,f0,Q,Ap,Ast,Fs);
    NF = design(NF_spec);
    % Plot of the frequency response
    % The blue line represents the frequency response of the designed filter
    fvtool(NF);
end