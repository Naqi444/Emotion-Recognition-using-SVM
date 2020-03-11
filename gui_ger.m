function varargout = gui_ger(varargin)
% GUI_GER M-file for gui_ger.fig
%      GUI_GER, by itself, creates a new GUI_GER or raises the existing
%      singleton*.
%
%      H = GUI_GER returns the handle to a new GUI_GER or the handle to
%      the existing singleton*.
%
%      GUI_GER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_GER.M with the given input arguments.
%
%      GUI_GER('Property','Value',...) creates a new GUI_GER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_ger_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_ger_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_ger

% Last Modified by GUIDE v2.5 05-Apr-2015 19:15:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_ger_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_ger_OutputFcn, ...
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


% --- Executes just before gui_ger is made visible.
function gui_ger_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_ger (see VARARGIN)

% Choose default command line output for gui_ger
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_ger wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_ger_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off;
cd german
delete 'Thumbs.db';
cd ..
Fd=dir('german');
Fd=char(Fd.name);
sz=size(Fd,1)-2;
h=waitbar(0,'Please wait the system is training');
for ii=1:sz
    cd german
    st=Fd(ii+2,:);
    grp{ii}=st(6:7);
    if st(6:7)=='an'
        gg(ii)=1e-3;
    end
    if st(6:7)=='di'
        gg(ii)=1e-2;
    end
        if st(6:7)=='fe'
        gg(ii)=1e-1;
        end
        if st(6:7)=='ha'
        gg(ii)=1;
        end
        if st(6:7)=='sa'
        gg(ii)=1e1;
        end
        if st(6:7)=='bo'
        gg(ii)=1e2;
    end
    [I Fs]=wavread(st,[1e4 2e4]);
    I=I(:,1);
    cd ..
[E]=endpointdetect(I,Fs);
W=fix(.04*Fs);                 %Window length is 40 ms
SP=.4;                         %Shift percentage is (10ms) %Overlap-Add method works good with this value(.4)
Seg=segment1(E,W,SP);
%-------------------------------------------------
for nn=1:size(Seg,2)
[F0,T,C]=PitchTrackCepstrum(Seg(:,nn),Fs);
LE=sum(Seg(:,nn).^2);
[F T]=spFormantsTrackLpc(Seg(:,nn),Fs);
F1=F(1);F2=F(2);F3=F(3);
[MFC ME] = mfcc(Seg(:,nn),Fs);
fv(:,nn)=[F0 LE F1 F2 F3 MFC' ME']';
end
FV(:,ii)=fv(:);
waitbar(ii/sz);
end
size(FV);
close(h)
[mdel nuu]=mysvmtrain(FV,gg);

handles.mdel=mdel;
handles.nuu=nuu;
guidata(hObject, handles);



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd german_test
 [J P]=uigetfile('.wav','Select The speech signal'); 
 [J Fs]=wavread(strcat(P,J),[1e4 2e4]);
cd ..
J=J(:,1);
handles.J=J;
handles.Fs=Fs;
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sp={'anger','Disgust','Fear','Happiness','sad','boredom'};
J=handles.J;
Fs=handles.Fs;
Fs;
[E]=endpointdetect(J,Fs);
W=fix(.04*Fs);                 %Window length is 40 ms
SP=.4;                         %Shift percentage is (10ms) %Overlap-Add method works good with this value(.4)
Seg=segment1(E,W,SP);
%-------------------------------------------------
for nn=1:size(Seg,2)
[F0,T,C]=PitchTrackCepstrum(Seg(:,nn),Fs);
LE=sum(Seg(:,nn).^2);
[F T]=spFormantsTrackLpc(Seg(:,nn),Fs);
F1=F(1);F2=F(2);F3=F(3);
[MFC ME] = mfcc(Seg(:,nn),Fs);
fv(:,nn)=[F0 LE F1 F2 F3 MFC' ME']';
end
FT=fv(:);
if size(FT,1)<713;
    LL=713-length(FT);
    FT=[FT ;zeros(LL,1)];
else
    FT=FT(1:713);
end
mdel=handles.mdel;
nuu=handles.nuu;
res=mysvmtest(FT',mdel,nuu);
msgbox(['The Given Emotion is ',sp{res(1)}]);
clear FT J;
clear all

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
close all;

