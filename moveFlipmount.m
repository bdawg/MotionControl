function moveFlipmount(posn)
% Position must be the number 1 or 2

flipObj = serial('COM12', ...
    'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');

fopen(flipObj); %Open the device
flipObj.Terminator=''; %Set terminator to ''


%Move to position
if posn == 1
    disp('Moving to position 1')
    posn = '01';
elseif posn == 2
    disp('Moving to position 2')
    posn = '02';
else
    disp('Invalid position')
    posn = '00';
end

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


% Clean up when done
fclose(flipObj);
delete(flipObj);
clear flipObj



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