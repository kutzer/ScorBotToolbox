%classdef ScorBot < hgsetge
classdef ScorBot < matlab.mixin.SetGet
    % ScorBot handle class for creating an object to interact with 
    properties(GetAccess = 'public', SetAccess = 'public')
        MoveTime
        MoveType
        BSEPR       %Joint angles
        XYZPR       %Task Space
        Pose        %Task Space (SE3)
        Gripper
        Speed
    end
    
    methods(Access = 'public')
        function obj = ScorBot
            ScorInit;
            ScorHome;
            MoveTime = ScorGetMoveTime;
            MoveType = 'LinearJoint';
            BSEPR    = ScorGetBSEPR;
            XYZPR    = ScorGetXYZPR;
            Pose     = ScorGetPose;
            Gripper  = ScorGetGripper;
            Speed    = ScorGetSpeed;
        end
        
        function delete(obj)
            ScorSafeShutdown;
            delete(obj);
        end            
    end
    
    methods
        function BSEPR = get.BSEPR(obj)
            disp('TEST')
            BSEPR = ScorGetBSEPR;
        end
        
        function XYZPR = get.XYZPR(obj)
            XYZPR = ScorGetXYZPR;
        end
        
        function Pose = get.Pose(obj)
            Pose = ScorGetPose;
        end
        
        function Gripper = get.Gripper(obj)
            Gripper = ScorGetGripper;
        end
        
        function Speed = get.Speed(obj)
            Speed = ScorGetSpeed;
        end
        
        function obj = set.BSEPR(obj, value)
            obj.BSEPR = value;
            ScorSetBSEPR(value, 'MoveType', obj.MoveType);
        end
        
        function obj = set.XYZPR(obj, value)
            obj.XYZPR = value;
            ScorSetXYZPR(value, 'MoveType', obj.MoveType);
        end
        
        function obj = set.Pose(obj, value)
            obj.Pose = value;
            ScorSetPose(value);
        end
        
        function obj = set.Gripper(obj, value)
            obj.Gripper = value;
            ScorSetGripper(value);
        end
        
        function obj = set.Speed(obj, value)
            obj.Speed = value;
            ScorSetSpeed(value);
        end
        
        function obj = set.MoveTime(obj, value)
            obj.MoveTime = value;
            ScorSetMoveTime(value);
        end
        
        function obj = set.MoveType(obj, value)
            switch(value)
                case 'LinearJoint'
                    obj.MoveType = 'LinearJoint';
                case 'LinearTask'
                    obj.MoveType = 'LinearTask';
                otherwise
                    error('Move Type must be LinearTask or LinearJoint');   
            end
        end
        
    end
end