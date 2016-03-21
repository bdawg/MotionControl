function varargout = vControl_steerImPup(varargin)
% VCONTROL_STEERIMPUP MATLAB code for vControl_steerImPup.fig
%      VCONTROL_STEERIMPUP, by itself, creates a new VCONTROL_STEERIMPUP or raises the existing
%      singleton*.
%
%      H = VCONTROL_STEERIMPUP returns the handle to a new VCONTROL_STEERIMPUP or the handle to
%      the existing singleton*.
%
%      VCONTROL_STEERIMPUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VCONTROL_STEERIMPUP.M with the given input arguments.
%
%      VCONTROL_STEERIMPUP('Property','Value',...) creates a new VCONTROL_STEERIMPUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vControl_steerImPup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vControl_steerImPup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vControl_steerImPup

% Last Modified by GUIDE v2.5 14-Apr-2014 18:24:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vControl_steerImPup_OpeningFcn, ...
                   'gui_OutputFcn',  @vControl_steerImPup_OutputFcn, ...
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



% --- Executes just before vControl_steerImPup is made visible.
function vControl_steerImPup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vControl_steerImPup (see VARARGIN)

% Choose default command line output for vControl_steerImPup
handles.output = hObject;

% Get data from parent function
handlesParent=varargin{1};
handles.vCamGui=varargin{2};

stepsPerMm = 0.047625;
nudgeAmt= 1000;%1. /stepsPerMm;
setappdata(handles.vCamGui,'nudgeAmt',nudgeAmt);

