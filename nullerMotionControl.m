function varargout = nullerMotionControl(varargin)
% NULLERMOTIONCONTROL MATLAB code for nullerMotionControl.fig
%      NULLERMOTIONCONTROL, by itself, creates a new NULLERMOTIONCONTROL or raises the existing
%      singleton*.
%
%      H = NULLERMOTIONCONTROL returns the handle to a new NULLERMOTIONCONTROL or the handle to
%      the existing singleton*.
%
%      NULLERMOTIONCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NULLERMOTIONCONTROL.M with the given input arguments.
%
%      NULLERMOTIONCONTROL('Property','Value',...) creates a new NULLERMOTIONCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nullerMotionControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nullerMotionControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nullerMotionControl

% Last Modified by GUIDE v2.5 17-Mar-2016 10:08:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nullerMotionControl_OpeningFcn, ...
                   'gui_OutputFcn',  @nullerMotionControl_OutputFcn, ...
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



% --- Executes just before nullerMotionControl is made visible.
function nullerMotionControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nullerMotionControl (see VARARGIN)

% Choose default command line output for nullerMotionControl
handles.output = hObject;

enableZabers = true;
enableFlipmount = false;
enableImr = true;
enablePicos = true;

%stepsPerMm = 0.047625;
%nudgeAmt= 1000;%1. /stepsPerMm;

imrAngleOffset = 0; % Encoder angle for no rotation

guiUpdateRate = 4;
defaultPicoDriver = 'a1';
defaultPicoChannel = '1';
nudgeAmt = str2double(get(handles.zabNudgeAmtBox,'String'));
setappdata(handles.nullerMotionControl,'enableZabers',enableZabers);
setappdata(handles.nullerMotionControl,'enableFlipmount',enableFlipmount);
setappdata(handles.nullerMotionControl,'enableImr',enableImr);
setappdata(handles.nullerMotionControl,'enablePicos',enablePicos)
setappdata(handles.nullerMotionControl,'nudgeAmt',nudgeAmt);
setappdata(handles.nullerMotionControl,'imrAngleOffset',imrAngleOffset);
setappdata(handles.nullerMotionControl,'picoDriver',defaultPicoDriver);
setappdata(handles.nullerMotionControl,'picoChannel',defaultPicoChannel);

