function varargout = MEAP(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MEAP_OpeningFcn, ...
                   'gui_OutputFcn',  @MEAP_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before MEAP is made visible.
function MEAP_OpeningFcn(hObject, ~, handles, varargin)
global paused togglerepeat surinitial bassinitial volume panelsum audiotimer audiotimer1
audiotimer = timer('TimerFcn',{@TimerCallback,hObject,handles},'StartFcn',@user_timer_start,'StopFcn',@user_timer_stop,'Period',1,'ExecutionMode','FixedRate','TasksToExecute',inf,'BusyMode','drop');
setappdata(hObject,'audiotimer',audiotimer);  
panelsum = [handles.panel_controls,handles.panel_speed,handles.trim1,handles.trim2,handles.startSection1,handles.endSection1,handles.startSection2,handles.endSection2,handles.panel_volume,handles.panel_set,handles.panel_file,handles.panel_details,handles.repeatbox2,handles.speed_text,handles.percentagetext,handles.maxtext,handles.mintext,handles.slider_text,handles.audio_text,handles.status_text,handles.timetext,handles.timer_text2,handles.surroundbox,handles.bassbox,handles.samplingtext,handles.channelstext,handles.fs_text,handles.hztext,handles.channel_text];
audiotimer1 = timer('TimerFcn',{@Timer2Callback,hObject,handles},'StartFcn',@user_timer_start,'StopFcn',@user_timer_stop,'Period',1,'ExecutionMode','FixedRate','TasksToExecute',inf,'BusyMode','drop');
setappdata(hObject,'audiotimer1',audiotimer1);

%setting up track 1
set(handles.timer_text2,'String','');
set(handles.status_text,'String','No file.');
set(handles.slider_text,'String','00:00');
set(handles.audio_stop,'Enable','off');
set(handles.audio_play,'Enable','off');
set(handles.button_set,'Enable','off');
set(handles.slider_speed,'Enable','off');
set(handles.speed_text,'String','0');
set(handles.audio_pause,'Enable','off');
set(handles.slider_pos,'Enable','off');
set(handles.surroundbox,'Enable','off');
set(handles.bassbox,'Enable','off');
set(handles.repeatbox,'Enable','off');
set(handles.plotbutton,'Enable','off');
volume = SoundVolume;
set(handles.slider_volume,'Value',volume);

%setting up track 2
set(handles.timer_text2,'String','');
set(handles.status_text2,'String','No file.');
set(handles.slider_text2,'String','00:00');
set(handles.audio_stop2,'Enable','off');
set(handles.audio_play2,'Enable','off');
set(handles.button_set2,'Enable','off');
set(handles.slider_speed2,'Enable','off');
set(handles.speed_text2,'String','0');
set(handles.audio_pause2,'Enable','off');
set(handles.slider_pos2,'Enable','off');
set(handles.surroundbox2,'Enable','off');
set(handles.bassbox2,'Enable','off');
set(handles.repeatbox2,'Enable','off');
set(handles.plotbutton2,'Enable','off');
set(handles.slider_volume2,'Value',volume);

surinitial = 0;
bassinitial = 0;
togglerepeat = 0;
paused = 0;
handles.output = hObject;
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MEAP_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;

function user_timer_start(~, ~)
function user_timer_stop(~, ~)

% --- Executes on button press in audio_load.
function audio_load_Callback(~, ~, handles)
global player1 fs t tstore astore fstore audio surinitial bassinitial suraudio1 suraudio2 bassaudio1  bassaudio2
set(handles.slider_speed,'Value',0);
set(handles.speed_text,'String','0');
[file,path] = uigetfile({'*.wav;*.mp4;*.au;'});
if (file(1) == 0) && (path(1) == 0)
    disp('');
else
    set(handles.status_text,'String','File loading ...');
    pause(0.1)
    file = fullfile(path,file);
    [audio,fs] = audioread(file);
    fstore = fs;
    t = length(audio) / fs;
    t = uint16(t);
    t = double(t);
    tstore = t;
    astore = audio;
    player1 = audioplayer(audio,fs);
    hpfilt = designfilt('lowpassiir', 'PassbandFrequency', 0.2, 'StopbandFrequency', 0.6, 'PassbandRipple', 1, 'StopbandAttenuation', 10);
    sdelay = ceil(20e-3 * fstore);
    suraudio1 = zeros(size(astore,1) + sdelay,2);
    q1 = sdelay : size(astore,1) + sdelay-1;
    q2 = 1 : size(astore,1);
    suraudio1(q1,1) = astore(:,1);
    suraudio1(q2,2) = astore(:,2);
    bassaudio1 = filtfilt(hpfilt,astore);
    q3 = sdelay : size(bassaudio1,1) + sdelay-1;
    q4 = 1 : size(bassaudio1,1);
    suraudio2(q3,1) = bassaudio1(:,1);
    suraudio2(q4,2) = bassaudio1(:,2);
    bassaudio2 = filtfilt(hpfilt,suraudio1);
    set(handles.fs_text,'String',get(player1,'SampleRate'));
    channels = get(player1,'NumberOfChannels');
    if channels == 1
        set(handles.channel_text,'String','1 (Mono)');
    else
        set(handles.channel_text,'String','2 (Stereo)');
    end
    bits = get(player1,'BitsPerSample');
    set(handles.bit_text,'String',bits);
    set(handles.slider_pos,'Enable','off');
    set(handles.button_set,'Enable','off');
    set(handles.audio_text,'String',file);
    set(handles.slider_speed,'Enable','on');
    set(handles.audio_stop,'Enable','off');
    set(handles.audio_play,'Enable','on');
    set(handles.slider_text,'String','00:00');
    set(handles.slider_pos,'Max',tstore);
    set(handles.slider_pos,'Min',0);
    set(handles.surroundbox,'Value',0);
    set(handles.bassbox,'Value',0);
    set(handles.repeatbox,'Enable','on');
    set(handles.plotbutton,'Enable','on');
    set(handles.status_text,'String','File loaded.');
    
    plot(player1)
    surinitial = 0;
    bassinitial = 0;
end
 
% --- Executes on button press in audio_play.
function audio_play_Callback(~, ~, handles)
global t tstore paused player1 audiotimer
t = tstore;
play(player1)
start(audiotimer)
set(handles.audio_pause,'Enable','on');
set(handles.audio_stop,'Enable','on');
set(handles.slider_speed,'Enable','off');
set(handles.audio_load,'Enable','off');
set(handles.audio_play,'Enable','off');
set(handles.button_set,'Enable','on');
set(handles.slider_pos,'Enable','on');
set(handles.audio_pause,'Enable','on');
set(handles.surroundbox,'Enable','on');
set(handles.bassbox,'Enable','on');
set(handles.plotbutton,'Enable','on');
set(handles.status_text,'String','Playing ...');
if paused == 1;
    set(handles.audio_pause,'String','Pause');
    set(handles.status_text,'String','Paused.');
    paused = 0;
end
 
% --- Executes on button press in audio_pause.
function audio_pause_Callback(hObject, ~, handles)
global paused player1 audiotimer
if paused == 0
    pause(player1)
    stop(audiotimer)
    set(hObject,'String','Resume');
    set(handles.status_text,'String','Paused.');
    set(handles.slider_pos,'Enable','off');
    set(handles.button_set,'Enable','off');
    set(handles.surroundbox,'Enable','off');
    set(handles.bassbox,'Enable','off');
    paused = 1;
else
    if (paused == 1)
        resume(player1)
        start(audiotimer)
        paused = 0;
        set(hObject,'String','Pause');
        set(handles.status_text,'String','Playing ...');
        set(handles.slider_pos,'Enable','on');
        set(handles.button_set,'Enable','on');
        set(handles.surroundbox,'Enable','on');
        set(handles.bassbox,'Enable','on');
    end
end

% --- Executes on button press in audio_stop.
function audio_stop_Callback(~, ~, handles)
global player1 t tstore audiotimer
t = tstore;
stop(player1)
stop(audiotimer)
set(handles.timer_text,'String','');
set(handles.button_set,'Enable','off');
set(handles.slider_pos,'Enable','off');
set(handles.slider_speed,'Enable','on');
set(handles.audio_pause,'Enable','off');
set(handles.button_set,'Enable','off');
set(handles.audio_load,'Enable','on');
set(handles.audio_play,'Enable','on');
set(handles.surroundbox,'Enable','off');
set(handles.bassbox,'Enable','off');
set(handles.plotbutton,'Enable','off');
set(handles.status_text,'String','Stopped.');

% --- Executes on slider movement.
function slider_speed_Callback(hObject, ~, handles)
global player1 audio fs t tstore fstore spdrate
spdrate = get(hObject,'Value');
set(handles.speed_text,'String',fix(spdrate))
set(player1,'SampleRate',fs*((spdrate/100)+1))
fstore = get(player1,'SampleRate');
set(handles.fs_text,'String',get(player1,'SampleRate'))
t = length(audio) / get(player1,'SampleRate');
t = uint16(t);
t = double(t);
tstore = t;
set(handles.slider_pos,'Max',tstore);

% --- Executes during object creation, after setting all properties.
function slider_speed_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider_volume_Callback(hObject, ~, ~)
global  volume
volume = SoundVolume((get(hObject,'Value')));

function slider_volume_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% Timer function for Track 1
function TimerCallback(~,~,~,handles)
global t tstore mins secs tf togglerepeat player1 audiotimer
hours = floor(t / 3600);
t = t - hours * 3600;
mins = floor(t / 60);
secs = t - mins * 60;
hms = sprintf('%02d:%02d',mins,secs);
set(handles.timer_text,'String',hms)
t = t-1;
tf = strcmp(hms,'00:00');
if (tf == 1) && (togglerepeat == 0)
    set(handles.status_text,'String','Stopped.');
    set(handles.timer_text,'String','');
    set(handles.button_set,'Enable','off');
    set(handles.slider_pos,'Enable','off');
    set(handles.slider_speed,'Enable','on');
    set(handles.audio_pause,'Enable','off');
    set(handles.button_set,'Enable','off');
    set(handles.audio_load,'Enable','on');
    set(handles.audio_play,'Enable','on');
    set(handles.surroundbox,'Enable','off');
    set(handles.bassbox,'Enable','off');
    set(handles.plotbutton,'Enable','off');
    stop(audiotimer)
    stop(player1)
else if (tf == 1) && (togglerepeat == 1)
        set(handles.status_text,'String','Repeating ...');
        set(handles.button_set,'Enable','off');
        set(handles.slider_pos,'Enable','off');
        set(handles.audio_pause,'Enable','off');
        set(handles.audio_stop,'Enable','off');
        set(handles.button_set,'Enable','off');
        set(handles.surroundbox,'Enable','off');
        set(handles.bassbox,'Enable','off');
        t = tstore;
        pause(1)
        play(player1)
        set(handles.status_text,'String','Playing ...');
        set(handles.button_set,'Enable','on');
        set(handles.slider_pos,'Enable','on');
        set(handles.audio_pause,'Enable','on');
        set(handles.audio_stop,'Enable','on');
        set(handles.button_set,'Enable','on');
        set(handles.surroundbox,'Enable','on');
        set(handles.bassbox,'Enable','on');
    end
end

% Timer function for Track 2
function Timer2Callback(~,~,~,handles)
global t2 tstore2 mins secs tf togglerepeat player2 audiotimer1
hours = floor(t2 / 3600);
t2 = t2 - hours * 3600;
mins = floor(t2 / 60);
secs = t2 - mins * 60;
hms = sprintf('%02d:%02d',mins,secs);
set(handles.timer_text2,'String',hms)
t2 = t2-1;
tf = strcmp(hms,'00:00');
if (tf == 1) && (togglerepeat == 0)
    set(handles.status_text2,'String','Stopped.');
    set(handles.timer_text2,'String','');
    set(handles.button_set2,'Enable','off');
    set(handles.slider_pos2,'Enable','off');
    set(handles.slider_speed2,'Enable','on');
    set(handles.audio_pause2,'Enable','off');
    set(handles.button_set2,'Enable','off');
    set(handles.audio_load2,'Enable','on');
    set(handles.audio_play2,'Enable','on');
    set(handles.surroundbox2,'Enable','off');
    set(handles.bassbox2,'Enable','off');
    set(handles.plotbutton2,'Enable','off');
    stop(audiotimer1)
    stop(player2)
else if (tf == 1) && (togglerepeat == 1)
        set(handles.status_text2,'String','Repeating ...');
        set(handles.button_set2,'Enable','off');
        set(handles.slider_pos2,'Enable','off');
        set(handles.audio_pause2,'Enable','off');
        set(handles.audio_stop2,'Enable','off');
        set(handles.button_set2,'Enable','off');
        set(handles.surroundbox2,'Enable','off');
        set(handles.bassbox2,'Enable','off');
        t2 = tstore2;
        pause(1)
        play(player2)
        set(handles.status_text2,'String','Playing ...');
        set(handles.button_set2,'Enable','on');
        set(handles.slider_pos2,'Enable','on');
        set(handles.audio_pause2,'Enable','on');
        set(handles.audio_stop2,'Enable','on');
        set(handles.button_set2,'Enable','on');
        set(handles.surroundbox2,'Enable','on');
        set(handles.bassbox2,'Enable','on');
    end
end

% --- Executes on slider movement.
function slider_pos_Callback(hObject, ~, handles)
global pos
pos = get(hObject,'Value');
pos = uint16(pos);
pos = double(pos);
pstore = pos;
phours = floor(pstore / 3600);
pstore = pstore - phours * 3600;
pmins = floor(pstore / 60);
psecs = pstore - pmins * 60;
phms = sprintf('%02d:%02d',pmins,psecs);
set(handles.slider_text,'String',phms)

% --- Executes during object creation, after setting all properties.
function slider_pos_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in button_set.
function button_set_Callback(~, ~, handles)
global player1 pos t tstore tf audiotimer
skip = player1.SampleRate*pos;
if (pos == tstore)
    t = tstore - pos;
    stop(player1)
    set(handles.status_text,'String','Stopped.');
    set(handles.audio_pause,'Enable','off');
    set(handles.audio_stop,'Enable','off');
    set(handles.audio_play,'Enable','on');
    set(handles.audio_load,'Enable','on');
else
    if (tf == 0)
        t = tstore - pos;
        stop(player1)
        play(player1,skip)
        set(handles.status_text,'String','Playing ...');
        set(handles.audio_pause,'Enable','on');
        set(handles.audio_stop,'Enable','on');
        set(handles.audio_play,'Enable','off');
        set(handles.audio_load,'Enable','off');
    else
        t = tstore - pos;
        stop(player1)
        play(player1,skip)
        start(audiotimer)
        set(handles.status_text,'String','Playing ...');
        set(handles.audio_pause,'Enable','on');
        set(handles.audio_play,'Enable','off');
        set(handles.audio_stop,'Enable','on');
        set(handles.audio_load,'Enable','off');
    end
end

function button_set2_Callback (~, ~, handles)
global player2 pos t tstore tf audiotimer1
skip = player2.SampleRate*pos;
if (pos == tstore)
    t = tstore - pos;
    stop(player2)
    set(handles.status_text2,'String','Stopped.');
    set(handles.audio_pause2,'Enable','off');
    set(handles.audio_stop2,'Enable','off');
    set(handles.audio_play2,'Enable','on');
    set(handles.audio_load2,'Enable','on');
else
    if (tf == 0)
        t = tstore - pos;
        stop(player2)
        play(player2,skip)
        set(handles.status_text2,'String','Playing ...');
        set(handles.audio_pause2,'Enable','on');
        set(handles.audio_stop2,'Enable','on');
        set(handles.audio_play2,'Enable','off');
        set(handles.audio_load2,'Enable','off');
    else
        t = tstore - pos;
        stop(player2)
        play(player2,skip)
        start(audiotimer1)
        set(handles.status_text2,'String','Playing ...');
        set(handles.audio_pause2,'Enable','on');
        set(handles.audio_play2,'Enable','off');
        set(handles.audio_stop2,'Enable','on');
        set(handles.audio_load2,'Enable','off');
    end
end

% --- Executes on button press in repeatbox.
function repeatbox_Callback(~, ~, handles)
global togglerepeat
togglerepeat = get(handles.repeatbox,'Value');

% --- Executes on button press in repeatbox2.
function repeatbox2_Callback(~, ~, handles)
global togglerepeat
togglerepeat = get(handles.repeatbox2,'Value');

% --- Executes on button press in surroundbox.
function surroundbox_Callback(~, ~, ~)
global player t tstore  astore fstore suraudio1 bassaudio1 suraudio2 surinitial bassinitial
flashpos = player.SampleRate*(tstore-t);
if (surinitial == 0) && (bassinitial == 0)
    stop(player)
    player = audioplayer(suraudio1,fstore);
    play(player,flashpos)
    surinitial = 1;
else
    if (surinitial == 0) && (bassinitial == 1)
    stop(player)
    player = audioplayer(suraudio2,fstore);
    play(player,flashpos)
    surinitial = 1;
    else
        if (surinitial == 1) && (bassinitial == 0)
        stop(player)
        player = audioplayer(astore,fstore);
        play(player,flashpos)
        surinitial = 0;
        else
            if (surinitial == 1) && (bassinitial == 1)
            player = audioplayer(bassaudio1,fstore);
            play(player,flashpos)
            surinitial = 0;
            end
        end
    end
end

% --- Executes on button press in bassbox.
function bassbox_Callback(~, ~, ~)
global player t tstore astore fstore suraudio1 bassaudio1 bassaudio2 surinitial bassinitial
flashpos = player.SampleRate*(tstore-t);
if (surinitial == 0) && (bassinitial == 0)
    stop(player)
    player = audioplayer(bassaudio1,fstore);
    play(player,flashpos)
    bassinitial = 1;
else
    if (surinitial == 0) && (bassinitial == 1)
    stop(player)
    player = audioplayer(astore,fstore);
    play(player,flashpos)
    bassinitial = 0;
    else
        if (surinitial == 1) && (bassinitial == 0)
        stop(player)
        player = audioplayer(bassaudio2,fstore);
        play(player,flashpos)
        bassinitial = 1;
        else
            if (surinitial == 1) && (bassinitial == 1)
            player = audioplayer(suraudio1,fstore);
            play(player,flashpos)
            bassinitial = 0;
            end
        end
    end
end

% --- Executes on button press in plotbutton.
function plotbutton_Callback(~, ~, ~)
global tstore astore fstore suraudio1 bassaudio1 bassaudio2 surinitial bassinitial
figure
tplot1 = linspace(0,tstore,length(astore));
nfft1 = min(256,length(astore));
tplot2 = linspace(0,tstore,length(suraudio1));
nfft2 = min(256,length(suraudio1));
tplot3 = linspace(0,tstore,length(bassaudio1));
nfft3 = min(256,length(bassaudio1));
tplot4 = linspace(0,tstore,length(bassaudio2));
nfft4 = min(256,length(bassaudio2));
if (surinitial == 0) && (bassinitial == 0)
    subplot(2,1,1)
    plot(tplot1,astore), title('Waveform'), xlabel('Seconds'), axis tight
    subplot(2,1,2)
    specgram(astore(:,1),nfft1,fstore), title('Spectogram'), xlabel('Seconds');
else
    if (surinitial == 1) && (bassinitial == 0)
    subplot(2,1,1)
    plot(tplot2,suraudio1), title('Waveform'), xlabel('Seconds'), axis tight
    subplot(2,1,2)
    specgram(suraudio1(:,1),nfft2,fstore), title('Spectogram'), xlabel('Seconds')
    else
        if (surinitial == 0) && (bassinitial == 1)
            subplot(2,1,1)
            plot(tplot3,bassaudio1), title('Waveform'), xlabel('Seconds'), axis tight
            subplot(2,1,2)
            specgram(bassaudio1(:,1),nfft3,fstore), title('Spectogram'), xlabel('Seconds')
        else
            if (surinitial == 1) && (bassinitial == 1)
            subplot(2,1,1)
            plot(tplot4,bassaudio2), title('Waveform'), xlabel('Seconds'), axis tight
            subplot(2,1,2)
            specgram(bassaudio2(:,1),nfft4,fstore), title('Spectogram'), xlabel('Seconds')
            end
        end
    end
end

% --- Executes on button press in creditsbutton.
function creditsbutton_Callback(~, ~, ~)
msg = {'Created by Enric-Jeremy for Assignment 1(2020).';...
               '';...
               'Basic Controls';
               '';...
               'Load - load a track into a section';
               'Play - play a track in a section';
               'Pause/Resume - pause a playing track or resume a paused track';
               'Stop - stop a playing or paused track';
               'Repeat - play a track on loop if checked'
               '';...
               'Advanced Controls';
               '';...
               'Time Slider - start a track from a specific point of the track';
               'Trim Track - trim a track by specifying in and out points';
               'Speed Slider - change the playing speed of a track';
               'Volume Slider - change the volume of a track';
               'Surround Sound - change the audio to surround sound';
               'Enhanced Bass - increment the bass of a track';
               'Generate Audio Signal - generate a visual waveform and spectrogram of a track';
               'Start Recording - start recording and play all tracks simultaneously';
               'Stop Recording - stops the recording';
               'Export Recording - exports the recording in a variety of formats';};
msgbox(msg,'Annot8 Manual','modal');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, guidata)
closereq;


