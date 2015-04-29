function varargout = starkedensitygui2(varargin)
% STARKEDENSITYGUI2 MATLAB code for starkedensitygui2.fig
%      STARKEDENSITYGUI2, by itself, creates a new STARKEDENSITYGUI2 or raises the existing
%      singleton*.
%
%      H = STARKEDENSITYGUI2 returns the handle to a new STARKEDENSITYGUI2 or the handle to
%      the existing singleton*.
%
%      STARKEDENSITYGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STARKEDENSITYGUI2.M with the given input arguments.
%
%      STARKEDENSITYGUI2('Property','Value',...) creates a new STARKEDENSITYGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before starkedensitygui2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to starkedensitygui2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help starkedensitygui2

% Last Modified by GUIDE v2.5 09-Dec-2013 16:15:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @starkedensitygui2_OpeningFcn, ...
                   'gui_OutputFcn',  @starkedensitygui2_OutputFcn, ...
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


% --- Executes just before starkedensitygui2 is made visible.
function starkedensitygui2_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to starkedensitygui2 (see VARARGIN)

% Choose default command line output for starkedensitygui2
handles.output = hObject;

% initial values of the checkboxes
handles.checkdseh = 0;
handles.checkwseh = 0;
handles.checkCnh = 0;
handles.checkCgh = 0;
handles.checkwavelengthh = 1;
handles.checkbkgh = 1;
handles.checkIonEh = 1;
handles.checkAlphah = 1;
handles.checkUpperEh = 1;
handles.checkUpperOQNh = 1;
handles.checkLowerEh = 1;
handles.checkLowerOQNh = 1;
handles.checkDensityh = 1;
handles.checkTgash = 1;
handles.checkRedMassh = 1;