if enableImr
    imrObj = serial('COM11', ...
    'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    fopen(imrObj); %Open the device
    imrObj.Terminator=''; %Set terminator to ''
else
    imrObj=0;
end

% Connect to Flip mount
if enableFlipmount
    flipObj = serial('COM12', ...
    'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    fopen(flipObj); %Open the device
    flipObj.Terminator=''; %Set terminator to ''
else
    flipObj=0;
end
    
% Connect to Picomotors
if enablePicos
    picoObj = serial('COM9', ...
    'BaudRate',19200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');
    fopen(picoObj); %Open the device
    picoObj.Terminator='CR'; %Set terminator to CR
    
    % Check it's working
    fprintf(picoObj, 'ver');
    fscanf(picoObj)
    
    % Enable motors
    fprintf(picoObj, 'mon');
    
    % Set default channel
    setChlString = ['chl ' defaultPicoDriver '=' defaultPicoChannel];
    fprintf(picoObj, setChlString);
else
    picoObj=0;
end


% Connect to Zaber
if enableZabers
    zabersObj = serial('COM10', ...
        'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,...
        'FlowControl','none','Timeout',60);
    fopen(zabersObj);
    zabersObj.Terminator='';

    % Get Zaber's current positions
    packet = [1 60 0 0 0 0];
    fwrite(zabersObj,packet,'uint8')
    pos = fread(zabersObj,6);
    posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
    chipLRPosn = posNum;
    setappdata(handles.nullerMotionControl,'chipLRPosn',chipLRPosn)
    set(handles.chipLRTextBox,'String',num2str(chipLRPosn))

    packet = [2 60 0 0 0 0];
    fwrite(zabersObj,packet,'uint8')
    pos = fread(zabersObj,6);
    posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
    chipUDPosn = posNum;
    setappdata(handles.nullerMotionControl,'chipUDPosn',chipUDPosn)
    set(handles.chipUDTextBox,'String',num2str(chipUDPosn))

    packet = [3 60 0 0 0 0];
    fwrite(zabersObj,packet,'uint8')
    pos = fread(zabersObj,6);
    posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
    chipFocPosn = posNum;
    setappdata(handles.nullerMotionControl,'chipFocPosn',chipFocPosn)
    set(handles.chipFocTextBox,'String',num2str(chipFocPosn))

    packet = [4 60 0 0 0 0];
    fwrite(zabersObj,packet,'uint8')
    pos = fread(zabersObj,6);
    posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
    maskLRPosn = posNum;
    setappdata(handles.nullerMotionControl,'maskLRPosn',maskLRPosn)
    set(handles.maskLRTextBox,'String',num2str(maskLRPosn))

    packet = [5 60 0 0 0 0];
    fwrite(zabersObj,packet,'uint8')
    pos = fread(zabersObj,6);
    posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
    maskUDPosn = posNum;
    setappdata(handles.nullerMotionControl,'maskUDPosn',maskUDPosn)
    set(handles.maskUDTextBox,'String',num2str(maskUDPosn))

else
    zabersObj = 0;
end

setappdata(handles.nullerMotionControl,'zabersObj',zabersObj)
setappdata(handles.nullerMotionControl,'flipObj',flipObj)
setappdata(handles.nullerMotionControl,'imrObj',imrObj)
setappdata(handles.nullerMotionControl,'picoObj',picoObj)

handles.valTimer = timer(...
    'ExecutionMode', 'fixedRate', ...
    'Period', 1/guiUpdateRate, ...
    'TimerFcn', {@updateGuiFn,hObject} );
start(handles.valTimer)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nullerMotionControl wait for user response (see UIRESUME)
% uiwait(handles.nullerMotionControl);


% --- Outputs from this function are returned to the command line.
function varargout = nullerMotionControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnChipUp.
function btnChipUp_Callback(hObject, eventdata, handles)
% hObject    handle to btnChipUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = nudgeAmt;
device=2;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
%greyOutBoxes(handles,0)
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
%greyOutBoxes(handles,1)
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'chipUDPosn',posNum)
set(handles.chipUDTextBox,'String',num2str(posNum))


% --- Executes on button press in btnChipDown.
function btnChipDown_Callback(hObject, eventdata, handles)
% hObject    handle to btnChipDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=2;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'chipUDPosn',posNum)
set(handles.chipUDTextBox,'String',num2str(posNum))


function chipUDTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to chipUDTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chipUDTextBox as text
%        str2double(get(hObject,'String')) returns contents of chipUDTextBox as a double
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
newPosn = str2num(get(handles.chipUDTextBox,'string'));
cmd = 20; %Move absolute
device=2;
[d3 d4 d5 d6] = entryToBits(newPosn);
packet = [device cmd d3 d4 d5 d6];
greyOutBoxes(handles,0)
pause(0.5)
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
greyOutBoxes(handles,1)
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'chipUDPosn',posNum)
set(handles.chipUDTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function chipUDTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chipUDTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnChipLeft.
function btnChipLeft_Callback(hObject, eventdata, handles)
% hObject    handle to btnChipLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=1;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'chipLRPosn',posNum)
set(handles.chipLRTextBox,'String',num2str(posNum))

% --- Executes on button press in btnChipRight.
function btnChipRight_Callback(hObject, eventdata, handles)
% hObject    handle to btnChipRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = nudgeAmt;
device=1;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'chipLRPosn',posNum)
set(handles.chipLRTextBox,'String',num2str(posNum))


function chipLRTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to chipLRTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chipLRTextBox as text
%        str2double(get(hObject,'String')) returns contents of chipLRTextBox as a double
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
newPosn = str2num(get(handles.chipLRTextBox,'string'));
cmd = 20; %Move absolute
device=1;
[d3 d4 d5 d6] = entryToBits(newPosn);
packet = [device cmd d3 d4 d5 d6];
greyOutBoxes(handles,0)
pause(0.5)
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
greyOutBoxes(handles,1)
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'chipLRPosn',posNum)
set(handles.chipLRTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function chipLRTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chipLRTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnChipPlus.
function btnChipPlus_Callback(hObject, eventdata, handles)
% hObject    handle to btnChipPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = nudgeAmt;
device=3;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'chipFocPosn',posNum)
set(handles.chipFocTextBox,'String',num2str(posNum))

