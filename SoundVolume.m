function volume = SoundVolume(volume)
    if ~usejava('awt')
        error('YMA:SoundVolume:noJava','SoundVolume only works on Matlab envs that run on java');
    end
    if nargin && (~isnumeric(volume) || length(volume)~=1 || volume<0 || volume>1)
        error('YMA:SoundVolume:badVolume','Volume value must be a scalar number between 0.0 and 1.0')
    end
    import javax.sound.sampled.*
    mixerInfos = AudioSystem.getMixerInfo;
    foundFlag = 0;
    for mixerIdx = 1 : length(mixerInfos)
        if foundFlag,  break;  end
        ports = getTargetLineInfo(AudioSystem.getMixer(mixerInfos(mixerIdx)));
        for portIdx = 1 : length(ports)
            port = ports(portIdx);
            try
                portName = port.getName;  % better
            catch   
                portName = port.toString; % sub-optimal
            end
            if ~isempty(strfind(lower(char(portName)),'speaker'))
                foundFlag = 1;
                break;
            end
        end
    end
    if ~foundFlag
        error('YMA:SoundVolume:noSpeakerPort','Speaker port not found');
    end
    line = AudioSystem.getLine(port);
    line.open();
    ctrls = line.getControls;
    foundFlag = 0;
    for ctrlIdx = 1 : length(ctrls)
        ctrl = ctrls(ctrlIdx);
        ctrlType = ctrls(ctrlIdx).getType;
        try
            ctrlType = char(ctrlType);
        catch  
            ctrlType = char(ctrlType.toString);
        end
        if ~isempty(strfind(lower(ctrlType),'volume'))
            foundFlag = 1;
            break;
        end
    end
    if ~foundFlag
        error('YMA:SoundVolume:noVolumeControl','Speaker volume control not found');
    end
    oldValue = ctrl.getValue;
    if nargin
        ctrl.setValue(volume);
    end
    if nargout
        volume = oldValue;
    end