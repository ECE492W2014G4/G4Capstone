% Distortion Component for MATLAB Simulation

% Read Input File
[wav1,Fs,nbits] = wavread('sample_wav.wav','native');
wav_size = length(wav1);
one_chan_wav = zeros(1,wav_size);
columntocopy = 1;
one_chan_wav = wav1(:, 1);

% Plot Input Wav File
dt = 1/Fs;
t = 0:dt:(wav_size*dt)-dt;
figure
plot(t,one_chan_wav); xlabel('Seconds'); ylabel('Amplitude');

% Test input
input = one_chan_wav;

% Initialize array with zeros
output = zeros(1, wav_size);

% Set clip value
clip_value = 3000;

% Pseudo code
for i = 1:length(input)
	if input(i) < 0 % check if negative
		if input(i) < -clip_value % if the input is less than the negative clip_value
			output(i) = -clip_value;
		else
			output(i) = input(i);
		end
	elseif input(i) > 0 % check if positive
		if input(i) > clip_value % if the input is greater than the positive clip_value
			output(i) = clip_value;
		else
			output(i) = input(i);
		end
	end
end

% Plot Output
% Plot Input Wav File
dt = 1/Fs;
t = 0:dt:(wav_size*dt)-dt;
figure
ax = plot(t,output); xlabel('Seconds'); ylabel('Amplitude');
ax.XTick = [0 .2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2];
ylim([-4000 4000]);
%axis([0 3 -600 600]);


% Check if output = expected output
expected_output = [-20 400 400 152 400 -400 -32 0 400 -231];
if isequal(output,expected_output)
    fprintf('Outputs are equal\n');
end


% Write the signal x to a .wav file
% Used to normalize the output signal. Reference: http://www.mathworks.com/matlabcentral/answers/50521-writing-a-wav-file-using-matlab
output = output./max(abs(output(:)))*(1-(2^-(16-1)));
wavwrite(output,Fs,16,'C:\Users\Jarvis\Documents\University of Alberta\ECE 492\Capstone\Simulations\Distortion\modified_output_3000.wav');