% --- Executes on button press in btnChipMinus.
function btnChipMinus_Callback(hObject, eventdata, handles)
% hObject    handle to btnChipMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=3;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'chipFocPosn',posNum)
set(handles.chipFocTextBox,'String',num2str(posNum))


function chipFocTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to chipFocTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chipFocTextBox as text
%        str2double(get(hObject,'String')) returns contents of chipFocTextBox as a double
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
newPosn = str2num(get(handles.chipFocTextBox,'string'));
cmd = 20; %Move absolute
device=3;
[d3 d4 d5 d6] = entryToBits(newPosn);
packet = [device cmd d3 d4 d5 d6];
greyOutBoxes(handles,0)
pause(0.5)
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
greyOutBoxes(handles,1)
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'chipFocPosn',posNum)
set(handles.chipFocTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function chipFocTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chipFocTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnImSave.
function btnImSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnImSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnMaskUp.
function btnMaskUp_Callback(hObject, eventdata, handles)
% hObject    handle to btnMaskUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = nudgeAmt;
device=5;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'maskUDPosn',posNum)
set(handles.maskUDTextBox,'String',num2str(posNum))

% --- Executes on button press in btnMaskDown.
function btnMaskDown_Callback(hObject, eventdata, handles)
% hObject    handle to btnMaskDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=5;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'maskUDPosn',posNum)
set(handles.maskUDTextBox,'String',num2str(posNum))


function maskUDTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to maskUDTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maskUDTextBox as text
%        str2double(get(hObject,'String')) returns contents of maskUDTextBox as a double
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
newPosn = str2num(get(handles.maskUDTextBox,'string'));
cmd = 20; %Move absolute
device=5;
[d3 d4 d5 d6] = entryToBits(newPosn);
packet = [device cmd d3 d4 d5 d6];
greyOutBoxes(handles,0)
pause(0.5)
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
greyOutBoxes(handles,1)
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'maskUDPosn',posNum)
set(handles.maskUDTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function maskUDTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maskUDTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnMaskLeft.
function btnMaskLeft_Callback(hObject, eventdata, handles)
% hObject    handle to btnMaskLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=4;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'maskLRPosn',posNum)
set(handles.maskLRTextBox,'String',num2str(posNum))


% --- Executes on button press in btnMaskRight.
function btnMaskRight_Callback(hObject, eventdata, handles)
% hObject    handle to btnMaskRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
nudgeAmt=getappdata(handles.nullerMotionControl,'nudgeAmt');
cmd = 21; %Move relative
nsteps = nudgeAmt;
device=4;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'maskLRPosn',posNum)
set(handles.maskLRTextBox,'String',num2str(posNum))


function maskLRTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to maskLRTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maskLRTextBox as text
%        str2double(get(hObject,'String')) returns contents of maskLRTextBox as a double
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
newPosn = str2num(get(handles.maskLRTextBox,'string'));
cmd = 20; %Move absolute
device=4;
[d3 d4 d5 d6] = entryToBits(newPosn);
packet = [device cmd d3 d4 d5 d6];
greyOutBoxes(handles,0)
pause(0.5)
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
greyOutBoxes(handles,1)
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.nullerMotionControl,'maskLRPosn',posNum)
set(handles.maskLRTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function maskLRTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maskLRTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnPupSave.
function btnPupSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnPupSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in homeAllBtn.
function homeAllBtn_Callback(hObject, eventdata, handles)
% hObject    handle to homeAllBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
cmd = 1; 
device=0;
[d3 d4 d5 d6] = entryToBits(0);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,30); %30 because 5 actuators, 6 bytes each
% posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
% setappdata(handles.nullerMotionControl,'maskLRPosn',posNum)
% set(handles.maskLRTextBox,'String',num2str(posNum))