% Get Zaber's current positions
zabersObj=getappdata(handles.vCamGui,'zabersObj');
packet = [1 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
imLRPosn = posNum;
setappdata(handles.steerGUI,'imLRPosn',imLRPosn)
set(handles.imLRTextBox,'String',num2str(imLRPosn))

packet = [2 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
imUDPosn = posNum;
setappdata(handles.steerGUI,'imUDPosn',imUDPosn)
set(handles.imUDTextBox,'String',num2str(imUDPosn))

packet = [3 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
imFocPosn = posNum;
setappdata(handles.steerGUI,'imFocPosn',imFocPosn)
set(handles.imFocTextBox,'String',num2str(imFocPosn))

packet = [4 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
pupLRPosn = posNum;
setappdata(handles.steerGUI,'pupLRPosn',pupLRPosn)
set(handles.pupLRTextBox,'String',num2str(pupLRPosn))

packet = [5 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
pupUDPosn = posNum;
setappdata(handles.steerGUI,'pupUDPosn',pupUDPosn)
set(handles.pupUDTextBox,'String',num2str(pupUDPosn))

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vControl_steerImPup wait for user response (see UIRESUME)
% uiwait(handles.steerGUI);


% --- Outputs from this function are returned to the command line.
function varargout = vControl_steerImPup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnImUp.
function btnImUp_Callback(hObject, eventdata, handles)
% hObject    handle to btnImUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
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
setappdata(handles.steerGUI,'imUDPosn',posNum)
set(handles.imUDTextBox,'String',num2str(posNum))


% --- Executes on button press in btnImDown.
function btnImDown_Callback(hObject, eventdata, handles)
% hObject    handle to btnImDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=2;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.steerGUI,'imUDPosn',posNum)
set(handles.imUDTextBox,'String',num2str(posNum))


function imUDTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to imUDTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imUDTextBox as text
%        str2double(get(hObject,'String')) returns contents of imUDTextBox as a double
zabersObj=getappdata(handles.vCamGui,'zabersObj');
newPosn = str2num(get(handles.imUDTextBox,'string'));
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
setappdata(handles.steerGUI,'imUDPosn',posNum)
set(handles.imUDTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function imUDTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imUDTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnImLeft.
function btnImLeft_Callback(hObject, eventdata, handles)
% hObject    handle to btnImLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=1;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.steerGUI,'imLRPosn',posNum)
set(handles.imLRTextBox,'String',num2str(posNum))

% --- Executes on button press in btnImRight.
function btnImRight_Callback(hObject, eventdata, handles)
% hObject    handle to btnImRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
cmd = 21; %Move relative
nsteps = nudgeAmt;
device=1;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.steerGUI,'imLRPosn',posNum)
set(handles.imLRTextBox,'String',num2str(posNum))


function imLRTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to imLRTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imLRTextBox as text
%        str2double(get(hObject,'String')) returns contents of imLRTextBox as a double
zabersObj=getappdata(handles.vCamGui,'zabersObj');
newPosn = str2num(get(handles.imLRTextBox,'string'));
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
setappdata(handles.steerGUI,'imLRPosn',posNum)
set(handles.imLRTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function imLRTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imLRTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnFocPlus.
function btnFocPlus_Callback(hObject, eventdata, handles)
% hObject    handle to btnFocPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
cmd = 21; %Move relative
nsteps = nudgeAmt;
device=3;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.steerGUI,'imFocPosn',posNum)
set(handles.imFocTextBox,'String',num2str(posNum))

% --- Executes on button press in btnFocMinus.
function btnFocMinus_Callback(hObject, eventdata, handles)
% hObject    handle to btnFocMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=3;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.steerGUI,'imFocPosn',posNum)
set(handles.imFocTextBox,'String',num2str(posNum))


function imFocTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to imFocTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imFocTextBox as text
%        str2double(get(hObject,'String')) returns contents of imFocTextBox as a double
zabersObj=getappdata(handles.vCamGui,'zabersObj');
newPosn = str2num(get(handles.imFocTextBox,'string'));
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
setappdata(handles.steerGUI,'imFocPosn',posNum)
set(handles.imFocTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function imFocTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imFocTextBox (see GCBO)
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


% --- Executes on button press in btnPupUp.
function btnPupUp_Callback(hObject, eventdata, handles)
% hObject    handle to btnPupUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
cmd = 21; %Move relative
nsteps = nudgeAmt;
device=5;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.steerGUI,'pupUDPosn',posNum)
set(handles.pupUDTextBox,'String',num2str(posNum))

% --- Executes on button press in btnPupDown.
function btnPupDown_Callback(hObject, eventdata, handles)
% hObject    handle to btnPupDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=5;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.steerGUI,'pupUDPosn',posNum)
set(handles.pupUDTextBox,'String',num2str(posNum))


function pupUDTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to pupUDTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pupUDTextBox as text
%        str2double(get(hObject,'String')) returns contents of pupUDTextBox as a double
zabersObj=getappdata(handles.vCamGui,'zabersObj');
newPosn = str2num(get(handles.pupUDTextBox,'string'));
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
setappdata(handles.steerGUI,'pupUDPosn',posNum)
set(handles.pupUDTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function pupUDTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pupUDTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnPupLeft.
function btnPupLeft_Callback(hObject, eventdata, handles)
% hObject    handle to btnPupLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
cmd = 21; %Move relative
nsteps = nudgeAmt;
device=4;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.steerGUI,'pupLRPosn',posNum)
set(handles.pupLRTextBox,'String',num2str(posNum))


% --- Executes on button press in btnPupRight.
function btnPupRight_Callback(hObject, eventdata, handles)
% hObject    handle to btnPupRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zabersObj=getappdata(handles.vCamGui,'zabersObj');
nudgeAmt=getappdata(handles.vCamGui,'nudgeAmt');
cmd = 21; %Move relative
nsteps = -1*nudgeAmt;
device=4;
[d3 d4 d5 d6] = entryToBits(nsteps);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
setappdata(handles.steerGUI,'pupLRPosn',posNum)
set(handles.pupLRTextBox,'String',num2str(posNum))


function pupLRTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to pupLRTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pupLRTextBox as text
%        str2double(get(hObject,'String')) returns contents of pupLRTextBox as a double
zabersObj=getappdata(handles.vCamGui,'zabersObj');
newPosn = str2num(get(handles.pupLRTextBox,'string'));
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
setappdata(handles.steerGUI,'pupLRPosn',posNum)
set(handles.pupLRTextBox,'String',num2str(posNum))

% --- Executes during object creation, after setting all properties.
function pupLRTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pupLRTextBox (see GCBO)
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
zabersObj=getappdata(handles.vCamGui,'zabersObj');
cmd = 1; 
device=0;
[d3 d4 d5 d6] = entryToBits(0);
packet = [device cmd d3 d4 d5 d6];
fwrite(zabersObj,packet,'uint8')
%pause(1)
pos = fread(zabersObj,30); %30 because 5 actuators, 6 bytes each
% posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
% setappdata(handles.steerGUI,'pupLRPosn',posNum)
% set(handles.pupLRTextBox,'String',num2str(posNum))


function refreshTextBoxes(handles)
% Get Zaber's current positions
zabersObj=getappdata(handles.vCamGui,'zabersObj');
packet = [1 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
imLRPosn = posNum;
setappdata(handles.steerGUI,'imLRPosn',imLRPosn)
set(handles.imLRTextBox,'String',num2str(imLRPosn))
pause(0.2)

packet = [2 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
imUDPosn = posNum;
setappdata(handles.steerGUI,'imUDPosn',imUDPosn)
set(handles.imUDTextBox,'String',num2str(imUDPosn))
pause(0.2)

packet = [3 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
imFocPosn = posNum;
setappdata(handles.steerGUI,'imFocPosn',imFocPosn)
set(handles.imFocTextBox,'String',num2str(imFocPosn))
pause(0.2)

packet = [4 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
pupLRPosn = posNum;
setappdata(handles.steerGUI,'pupLRPosn',pupLRPosn)
set(handles.pupLRTextBox,'String',num2str(pupLRPosn))
pause(0.2)

packet = [5 60 0 0 0 0];
fwrite(zabersObj,packet,'uint8')
pos = fread(zabersObj,6);
posNum=bitsToNumber(pos(3),pos(4),pos(5),pos(6));
pupUDPosn = posNum;
setappdata(handles.steerGUI,'pupUDPosn',pupUDPosn)
set(handles.pupUDTextBox,'String',num2str(pupUDPosn))
pause(0.2)


% --- Executes on button press in refreshBtn.
function refreshBtn_Callback(hObject, eventdata, handles)
% hObject    handle to refreshBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refreshTextBoxes(handles)

function greyOutBoxes(handles,action)
if action == 0
    set(handles.imUDTextBox,'Enable','off');
    set(handles.imLRTextBox,'Enable','off');
    set(handles.imFocTextBox,'Enable','off');
    set(handles.pupUDTextBox,'Enable','off');
    set(handles.pupLRTextBox,'Enable','off');
end

if action == 1
    set(handles.imUDTextBox,'Enable','on');
    set(handles.imLRTextBox,'Enable','on');
    set(handles.imFocTextBox,'Enable','on');
    set(handles.pupUDTextBox,'Enable','on');
    set(handles.pupLRTextBox,'Enable','on');
end
    
    
    
    
    



function globalPupOffsetUD_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to globalPupOffsetUD_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of globalPupOffsetUD_textbox as text
%        str2double(get(hObject,'String')) returns contents of globalPupOffsetUD_textbox as a double
UDoffset=str2num(get(handles.globalPupOffsetUD_textbox,'string'))
setappdata(handles.vCamGui,'globalPupOffsetUD',UDoffset);


% --- Executes during object creation, after setting all properties.
function globalPupOffsetUD_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to globalPupOffsetUD_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function globalPupOffsetLR_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to globalPupOffsetLR_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of globalPupOffsetLR_textbox as text
%        str2double(get(hObject,'String')) returns contents of globalPupOffsetLR_textbox as a double
LRoffset=str2num(get(handles.globalPupOffsetLR_textbox,'string'))
setappdata(handles.vCamGui,'globalPupOffsetLR',LRoffset);

% --- Executes during object creation, after setting all properties.
function globalPupOffsetLR_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to globalPupOffsetLR_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
