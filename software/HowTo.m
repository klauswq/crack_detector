%% Usual setup---step 1
pi=raspi('169.254.0.2','pi','raspberry');
% Dont forget environmental variables
%% Use this to transfer files---step 2
pi.putFile('touch_probe','/home/pi/touch_probe');
%%-step 3
tp=TouchProbe('http://169.254.0.3:11311','169.254.0.3');
tp.disp_fsr();
%% Run the example nodes via pi shell (pi.openShell)-step 4
% Make sure env vars are setup
% The start.sh script runs all examples at once. Use:
% >>sh toucht_probe/start.sh
% But you can simply run them one by one.
%% step 5
tp.drive_servo(0,0,2);
pause(2);

%***************************************************%
%You can run any section in the step 6, which includes poking and drafting
%and each approach with high or low resolution, then continue with step 7
%% step 6
%pork at high resolution
x_m=0.3:0.1:3.4;% x aixi
l_x=length(x_m);
y_m=0:0.05:3.4;% y axis
l_y=length(y_m);
value=zeros(l_x,l_y,1);% height matrix
i=1;
j=1;
tp.drive_servo(0.2,0,2); % drive to initial position
pause(2);
for x=0.3:0.1:3.4
    for y=0:0.05:3.4
        z=0.5;% drop the z-axis
        msg_x=x;
        msg_y=y;
        msg_z=z;% move to corresponding position 
        tp.drive_servo(msg_x,msg_y,msg_z);
        pause(0.4);
        value(i,j,:)=double(tp.value);% record the force of pressure in this position
        j=j+1;
        pause(0.3);
        z=2; %raise the z-axis
        msg_x=x;
        msg_y=y;
        msg_z=z;
        tp.drive_servo(msg_x,msg_y,msg_z);
        pause(0.4);
    end
        j=1;
        i=i+1;   
end

pause(2);
tp.drive_servo(0,0,1);

%% step 6
%drag at high resolution
x_m=0.4:0.1:3.4;
l_x=length(x_m);
y_m=0:0.1:3.8;
l_y=length(y_m);
value=zeros(l_x,l_y,1);
i=1;
j=1;
tp.drive_servo(0.2,0,2);
pause(2);
for x=0.4:0.1:3.4
    for y=0:0.1:3.3
        z=0.5;
        msg_x=x;
        msg_y=y;
        msg_z=z;
        tp.drive_servo(msg_x,msg_y,msg_z);
        pause(0.4);
        value(i,j,:)=double(tp.value);
        j=j+1;
        pause(0.2);
         z=2;
         pause(0.1);
%         msg_x=x;
%         msg_y=y;
%         msg_z=z;
%         tp.drive_servo(msg_x,msg_y,msg_z);
%         pause(0.4);
    end
        j=1;
        i=i+1;   
end

pause(2);
tp.drive_servo(0,0,1);

%% step 6
%pork at low resolution
x_m=0:0.2:3.4;
l_x=length(x_m);
y_m=0:0.2:3.8;
l_y=length(y_m);
value=zeros(l_x,l_y,1);
i=1;
j=1;
tp.drive_servo(0.2,0,2);
pause(2);
for x=0:0.2:3.4
    for y=0:0.2:3.8
        z=0;
        msg_x=x;
        msg_y=y;
        msg_z=z;
        tp.drive_servo(msg_x,msg_y,msg_z);
        pause(0.4);
        value(i,j,:)=double(tp.value);
        j=j+1;
        pause(0.3);
        z=2;
        msg_x=x;
        msg_y=y;
        msg_z=z;
        tp.drive_servo(msg_x,msg_y,msg_z);
        pause(0.4);
    end
        j=1;
        i=i+1;   
end

pause(2);
tp.drive_servo(0,0,1);

%% step 6
%drag at low resolution
x_m=0:0.2:3.4;
l_x=length(x_m);
y_m=0:0.2:3.8;
l_y=length(y_m);
value=zeros(l_x,l_y,1);
i=1;
j=1;
tp.drive_servo(0.2,0,2);
pause(2);
for x=0:0.2:3.4
    for y=0:0.2:3.8
        z=0;
        msg_x=x;
        msg_y=y;
        msg_z=z;
        tp.drive_servo(msg_x,msg_y,msg_z);
        pause(0.4);
        value(i,j,:)=double(tp.value);
        j=j+1;
        pause(0.3);
%         z=2;
%         msg_x=x;
%         msg_y=y;
%         msg_z=z;
%         tp.drive_servo(msg_x,msg_y,msg_z);
%         pause(0.4);
    end
        j=1;
        i=i+1;   
end

pause(2);
tp.drive_servo(0,0,1);
%% step 7 plot the results
%mesh grid of original image  
r=x_m;
c=y_m;
[X,Y] = meshgrid(r,c);
Z=zeros(l_x,l_y);
for i=1:1:l_x
    for j=1:1:l_y
        Z(i,j)=8*value(i,j,:);
    end
end
%Z=peaks(X,Y);
%surfl(X,Y,Z); 
hold off
shading interp;
colormap cool;
colorbar 
mesh(Z);

xlabel('x axis');
ylabel('y axis');
zlabel('force of pressure');
% mesh grid of the optimal image
f=figure;
d=zeros(size(Z));
d_size=size(Z);
row=d_size(1);
col=d_size(2);

%-------------------------------------------%
    %weight of each point varies, the weight of current point is 2,
    %the weight of diagonal point is 0.5
%-------------------------------------------%
     
for i=1:1:row-1
    for j=1:1:col-1
        if j==col-1
            d(i,j+1)=(2*Z(i,j+1)+Z(i,j)+Z(i+1,j)+0.5*Z(i+1,j+1))/4;
        else   
            d(i,j)=(2*Z(i,j)+Z(i+1,j)+Z(i,j+1)+0.5*Z(i+1,j+1))/4;
        end
        
        
        if i==row-1
            d(i+1,j)=(2*Z(i,j)+Z(i+1,j)+Z(i,j+1)+0.5*Z(i+1,j+1))/4;
        end
         
    end
end
shading interp;
colormap cool;
colorbar 
mesh(d);

%image of the thresholding classifier
f=figure;
u=zeros(size(Z));
u_size=size(Z);
row=u_size(1);
col=u_size(2);
for i=1:1:row-1
    for j=1:1:col-1
        if j==col-1
            u(i,j+1)=(2*Z(i,j+1)+Z(i,j)+Z(i+1,j)+0.5*Z(i+1,j+1))/4;
        else   
            u(i,j)=(2*Z(i,j)+Z(i+1,j)+Z(i,j+1)+0.5*Z(i+1,j+1))/4;
        end
        
        
        if i==row-1
            u(i+1,j)=(2*Z(i,j)+Z(i+1,j)+Z(i,j+1)+0.5*Z(i+1,j+1))/4;
        end
        % the threshold value will determine the height of each point 
        if u(i,j)>1.3
            u(i,j)=1*u(i,j);
        else
            u(i,j)=0;
        end
         
    end
end
shading interp;
colormap cool;
colorbar 
mesh(u);
xlabel('x axis');
ylabel('y axis');
zlabel('force of pressure');



%% step 8 
rosshutdown
clear       