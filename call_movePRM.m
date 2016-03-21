angle=360*4+10;
angle=129; %% this value (129) is horizontal
% NB if facing camera it rotates clockwise with positive number rotation

prmObj = serial('COM11', ...
    'BaudRate',115200,'DataBits',8,'Parity','none','StopBits',1,'FlowControl','none');


fopen(prmObj); %Open the device
prmObj.Terminator=''; %Set terminator to ''

%Get hardware info
%Send request:
% nbytes=6;
% hexString={'05' '00' '00' '00' '50' '01'};
% for ii = 1:nbytes
%     hex=hexString{ii};
%     dec=hex2dec(hex);
%     fwrite(prmObj,dec,'uint8')
% end
% 
% %Retrieve the get
% nbytes=90;
% response=fread(prmObj,nbytes);
% modelNo=response(11:18);
% modelNo = char(modelNo)


%Get position
%Send request:
nbytes=6;
hexString={'90' '04' '00' '00' '50' '01'};
for ii = 1:nbytes
    hex=hexString{ii};
    dec=hex2dec(hex);
    fwrite(prmObj,dec,'uint8')
end

%Retrieve the get
nbytes=20;
response=fread(prmObj,nbytes);
posnHex=response(9:12)








% nbytes=6;
% hexString={'43' '04' '00' '00' '50' '01'};
% for ii = 1:nbytes
%     hex=hexString{ii};
%     dec=hex2dec(hex);
%     fwrite(prmObj,dec,'uint8')
% end




%movePRM(prmObj,angle,0)

% Clean up when done
fclose(prmObj);
delete(prmObj);
clear prmObj