% --- Executes on key press with focus on audio_load and none of its controls.
function audio_load_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to audio_load (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in audio_load2.
% --- Executes on button press in audio_load2.
function audio_load2_Callback(hObject, eventdata, handles)
% hObject    handle to audio_load2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global player2 fs t2 tstore2 astore fstore audio surinitial bassinitial suraudio1 suraudio2 bassaudio1 bassaudio2
set(handles.slider_speed2,'Value',0);
set(handles.speed_text2,'String','0');
[file,path] = uigetfile({'*.wav;*.mp3;'});
if (file(1) == 0) && (path(1) == 0)
    disp('');
else
    set(handles.status_text2,'String','File loading ...');
    pause(0.1)
    file = fullfile(path,file);
    [audio,fs] = audioread(file);
    fstore = fs;
    t2 = length(audio) / fs;
    t2 = uint16(t2);
    t2 = double(t2);  
    tstore2 = t2;
    astore = audio;
    player2 = audioplayer(audio,fs);
    hpfilt = designfilt('lowpassiir', 'PassbandFrequency', 0.2, 'StopbandFrequency', 0.6, 'PassbandRipple', 1, 'StopbandAttenuation', 10);
    sdelay = ceil(20e-3 * fstore);
    suraudio1 = zeros(size(astore,1) + sdelay,2);
    q1 = sdelay : size(astore,1) + sdelay-1;
    q2 = 1 : size(astore,1);
    suraudio1(q1,1) = astore(:,1);
    suraudio1(q2,2) = astore(:,2);
    bassaudio1 = filtfilt(hpfilt,astore);
    q3 = sdelay : size(bassaudio1,1) + sdelay-1;
    q4 = 1 : size(bassaudio1,1);
    suraudio2(q3,1) = bassaudio1(:,1);
    suraudio2(q4,2) = bassaudio1(:,2);
    bassaudio2 = filtfilt(hpfilt,suraudio1);
    set(handles.fs_text2,'String',get(player2,'SampleRate'));
    channels = get(player2,'NumberOfChannels');
    if channels == 1
        set(handles.channel_text2,'String','1 (Mono)');
    else
        set(handles.channel_text2,'String','2 (Stereo)');
    end
    set(handles.slider_pos2,'Enable','off');
    set(handles.button_set2,'Enable','off');
    set(handles.audio_text2,'String',file);
    set(handles.slider_speed2,'Enable','on');
    set(handles.audio_stop2,'Enable','off');
    set(handles.audio_play2,'Enable','on');
    set(handles.slider_text2,'String','00:00');
    set(handles.slider_pos2,'Max',tstore2);
    set(handles.slider_pos2,'Min',0);
    set(handles.surroundbox2,'Value',0);
    set(handles.bassbox2,'Value',0);
    set(handles.repeatbox2,'Enable','on');
    set(handles.plotbutton2,'Enable','on');
    set(handles.status_text2,'String','File loaded.');
    surinitial = 0;
    bassinitial = 0;
end

% --- Executes on button press in audio_play2.
% --- Executes on button press in audio_play2.
function audio_play2_Callback(hObject, eventdata, handles)
% hObject    handle to audio_play2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t2 tstore2 paused2 player2 audiotimer1
t2 = tstore2;
play(player2)
start(audiotimer1)
set(handles.audio_pause2,'Enable','on');
set(handles.audio_stop2,'Enable','on');
set(handles.slider_speed2,'Enable','off');
set(handles.audio_load2,'Enable','off');
set(handles.audio_play2,'Enable','off');
set(handles.button_set2,'Enable','on');
set(handles.slider_pos2,'Enable','on');
set(handles.audio_pause2,'Enable','on');
set(handles.surroundbox2,'Enable','on');
set(handles.bassbox2,'Enable','on');
set(handles.plotbutton2,'Enable','on');
set(handles.status_text2,'String','Playing ...');
if paused2 == 1;
    set(handles.audio_pause2,'String','Pause');
    set(handles.status_text2,'String','Paused.');
    paused2 = 0;
end


% --- Executes on button press in audio_pause2.
function audio_pause2_Callback(hObject, eventdata, handles)
% hObject    handle to audio_pause2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global paused2 player2 audiotimer1
if paused2 == 0
    pause(player2)
    stop(audiotimer1)
    set(hObject,'String','Resume');
    set(handles.status_text2,'String','Paused.');
    set(handles.slider_pos2,'Enable','off');
    set(handles.button_set2,'Enable','off');
    set(handles.surroundbox2,'Enable','off');
    set(handles.bassbox2,'Enable','off');
    paused2 = 1;
else
    if (paused2 == 1)
        resume(player2)
        start(audiotimer1)
        paused2 = 0;
        set(hObject,'String','Pause');
        set(handles.status_text2,'String','Playing ...');
        set(handles.slider_pos2,'Enable','on');
        set(handles.button_set2,'Enable','on');
        set(handles.surroundbox2,'Enable','on');
        set(handles.bassbox2,'Enable','on');
    end
end


% --- Executes on button press in audio_stop2.
function audio_stop2_Callback(hObject, eventdata, handles)
% hObject    handle to audio_stop2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global player2 t2 tstore2 audiotimer1
t2 = tstore2;
stop(player2)
stop(audiotimer1)
set(handles.timer_text2,'String','');
set(handles.button_set2,'Enable','off');
set(handles.slider_pos2,'Enable','off');
set(handles.slider_speed2,'Enable','on');
set(handles.audio_pause2,'Enable','off');
set(handles.button_set2,'Enable','off');
set(handles.audio_load2,'Enable','on');
set(handles.audio_play2,'Enable','on');
set(handles.surroundbox2,'Enable','off');
set(handles.bassbox2,'Enable','off');
set(handles.plotbutton2,'Enable','off');
set(handles.status_text2,'String','Stopped.');



% --- Executes on slider movement.
function slider_pos2_Callback(hObject, eventdata, handles)
% hObject    handle to slider_pos2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_pos2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_pos2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in surroundbox2.
function surroundbox2_Callback(hObject, eventdata, handles)
% hObject    handle to surroundbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of surroundbox2
global player t tstore  astore fstore suraudio1 bassaudio1 suraudio2 surinitial bassinitial
flashpos = player.SampleRate*(tstore-t);
if (surinitial == 0) && (bassinitial == 0)
    stop(player)
    player = audioplayer(suraudio1,fstore);
    play(player,flashpos)
    surinitial = 1;
else
    if (surinitial == 0) && (bassinitial == 1)
    stop(player)
    player = audioplayer(suraudio2,fstore);
    play(player,flashpos)
    surinitial = 1;
    else
        if (surinitial == 1) && (bassinitial == 0)
        stop(player)
        player = audioplayer(astore,fstore);
        play(player,flashpos)
        surinitial = 0;
        else
            if (surinitial == 1) && (bassinitial == 1)
            player = audioplayer(bassaudio1,fstore);
            play(player,flashpos)
            surinitial = 0;
            end
        end
    end
end


% --- Executes on button press in bassbox2.
function bassbox2_Callback(hObject, eventdata, handles)
% hObject    handle to bassbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of bassbox2
global player t tstore astore fstore suraudio1 bassaudio1 bassaudio2 surinitial bassinitial
flashpos = player.SampleRate*(tstore-t);
if (surinitial == 0) && (bassinitial == 0)
    stop(player)
    player = audioplayer(bassaudio1,fstore);
    play(player,flashpos)
    bassinitial = 1;
else
    if (surinitial == 0) && (bassinitial == 1)
    stop(player)
    player = audioplayer(astore,fstore);
    play(player,flashpos)
    bassinitial = 0;
    else
        if (surinitial == 1) && (bassinitial == 0)
        stop(player)
        player = audioplayer(bassaudio2,fstore);
        play(player,flashpos)
        bassinitial = 1;
        else
            if (surinitial == 1) && (bassinitial == 1)
            player = audioplayer(suraudio1,fstore);
            play(player,flashpos)
            bassinitial = 0;
            end
        end
    end
end

% --- Executes on button press in exportbutton.
function exportbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exportbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global playerObj;
global recObj;
disp('[INFO] Exporting recording ...')
 
% get audio data
y = getaudiodata(recObj);
% --- playerObj = getplayer(recObj);
% --- disp(playerObj);
 
% export audio
fileName = uiputfile({'*.wav';'*.au';'*.mp4'},'Save Audio As'); %saving the recorded audio
audiowrite(fileName,y, 8000); %writes the audio file with a sample rate of 8000



% --- Executes on slider movement.
function slider_volume2_Callback(hObject, eventdata, handles)
% hObject    handle to slider_volume2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global  volume
volume = SoundVolume((get(hObject,'Value')));

% --- Executes during object creation, after setting all properties.
function slider_volume2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_volume2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_speed2_Callback(hObject, eventdata, handles)
% hObject    handle to slider_speed2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global player audio fs t tstore fstore spdrate
spdrate = get(hObject,'Value');
set(handles.speed_text2,'String',fix(spdrate))
set(player,'SampleRate',fs*((spdrate/100)+1))
fstore = get(player,'SampleRate');
set(handles.fs_text2,'String',get(player,'SampleRate'))
t = length(audio) / get(player,'SampleRate');
t = uint16(t);
t = double(t);
tstore = t;
set(handles.slider_pos2,'Max',tstore);

% --- Executes during object creation, after setting all properties.
function slider_speed2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_speed2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in plotbutton2.
function plotbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to plotbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tstore astore fstore suraudio1 bassaudio1 bassaudio2 surinitial bassinitial
figure
tplot1 = linspace(0,tstore,length(astore));
nfft1 = min(256,length(astore));
tplot2 = linspace(0,tstore,length(suraudio1));
nfft2 = min(256,length(suraudio1));
tplot3 = linspace(0,tstore,length(bassaudio1));
nfft3 = min(256,length(bassaudio1));
tplot4 = linspace(0,tstore,length(bassaudio2));
nfft4 = min(256,length(bassaudio2));
if (surinitial == 0) && (bassinitial == 0)
    subplot(2,1,1)
    plot(tplot1,astore), title('Waveform'), xlabel('Seconds'), axis tight
    subplot(2,1,2)
    specgram(astore(:,1),nfft1,fstore), title('Spectogram'), xlabel('Seconds');
else
    if (surinitial == 1) && (bassinitial == 0)
    subplot(2,1,1)
    plot(tplot2,suraudio1), title('Waveform'), xlabel('Seconds'), axis tight
    subplot(2,1,2)
    specgram(suraudio1(:,1),nfft2,fstore), title('Spectogram'), xlabel('Seconds')
    else
        if (surinitial == 0) && (bassinitial == 1)
            subplot(2,1,1)
            plot(tplot3,bassaudio1), title('Waveform'), xlabel('Seconds'), axis tight
            subplot(2,1,2)
            specgram(bassaudio1(:,1),nfft3,fstore), title('Spectogram'), xlabel('Seconds')
        else
            if (surinitial == 1) && (bassinitial == 1)
            subplot(2,1,1)
            plot(tplot4,bassaudio2), title('Waveform'), xlabel('Seconds'), axis tight
            subplot(2,1,2)
            specgram(bassaudio2(:,1),nfft4,fstore), title('Spectogram'), xlabel('Seconds')
            end
        end
    end
end


% --- Executes during object creation, after setting all properties.
function status_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status_text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function status_text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status_text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in audio_play2.
function pushbutton51_Callback(hObject, eventdata, handles)
% hObject    handle to audio_play2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in audio_pause2.
function pushbutton52_Callback(hObject, eventdata, handles)
% hObject    handle to audio_pause2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton53.
function pushbutton53_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider16_Callback(hObject, eventdata, handles)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function startSection1_Callback(hObject, eventdata, handles)
% hObject    handle to startSection1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startSection1 as text
%        str2double(get(hObject,'String')) returns contents of startSection1 as a double


% --- Executes during object creation, after setting all properties.
function startSection1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startSection1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endSection1_Callback(hObject, eventdata, handles)
% hObject    handle to endSection1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endSection1 as text
%        str2double(get(hObject,'String')) returns contents of endSection1 as a double


% --- Executes during object creation, after setting all properties.
function endSection1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endSection1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton54.
function pushbutton54_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function startSection2_Callback(hObject, eventdata, handles)
% hObject    handle to startSection2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startSection2 as text
%        str2double(get(hObject,'String')) returns contents of startSection2 as a double


% --- Executes during object creation, after setting all properties.
function startSection2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startSection2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endSection2_Callback(hObject, eventdata, handles)
% hObject    handle to endSection2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endSection2 as text
%        str2double(get(hObject,'String')) returns contents of endSection2 as a double


% --- Executes during object creation, after setting all properties.
function endSection2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endSection2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in trim1.
function trim1_Callback(hObject, eventdata, handles)
global t player data0;
% hObject    handle to trim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SectionStart = get(handles.startSection1, 'string');   
SectionEnd = get(handles.endSection1, 'string');
idx = (t >= str2num(SectionStart) & t < str2num(SectionEnd));
data0 = player(idx);



% --- Executes on button press in trim2.
function trim2_Callback(hObject, eventdata, handles)
global t player data1;
% hObject    handle to trim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SectionStart1 = get(handles.startSection2, 'string');   
SectionEnd1 = get(handles.endSection2, 'string');
idx = (t >= str2num(SectionStart1) & t < str2num(SectionEnd1));
data1 = player(idx);


% --- Executes on button press in start_rec.
function start_rec_Callback(~, eventdata, handles)
% hObject    handle to start_rec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global player1 player2 recObj;
 
% start recording
recObj = audiorecorder(8000,16,2);
record(recObj);
disp('[INFO] Recording in progress now ...')
 
% play all audio
play(player1)
play(player2)
disp('[INFO] Playing all audio ...')

% --- Executes on button press in stop_rec.
function stop_rec_Callback(hObject, eventdata, handles)
% hObject    handle to stop_rec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global recObj player1 player2;
 
% stop recording
stop(player1)
stop(player2)
stop(recObj)
disp('[INFO] Stopped recording ...')
