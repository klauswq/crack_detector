classdef TouchProbe<handle % Inherit from handle, this makes it behave like a JAVA object (read about it, don't be lazy)
    % this is a proof-of-concept code for the touch probe based on OOP
    % MATLAB
    properties
        %setup vars
        node;
        self_ip;
        master_ip;
        %subpub vars
        sub_camera;
        sub_fsr;
        pub_servo;
        msg_servo;
        %other
        fig;
        fsr_value;
        value;
        
        x;
        y;
        startTime;
        h;
        ax;
        t;
    end
    
    %     This code assumes these topic names and message types
    properties
        cam_topic='rpi2_testy/pi_camera/image';
        cam_msg_type='sensor_msgs/Image';
        fsr_topic='/force_sns/ch0';
        fsr_msg_type='std_msgs/Float32';
        servo_topic='servo_control';
        servo_msg_type='geometry_msgs/Point';
        node_name='Touch_probe';
        
    end
    
    methods
        %Constructor
        function self=TouchProbe(master_ip,self_ip)
            %Network setup
            self.master_ip=master_ip;
            self.self_ip=self_ip;
            self.set_env();            
            self.node = robotics.ros.Node(self.node_name);
            %subs setup:
            self.init_subs();
            %pub setup
            self.init_pubs();
            
            
        end
        
        function disp_cam(self)
            if isempty(self.fig)
                self.fig=[];
                %self.fig=figure;
                %self.fig.Children=axes;
            end
            self.sub_camera.NewMessageFcn=@self.camera_callback;
        end
        
        function stop_cam_disp(self)
            if  isempty(self.fig)
                return
            end
            self.sub_camera.NewMessageFcn=[];%Syntax for deleting objects
            self.fig.delete();
            self.fig=[];
        end
        
        
        function disp_fsr(self)
            self.h=animatedline;
            self.ax=gca;
            self.ax.YGrid='on';
            self.ax.YLim=[0 15];
            self.startTime=datetime('now');
            
            self.sub_fsr.NewMessageFcn=@self.fsr_callback;
        end
        
        function stop_fsr_disp(self)
            self.sub_fsr.NewMessageFcn=[];
        end
        
        function span_servo(self)
            for ii=1:20
                self.servo_x_msg.Data=ii;
                self.pub_servo_x.send(self.servo_x_msg);
                pause(0.3)
            end
        end
        
    end
    
    methods
        
        function set_env(self)
            sprintf("Setting ROS env variables:\n ROS_MASTER_URI =%s\nROS_IP =%s\n ",self.master_ip,self.self_ip);
            %setenv('ROS_MASTER_URI',self.master_ip);
            
            setenv('ROS_IP',self.self_ip);
            rosinit
        end
                       
        function init_subs(self)             
            self.sub_camera=rossubscriber(self.cam_topic,self.cam_msg_type);
            self.sub_fsr=rossubscriber(self.fsr_topic,self.fsr_msg_type);
        end
        
        function init_pubs(self)
            self.pub_servo=rospublisher(self.servo_topic,self.servo_msg_type);  
            self.msg_servo=rosmessage(self.pub_servo);
        end
        
        function drive_servo(self,msg_x,msg_y,msg_z)
            self.msg_servo.X=msg_x;
            self.msg_servo.Y=msg_y;
            self.msg_servo.Z=msg_z;
            self.pub_servo.send(self.msg_servo);
        end
        
        function move_around(self)
            for x=0:3
                self.msg_servo.Z=1;
                self.pub_servo.send(self.msg_servo);
                pause(1);
                for y=0:4
                    self.msg_servo.X=x;
                    self.msg_servo.Y=y;
                    self.msg_servo.Z=0;
                    self.pub_servo.send(self.msg_servo);
                end
            end
        end
        
        function camera_callback(self,sub,msg)%please understand why these argument are here. Read about callbacks.
            img=readImage(msg);%please understand why this is called. Read about this function.
            %imshow(img,'Parent',self.gui.UIAxes2);% figures have axes, images live in axes. So the parent of an image is the child of the figure.
        end
        
        function fsr_callback(self,sub,msg)
%             
            x=msg.Data;
            x = x* 3.3 / 1000;
             if x >= 1.45
                y = 4.6314*x^4 - 32.842*x^3 + 87.877*x^2 - 103.86*x + 45.735;
             else
                y = 0.172 * x;
             end
            self.value=y;
            
            self.t=datetime('now')-self.startTime;
            addpoints(self.h,datenum(self.t),double(self.value));
            self.ax.XLim=datenum([self.t-seconds(15) self.t]);
            datetick('x','keeplimits')
            drawnow
            disp(self.value);
%             
        end
        

    end
end