function refreshTextBoxes(handles)
% Get Zaber's current positions
zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
packet = [1 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
chipLRPosn = posNum;
setappdata(handles.nullerMotionControl,'chipLRPosn',chipLRPosn)
set(handles.chipLRTextBox,'String',num2str(chipLRPosn))
pause(0.2)

packet = [2 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
chipUDPosn = posNum;
setappdata(handles.nullerMotionControl,'chipUDPosn',chipUDPosn)
set(handles.chipUDTextBox,'String',num2str(chipUDPosn))
pause(0.2)

packet = [3 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
chipFocPosn = posNum;
setappdata(handles.nullerMotionControl,'chipFocPosn',chipFocPosn)
set(handles.chipFocTextBox,'String',num2str(chipFocPosn))
pause(0.2)

packet = [4 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
maskLRPosn = posNum;
setappdata(handles.nullerMotionControl,'maskLRPosn',maskLRPosn)
set(handles.maskLRTextBox,'String',num2str(maskLRPosn))
pause(0.2)

packet = [5 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
maskUDPosn = posNum;
setappdata(handles.nullerMotionControl,'maskUDPosn',maskUDPosn)
set(handles.maskUDTextBox,'String',num2str(maskUDPosn))
pause(0.2)


% --- Executes on button press in refreshBtn.
function refreshBtn_Callback(hObject, eventdata, handles)
% hObject    handle to refreshBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refreshTextBoxes(handles)


function greyOutBoxes(handles,action)
if action == 0
    set(handles.chipUDTextBox,'Enable','off');
    set(handles.chipLRTextBox,'Enable','off');
    set(handles.chipFocTextBox,'Enable','off');
    set(handles.maskUDTextBox,'Enable','off');
    set(handles.maskLRTextBox,'Enable','off');
end

if action == 1
    set(handles.chipUDTextBox,'Enable','on');
    set(handles.chipLRTextBox,'Enable','on');
    set(handles.chipFocTextBox,'Enable','on');
    set(handles.maskUDTextBox,'Enable','on');
    set(handles.maskLRTextBox,'Enable','on');
end
    
    
%%%% Used Functions %%%%
function [d3 d4 d5 d6] = entryToBits(data)
% Convert negative numbers...
if data<0
    data = 256^4 + data;
end

% d6 is the last bit (data must be larger than 256^3 to have a value here)
d6 = floor(data / 256^3);
data   = (data) - 256^3 * d6;

% d5 is the next largest bit... d5 = (0:256)*256^2
d5 = floor(data / 256^2);
if d5>256
    d5 = 256;
end

% d4 is the second smallest bit... d4 = (0:256)*256
data   = data - 256^2 * d5;
d4 = floor(data / 256);
if d4>256
    d4 = 256;
end

% d3 is the smallest bit, values are 0:256
d3 = floor(mod(data,256));
if d3>256
    d3 = 256;
end


function [data] = bitsToNumber(d3,d4,d5,d6)
    data = (d6*256^3)+(d5*256^2)+(d4*256)+d3;
%%%%
    

% --- Executes on button press in exitBtn.
function exitBtn_Callback(hObject, eventdata, handles)
% hObject    handle to exitBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Exiting...')

stop(handles.valTimer)

enableZabers=getappdata(handles.nullerMotionControl,'enableZabers');
if enableZabers
    zabersObj=getappdata(handles.nullerMotionControl,'zabersObj');
    fclose(zabersObj);
    delete(zabersObj);
end

enableFlipmount=getappdata(handles.nullerMotionControl,'enableFlipmount');
if enableFlipmount
    flipObj=getappdata(handles.nullerMotionControl,'flipObj');
    fclose(flipObj);
    delete(flipObj);
end

enableImr=getappdata(handles.nullerMotionControl,'enableImr');
if enableImr
    imrObj=getappdata(handles.nullerMotionControl,'imrObj');
    fclose(imrObj);
    delete(imrObj);
end

enablePicos=getappdata(handles.nullerMotionControl,'enablePicos');
if enablePicos
    picoObj=getappdata(handles.nullerMotionControl,'picoObj');
    % Disable motors
    fprintf(picoObj, 'mof');
    fclose(picoObj);
    delete(picoObj);
end


delete(handles.nullerMotionControl);
delete(handles.valTimer)

%exit %%%Exits matlab!


% --- Executes on button press in flipOutBtn.
function flipOutBtn_Callback(hObject, eventdata, handles)
% hObject    handle to flipOutBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flipObj=getappdata(handles.nullerMotionControl,'flipObj');
disp('Moving to position Out')
posn = '01';
nbytes=6;
hexString={'6A' '04' '00' posn '50' '01'};
for ii = 1:nbytes
    hex=hexString{ii};
    dec=hex2dec(hex);
    fwrite(flipObj,dec,'uint8')
end

pause(3)

%Get status bits
%Send request:
nbytes=6;
hexString={'29' '04' '00' '00' '50' '01'};
for ii = 1:nbytes
    hex=hexString{ii};
    dec=hex2dec(hex);
    fwrite(flipObj,dec,'uint8')
end

%Retrieve the get
nbytes=12;
response=fread(flipObj,nbytes);
statusBits=response(9:12)

% --- Executes on button press in flipInBtn.
function flipInBtn_Callback(hObject, eventdata, handles)
% hObject    handle to flipInBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flipObj=getappdata(handles.nullerMotionControl,'flipObj');
disp('Moving to position In')
posn = '02';
nbytes=6;
hexString={'6A' '04' '00' posn '50' '01'};
for ii = 1:nbytes
    hex=hexString{ii};
    dec=hex2dec(hex);
    fwrite(flipObj,dec,'uint8')
end

pause(3)

%Get status bits
%Send request:
nbytes=6;
hexString={'29' '04' '00' '00' '50' '01'};
for ii = 1:nbytes
    hex=hexString{ii};
    dec=hex2dec(hex);
    fwrite(flipObj,dec,'uint8')
end

%Retrieve the get
nbytes=12;
response=fread(flipObj,nbytes);
statusBits=response(9:12)


% --- Executes on button press in imrHomeBtn.
function imrHomeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to imrHomeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imrObj=getappdata(handles.nullerMotionControl,'imrObj');
disp('Homing')
nbytes=6;
hexString={'43' '04' '01' '00' '50' '01'}; %Do homing
for ii = 1:nbytes
    hex=hexString{ii};
    dec=hex2dec(hex);
    fwrite(imrObj,dec,'uint8')
end


function imrAngleBox_Callback(hObject, eventdata, handles)
% hObject    handle to imrAngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imrAngleBox as text
%        str2double(get(hObject,'String')) returns contents of imrAngleBox as a double
imrObj=getappdata(handles.nullerMotionControl,'imrObj');
EncCnt = 682.5;
angle = str2double(get(hObject,'String'));
absSteps = EncCnt*angle;
[d1 d2 d3 d4]=entryToBits(absSteps);
bytes=[d1 d2 d3 d4];
for ii = 1:4
    absPos{ii}=num2str(dec2hex(bytes(ii)));
end
nbytes=12;
header={'53' '04' '06' '00' '80' '01'};
chan={'01' '00'};
hexString=[header, chan, absPos];
for ii = 1:nbytes
    hex=hexString{ii};
    dec=hex2dec(hex);
    fwrite(imrObj,dec,'uint8')
end


% --- Executes during object creation, after setting all properties.
function imrAngleBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imrAngleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function updateGuiFn(hObject,eventdata,hfigure)
handles = guidata(hfigure);
imrObj=getappdata(handles.nullerMotionControl,'imrObj');
imrAngleOffset=getappdata(handles.nullerMotionControl,'imrAngleOffset');

% Get Imr position
enableImr=getappdata(handles.nullerMotionControl,'enableImr');
if enableImr
    EncCnt = 682.5;
    %Send request:
    nbytes=6;
    hexString={'90' '04' '00' '00' '50' '01'};
    for ii = 1:nbytes
        hex=hexString{ii};
        dec=hex2dec(hex);
        fwrite(imrObj,dec,'uint8')
    end

    %Retrieve the get
    nbytes=20;
    response=fread(imrObj,nbytes);
    p=response(9:12);
    rawAngle=bitsToNumber(p(1),p(2),p(3),p(4))/EncCnt;
    angle=rawAngle-imrAngleOffset;
    
    set(handles.imrAngleText,'String',num2str(angle))
end



function zabNudgeAmtBox_Callback(hObject, eventdata, handles)
% hObject    handle to zabNudgeAmtBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zabNudgeAmtBox as text
%        str2double(get(hObject,'String')) returns contents of zabNudgeAmtBox as a double
nudgeAmt = str2double(get(handles.zabNudgeAmtBox,'String'));
setappdata(handles.nullerMotionControl,'nudgeAmt',nudgeAmt);


% --- Executes during object creation, after setting all properties.
function zabNudgeAmtBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zabNudgeAmtBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in PicoActuatorBtns.
function PicoActuatorBtns_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in PicoActuatorBtns 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
picoObj = getappdata(handles.nullerMotionControl,'picoObj');

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'pico1btn'
        picoDriver = 'a2';
        picoChannel = '0';
    case 'pico2btn'
        picoDriver = 'a2';
        picoChannel = '1';
    case 'pico3btn'
        picoDriver = 'a2';
        picoChannel = '2';
    case 'pico4btn'
        picoDriver = 'a1';
        picoChannel = '1';
    case 'pico5btn'
        picoDriver = 'a1';
        picoChannel = '2';
end
setappdata(handles.nullerMotionControl,'picoDriver',picoDriver);
setappdata(handles.nullerMotionControl,'picoChannel',picoChannel);
setChlString = ['chl ' picoDriver '=' picoChannel];
fprintf(picoObj, setChlString);



% --- Executes on button press in picorNudgeMinusBtn.
function picorNudgeMinusBtn_Callback(hObject, eventdata, handles)
% hObject    handle to picorNudgeMinusBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
picoDriver=getappdata(handles.nullerMotionControl,'picoDriver');
picoObj = getappdata(handles.nullerMotionControl,'picoObj');
% picoNudgeAmt = -1*str2double(get(handles.picoNudgeAmtBox,'String'));
% nudgeStr = ['rel ' picoDriver '=' num2str(picoNudgeAmt)];
% fprintf(picoObj, nudgeStr);
nudgeTime=0.5;
fprintf(picoObj, ['rev ' picoDriver]);
pause(0.1)
fprintf(picoObj, ['go ' picoDriver]);
pause(nudgeTime)
fprintf(picoObj, ['sto ' picoDriver]);


% --- Executes on button press in picorNudgePlusBtn.
function picorNudgePlusBtn_Callback(hObject, eventdata, handles)
% hObject    handle to picorNudgePlusBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
picoDriver=getappdata(handles.nullerMotionControl,'picoDriver');
picoObj = getappdata(handles.nullerMotionControl,'picoObj');
% picoNudgeAmt = str2double(get(handles.picoNudgeAmtBox,'String'));
% nudgeStr = ['rel ' picoDriver '=' num2str(picoNudgeAmt)];
% fprintf(picoObj, nudgeStr);
nudgeTime=0.5;
fprintf(picoObj, ['for ' picoDriver]);
pause(0.1)
fprintf(picoObj, ['go ' picoDriver]);
pause(nudgeTime)
fprintf(picoObj, ['sto ' picoDriver]);

function picoNudgeAmtBox_Callback(hObject, eventdata, handles)
% hObject    handle to picoNudgeAmtBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of picoNudgeAmtBox as text
%        str2double(get(hObject,'String')) returns contents of picoNudgeAmtBox as a double


% --- Executes during object creation, after setting all properties.
function picoNudgeAmtBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to picoNudgeAmtBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function picoVelocBox_Callback(hObject, eventdata, handles)
% hObject    handle to picoVelocBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of picoVelocBox as text
%        str2double(get(hObject,'String')) returns contents of picoVelocBox as a double
picoObj = getappdata(handles.nullerMotionControl,'picoObj');
vStr = get(handles.picoVelocBox,'String');
wtime=0.1;
fprintf(picoObj, ['vel a1 0=' vStr]);
pause(wtime)
fprintf(picoObj, ['vel a1 1=' vStr]);
pause(wtime)
fprintf(picoObj, ['vel a1 2=' vStr]);
pause(wtime)
fprintf(picoObj, ['vel a2 0=' vStr]);
pause(wtime)
fprintf(picoObj, ['vel a2 1=' vStr]);
pause(wtime)
fprintf(picoObj, ['vel a2 2=' vStr]);
pause(wtime)
fprintf(picoObj, 'vel');
for k = 1:6
    fscanf(picoObj)
end

% --- Executes during object creation, after setting all properties.
function picoVelocBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to picoVelocBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