ylabel(handles.axes1,'Relative Intensity');
xlabel(handles.axes1,'Wavelength (nm)');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes starkedensitygui2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = starkedensitygui2_OutputFcn(~, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Outputs when the upload new data file button is pressed
function newdata_Callback(hObject, ~, handles)
cla;

% calls up filename 
filename = handles.filename;

data = load(filename);

% saves data into handle data
handles.data = data;

guidata(hObject, handles);

% plots data to axes1
axes(handles.axes1);

plot(data(:,1), data(:,2))
ylabel(handles.axes1,'Relative Intensity');
xlabel(handles.axes1,'Wavelength (nm)');

% Upon button press estimates the background height of the data based
% on the specified wavelength range.
function estbkgd_Callback(hObject, eventdata, handles)

data = handles.data;
backgrLB = handles.backgroundLB;
backgrUB = handles.backgroundUB;

datasize = size(data);

sumbackgrd = 0;
counter = 0;

for C = 1 : datasize(1)
    if data(C,1) >= backgrLB && data(C,1) <= backgrUB
        sumbackgrd = sumbackgrd + data(C,2);
        counter = counter + 1;
    end
end

backgrd = sumbackgrd/counter;

set(handles.inputbkg,'string',backgrd)
handles.inputbkgh = backgrd;

guidata(hObject, handles);

% --- Upon button press fits the Voigt profile to the data, plots the data
% and calculates the Stark broadening and Van der Waals broadening terms
function startdecon_Callback(hObject, eventdata, handles)

% calls up input values for Voigt profile estimation
unknown(1) = handles.inputdseh;  % dse, electron impact shift
unknown(2) = handles.inputwseh; %wse, electron impact half width half max
unknown(3) = handles.inputCnh;  %Cn, normalizing factor
unknown(4) = handles.inputCgh; %Cg = 4*ln(2)/(wdop^2 + w^2)

global convsteps
global convintLB
global convintUB
global background
global data
global centwavelength

background = handles.inputbkgh;
datarangeLB = handles.datarangeLB;
datarangeUB = handles.datarangeUB;
convsteps = handles.convsteps;
convintLB = handles.convintLB;
convintUB = handles.convintUB;

lorentzScaling = .2;  % scaling the graph for the lorentzian to fit better on the screen
gaussScaling = .15;  % scaling the graph for the gaussian to fit better on the screen

data = handles.data;
centwavelength = handles.inputwavelengthh; 

% sets the range of data the deconvolution will look at
datasize = size(data);
counter = 1;

for C = 1 : datasize(1)
    if data(C,1) >= datarangeLB && data(C,1) <= datarangeUB
        xvalues(counter, 1) = data(C, 1);
        yvalues(counter, 1) = data(C, 2);
        counter = counter + 1;
    end
end

%calculating fit
fit = lsqcurvefit('Voigtprofile', unknown, xvalues, yvalues);

%plotting final fit
yfit = Voigtprofile(fit, xvalues);
MaxVoigt = max(yfit);
Lorfit = Lorenzfit(fit, xvalues);
MaxLor = max(Lorfit);
Gaussfit = Gaussianfit(fit, xvalues);
MaxGauss = max(Gaussfit);

axes(handles.axes1);
cla;
plot(xvalues, yfit,'b',  data(:,1), data(:,2),'.r', xvalues, Lorfit*(MaxVoigt/MaxLor*lorentzScaling)+background/2,'--m',xvalues, Gaussfit*(MaxVoigt/MaxGauss*gaussScaling),'.-g');
ylabel(handles.axes1,'Relative Intensity');
xlabel(handles.axes1,'Wavelength (nm)');

VDWHWHM = Vanderwaalsbroad(centwavelength, handles.inputIonEh, handles.inputAlphah, handles.inputUpperEh, handles.inputUpperOQNh, handles.inputLowerEh, handles.inputLowerOQNh, handles.inputDensityh, handles.inputTgash,handles.inputRedMassh);

starkbroadHWHM = fit(2) - VDWHWHM;

starkEdensity = starkbroadHWHM/(fit(2)*10^-16);

set(handles.calcdse,'string',fit(1))
set(handles.calcwse,'string',fit(2))
set(handles.calcCn,'string',fit(3))
set(handles.calcCg,'string',fit(4))
set(handles.usedwavelength,'string',centwavelength)
set(handles.usedbkg,'string',background)
set(handles.usedIonE,'string',handles.inputIonEh)
set(handles.usedAlpha,'string',handles.inputAlphah)
set(handles.usedUpperE,'string',handles.inputUpperEh)
set(handles.usedUpperOQN,'string',handles.inputUpperOQNh)
set(handles.usedLowerE,'string',handles.inputLowerEh)
set(handles.usedLowerOQN,'string',handles.inputLowerOQNh)
set(handles.useDensity,'string',handles.inputDensityh)
set(handles.usedTgas,'string',handles.inputTgash)
set(handles.usedRedMass,'string',handles.inputRedMassh)

set(handles.starkFWHM,'string',starkbroadHWHM)
set(handles.starkFWHMnoVDW,'string',fit(2))
set(handles.starkDensity,'string',starkEdensity)


% --- Executes on selection change in wavelengthmenu.
function wavelengthmenu_Callback(hObject, eventdata, handles)

switch get(handles.wavelengthmenu,'Value')   
    case 1
        set(handles.inputwavelength,'string','manual')
        handles.inputwavelengthh = 0;  %nm, the central wavelength
        set(handles.inputIonE,'string','manual')
        handles.inputIonEh = 0; %eV, ionization of emitting particle
        set(handles.inputAlpha,'string','manual')
        handles.inputAlphah = 1;  %alpha value from Griem books
        set(handles.inputUpperE,'string','manual')
        handles.inputUpperEh = 1;  %eV, upper transition energy level
        set(handles.inputUpperOQN,'string','manual')
        handles.inputUpperOQNh = 1;  % upper transition orbital Quantum number 
        set(handles.inputLowerE,'string','manual')
        handles.inputLowerEh = 1;  %eV, lower transition energy level
        set(handles.inputLowerOQN,'string','manual')
        handles.inputLowerOQNh = 1;  % lower transition orbital Quantum number 
        set(handles.inputDensity,'string','manual')
        handles.inputDensityh = 2.40886e19; %cm^-3, neutral density
        set(handles.inputTgas,'string','manual')
        handles.inputTgash = 300; %K, The neutral gas temperature
        set(handles.inputRedMass,'string','manual')
        handles.inputRedMassh = 1; %K, The neutral gas temperature
        guidata(hObject, handles);
    case 2  
        handles.inputwavelengthh = 794.8176;  %nm, the central wavelength
        handles.inputIonEh = 15.7595; %eV, ionization of emitting particle      
        handles.inputAlphah = 1.654*10^-24;  %alpha value for Ar i        
        handles.inputUpperEh = 13.28263821;  %eV, upper transition energy level        
        handles.inputUpperOQNh = 1;  % upper transition orbital Quantum number 
        handles.inputLowerEh = 11.7231597;  %eV, lower transition energy level        
        handles.inputLowerOQNh = 0;  % lower transition orbital Quantum number         
        handles.inputDensityh = 2.40886e19; %cm^-3, neutral density
        handles.inputTgash = 300; %K, The neutral gas temperature
        handles.inputRedMassh = 19.97;  %amu, the reduced mass
        
        set(handles.inputwavelength,'string',handles.inputwavelengthh)
        set(handles.inputIonE,'string',handles.inputIonEh)
        set(handles.inputAlpha,'string',handles.inputAlphah)
        set(handles.inputUpperE,'string',handles.inputUpperEh)
        set(handles.inputUpperOQN,'string',handles.inputUpperOQNh)
        set(handles.inputLowerE,'string',handles.inputLowerEh)
        set(handles.inputLowerOQN,'string',handles.inputLowerOQNh)
        set(handles.inputDensity,'string',handles.inputDensityh)
        set(handles.inputTgas,'string',handles.inputTgash)
        set(handles.inputRedMass,'string',handles.inputRedMassh)
        guidata(hObject, handles);
    case 3
        handles.inputwavelengthh = 737.2118;  %nm, the central wavelength
        handles.inputIonEh = 15.7595; %eV, ionization of emitting particle      
        handles.inputAlphah = 1.654*10^-24;  %alpha value for Ar i        
        handles.inputUpperEh = 14.7570507;  %eV, upper transition energy level        
        handles.inputUpperOQNh = 2;  % upper transition orbital Quantum number 
        handles.inputLowerEh = 13.07571492;  %eV, lower transition energy level        
        handles.inputLowerOQNh = 1;  % lower transition orbital Quantum number         
        handles.inputDensityh = 2.40886e19; %cm^-3, neutral density
        handles.inputTgash = 300; %K, The neutral gas temperature
        handles.inputRedMassh = 19.97;  %amu, the reduced mass
        
        set(handles.inputwavelength,'string',handles.inputwavelengthh)
        set(handles.inputIonE,'string',handles.inputIonEh)
        set(handles.inputAlpha,'string',handles.inputAlphah)
        set(handles.inputUpperE,'string',handles.inputUpperEh)
        set(handles.inputUpperOQN,'string',handles.inputUpperOQNh)
        set(handles.inputLowerE,'string',handles.inputLowerEh)
        set(handles.inputLowerOQN,'string',handles.inputLowerOQNh)
        set(handles.inputDensity,'string',handles.inputDensityh)
        set(handles.inputTgas,'string',handles.inputTgash)
        set(handles.inputRedMass,'string',handles.inputRedMassh)
        guidata(hObject, handles);
end

% --- Executes on button press in updmanparam.
function updmanparam_Callback(hObject, eventdata, handles)
% hObject    handle to updmanparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.checkdseh < 1
    set(handles.inputdse,'string',handles.guessdseh)
    handles.inputdseh = handles.guessdseh;
end

if handles.checkwseh < 1
    set(handles.inputwse,'string',handles.guesswseh)
    handles.inputwseh = handles.guesswseh;
end

if handles.checkCnh < 1
    set(handles.inputCn,'string',handles.guessCnh)
    handles.inputCnh = handles.guessCnh;
end

if handles.checkCgh < 1
    set(handles.inputCg,'string',handles.guessCgh)
    handles.inputCgh = handles.guessCgh;
end

if handles.checkwavelengthh < 1
    set(handles.inputwavelength,'string',handles.guesswavelengthh)
    handles.inputwavelengthh = handles.guesswavelengthh
end

if handles.checkbkgh < 1
    set(handles.inputbkg,'string',handles.guessbkgh)
    handles.inputbkgh = handles.guessbkgh;
end

if handles.checkIonEh < 1
    set(handles.inputIonE,'string',handles.guessIonEh)
    handles.inputIonEh = handles.guessIonEh;
end

if handles.checkAlphah < 1
    set(handles.inputAlpha,'string',handles.guessAlphah)
    handles.inputAlphah = handles.guessAlphah;
end

if handles.checkUpperEh < 1
    set(handles.inputUpperE,'string',handles.guessUpperEh)
    handles.inputUpperEh = handles.guessUpperEh;
end

if handles.checkUpperOQNh < 1
    set(handles.inputUpperOQN,'string',handles.guessUpperOQNh)
    handles.inputUpperOQNh = handles.guessUpperOQNh;
end

if handles.checkLowerEh < 1
    set(handles.inputLowerE,'string',handles.guessLowerEh)
    handles.inputLowerEh = handles.guessLowerEh;
end

if handles.checkLowerOQNh < 1
    set(handles.inputLowerOQN,'string',handles.guessLowerOQNh)
    handles.inputLowerOQNh = handles.guessLowerOQNh;
end

if handles.checkDensityh < 1
    set(handles.inputDensity,'string',handles.guessDensityh)
    handles.inputDensityh = handles.guessDensityh;
end

if handles.checkTgash < 1
    set(handles.inputTgas,'string',handles.guessTgash)
    handles.inputTgash = handles.guessTgash;
end

if handles.checkRedMassh < 1
    set(handles.inputRedMass,'string',handles.guessRedMassh)
    handles.inputRedMassh = handles.guessRedMassh;
end

guidata(hObject, handles);


% all of the callback commands and create function commands, they are only
% for calling in input values and nothing else.  If initial values are
% wanted, values can be input into the create function commmands.

function filename_Callback(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename as text
%        str2double(get(hObject,'String')) returns contents of filename as a double
handles.filename = get(hObject,'String');

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function datarangeLB_Callback(hObject, eventdata, handles)
% hObject    handle to datarangeLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of datarangeLB as text
%        str2double(get(hObject,'String')) returns contents of datarangeLB as a double

handles.datarangeLB = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function datarangeLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datarangeLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function datarangeUB_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of datarangeUB as text
%        str2double(get(hObject,'String')) returns contents of datarangeUB as a double
handles.datarangeUB = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function datarangeUB_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function convintLB_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of convintLB as text
%        str2double(get(hObject,'String')) returns contents of convintLB as a double
handles.convintLB = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function convintLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to convintLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function convintUB_Callback(hObject, eventdata, handles)
% hObject    handle to convintUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of convintUB as text
%        str2double(get(hObject,'String')) returns contents of convintUB as a double
handles.convintUB = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function convintUB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to convintUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function convsteps_Callback(hObject, eventdata, handles)
% hObject    handle to convsteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of convsteps as text
%        str2double(get(hObject,'String')) returns contents of convsteps as a double
handles.convsteps = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function convsteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to convsteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function backgroundLB_Callback(hObject, eventdata, handles)
% hObject    handle to backgroundLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of backgroundLB as text
%        str2double(get(hObject,'String')) returns contents of backgroundLB as a double
handles.backgroundLB = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function backgroundLB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backgroundLB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function backgroundUB_Callback(hObject, eventdata, handles)
% hObject    handle to backgroundUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of backgroundUB as text
%        str2double(get(hObject,'String')) returns contents of backgroundUB as a double
handles.backgroundUB = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function backgroundUB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backgroundUB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function guessdse_Callback(hObject, eventdata, handles)
handles.guessdseh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessdse_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function guesswse_Callback(hObject, eventdata, handles)
handles.guesswseh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guesswse_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function guessCn_Callback(hObject, eventdata, handles)
handles.guessCnh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessCn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function guessCg_Callback(hObject, eventdata, handles)
handles.guessCgh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessCg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function guesswavelength_Callback(hObject, eventdata, handles)
handles.guesswavelengthh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guesswavelength_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function guessbkg_Callback(hObject, eventdata, handles)
handles.guessbkgh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessbkg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function wavelengthmenu_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function guessIonE_Callback(hObject, eventdata, handles)
handles.guessIonEh = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function guessIonE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function guessUpperE_Callback(hObject, eventdata, handles)
handles.guessUpperEh = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function guessUpperE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function guessUpperOQN_Callback(hObject, eventdata, handles)
handles.guessUpperOQNh = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function guessUpperOQN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function guessTgas_Callback(hObject, eventdata, handles)
handles.guessTgash = str2double(get(hObject,'String'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function guessTgas_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkdse.
function checkdse_Callback(hObject, eventdata, handles)
handles.checkdseh = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkwse.
function checkwse_Callback(hObject, eventdata, handles)
handles.checkwseh = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkCn.
function checkCn_Callback(hObject, eventdata, handles)
handles.checkCnh = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkCg.
function checkCg_Callback(hObject, eventdata, handles)
handles.checkCgh = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkwavelength.
function checkwavelength_Callback(hObject, eventdata, handles)
handles.checkwavelengthh = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkbkg.
function checkbkg_Callback(hObject, eventdata, handles)
handles.checkbkgh = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkIonE.
function checkIonE_Callback(hObject, eventdata, handles)
handles.checkIonEh = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkUpperE.
function checkUpperE_Callback(hObject, eventdata, handles)
handles.checkUpperEh = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkUpperOQN.
function checkUpperOQN_Callback(hObject, eventdata, handles)
handles.checkUpperOQNh = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in checkTgas.
function checkTgas_Callback(hObject, eventdata, handles)
handles.checkTgash = get(hObject,'Value');

guidata(hObject, handles);

function guessLowerOQN_Callback(hObject, eventdata, handles)
handles.guessLowerOQNh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessLowerOQN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkLowerOQN.
function checkLowerOQN_Callback(hObject, eventdata, handles)
handles.checkLowerOQNh = get(hObject,'Value');

guidata(hObject, handles);

function guessLowerE_Callback(hObject, eventdata, handles)
handles.guessLowerEh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessLowerE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkLowerE.
function checkLowerE_Callback(hObject, eventdata, handles)

handles.checkLowerEh = get(hObject,'Value');

guidata(hObject, handles);

function guessAlpha_Callback(hObject, eventdata, handles)
handles.guessAlphah = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessAlpha_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkAlpha.
function checkAlpha_Callback(hObject, eventdata, handles)

handles.checkAlphah = get(hObject,'Value');

guidata(hObject, handles);

function guessTgas_Callback(hObject, eventdata, handles)
handles.guessTgash = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessTgas_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function guessRedMass_Callback(hObject, eventdata, handles)
handles.guessRedMassh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessRedMass_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkRedMass.
function checkRedMass_Callback(hObject, eventdata, handles)
handles.checkRedMassh = get(hObject,'Value');

guidata(hObject, handles);

function guessDensity_Callback(hObject, eventdata, handles)
handles.guessDensityh = str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function guessDensity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkDensity.
function checkDensity_Callback(hObject, eventdata, handles)
handles.checkDensityh = get(hObject,'Value');

guidata(hObject, handles);
