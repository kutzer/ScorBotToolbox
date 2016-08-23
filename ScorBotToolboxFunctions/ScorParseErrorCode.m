function errStruct = ScorParseErrorCode(eCode)
% SCORPARSEERRORCODE parses a numeric error code from the ScorBot,
% returning a message describing the error.
%   errStruct = SCORPARSEERRORCODE(eCode) returns a structured array with a
%   field describing the error, and a field with the recommended mitigation
%   to eliminate the error.
%       errStruct.Code       - ScorBot error code (integer value) 
%       errStruct.Message    - Message describing ScorBot error code
%       errStruct.Mitigation - Suggested mitigation for ScorBot error
%
%   See also ScorIsReady
%
%   References:
%       [1] B. Mirko, "Error.h," Eshed Robotec R&D, 27June1993
%       [2] Shimon, edits to "Error.h," Eshed Robotec R&D, 24Sept2001
%
%   M. Kutzer, D. DiSerio, & C. Wick, 28Aug2015, USNA

% Updates
%   15Sep2015 - Updated to include mitigation for message 912
%   28Sep2015 - Updated to include mitigation for message 516

% TODO - Complete this function

%% Set Defaults
errStruct.Code       = eCode;
errStruct.Message    = [];
errStruct.Mitigation = [];
errStruct.QuickFix   = []; % experimental
if eCode <= 0
    return
end

%% Fatal Errors
eType = 'FATAL';

msg{1} = sprintf('%s: Invalid status of motion encountered',eType);
msg{2} = sprintf('%s: Position error during or impact occurred unable to reach PIC',eType);
msg{3} = sprintf('%s: Unable to communicte with PIC',eType);
msg{4} = sprintf('%s: Reentrance occured in the RTC driven procedure',eType);
msg{5} = sprintf('%s: Singular point encountered or error in robot kinematics parameters',eType);
msg{6} = sprintf('%s: Motion status invalid',eType);
msg{7} = sprintf('%s: Memory problems',eType);
msg{10} = sprintf('%s: ',eType);
msg{11} = sprintf('%s: ',eType);
msg{12} = sprintf('%s: ',eType);
msg{20} = sprintf('%s: Controller is not responding',eType);
msg{30} = sprintf('%s: Invalid board address',eType);
msg{40} = sprintf('%s: A/D conversion error',eType);
msg{50} = sprintf('%s: PIC not ready',eType);
msg{51} = sprintf('%s: The message does not come out of the stack',eType);
msg{52} = sprintf('%s: Full',eType);
msg{53} = sprintf('%s: ',eType);
msg{54} = sprintf('%s: ',eType);
msg{55} = sprintf('%s: ',eType);
msg{56} = sprintf('%s: Invalid reset',eType);
msg{60} = sprintf('%s: Unable to send string',eType);

% //-------------------------------------------------------------------------
% #define OK			   0
% #define KIN_OK    	   0
% #define ERR_IO		   1	//"FATAL: Invalid status of motion ecountered"
% #define ERR_TR_SND	   2	//"FATAL: Position error during or impact occured unable to reach PIC"
% #define ERR_TCK_SND	   3	//"FATAL: Unable to communicte with PIC"
% #define ERR_REE		   4	//"FATAL: Reentrance occured in the RTC driven procedure"
% #define ERR_SKIN		   5	//"FATAL: Singular point encountered or error in robot kinematics parameters"
% #define ERR_MST		   6	//"FATAL: Motion status invalid"
% #define ERR_MEM          7	//"Memory problems"
% 
% #define KIN_GEAR        10
% #define KIN_CFG         11
% #define KIN_CCFG        12
% 
% #define ERR_NOT_RESPOND 20	// "Controller is not responding"
% #define ERR_ADD		  30	// "Invalid board address"
% #define ERR_ADC         40	// A/D conversion error
% 
% #define ERR_PNR         50	// "PIC not ready"
% #define ERR_ESTK        51	// "The message doesn't come out of the stack"
% #define ERR_FLL	      52	//"Full"
% #define ERR_MBFF	      53
% #define ERR_SLCT	      54
% #define ERR_LRG	      55
% #define ERR_IRST        56	// Invalid reset
% 
% #define ERR_SST         60	// "Unable to send string"
% 
% // Up to this error code are FATAL ERRORS *********************************
% //-------------------------------------------------------------------------
%% Robot Errors
eType = 'ROBOT';

msg{200} = sprintf('%s: ',eType);
msg{201} = sprintf('%s: Position error during the motion is greater than allowed or impact has occurred',eType);
mit{201} = sprintf('Run "ScorHome" to re-home ScorBot');
qfx{201} = sprintf('ScorHome;');
msg{202} = sprintf('%s: Thermal overload',eType);
msg{203} = sprintf('%s: The PB is off',eType);
msg{300} = sprintf('%s: Emergency ON!!',eType);
msg{301} = sprintf('%s: Emergency OFF!!',eType);

% #define ERR_FATAL		  200
% #define ERR_TRCK		  201	//" Position error during the motion is grater then allowed or impact has occured"
% #define ERR_THR		  202	//" Thermic overload
% #define ERR_PWOFF       203	//" The PB is off "
% #define ERR_EMERG_ON    300	//" Emergency ON!!
% #define ERR_EMERG_OFF	  301	//" Emergency OFF!!
% 
% // Up to this error code are ROBOT ERRORS *********************************
% //-------------------------------------------------------------------------

%% System Errors
eType = 'SYSTEM';

msg{500} = sprintf('%s: Position error during the motion is greater than allowed or impact has occurred',eType);
mit{500} = sprintf('Run "ScorHome" to re-home ScorBot');
qfx{500} = sprintf('ScorHome;');
msg{511} = sprintf('%s: Power Box error',eType);
msg{512} = sprintf('%s: ',eType);
msg{513} = sprintf('%s: ',eType);
msg{514} = sprintf('%s: ',eType);
msg{515} = sprintf('%s: ',eType);
msg{516} = sprintf('%s: ',eType);
msg{517} = sprintf('%s: ',eType);
msg{522} = sprintf('%s: Path or file not found',eType);
msg{523} = sprintf('%s: Too many open files',eType);
msg{524} = sprintf('%s: Invalid access code',eType);
msg{525} = sprintf('%s: Unable to close file',eType);
msg{527} = sprintf('%s: Permission denied',eType);
msg{528} = sprintf('%s: Bad file number',eType);
msg{529} = sprintf('%s: Error while writing parameters',eType);
msg{530} = sprintf('%s: Error while reading parameters',eType);
msg{531} = sprintf('%s: Unknown error option',eType);
msg{532} = sprintf('%s: Invalid name',eType);
msg{533} = sprintf('%s: Invalid parameter',eType);
msg{534} = sprintf('%s: Too long line',eType);
msg{535} = sprintf('%s: File not opened',eType);
msg{536} = sprintf('%s: File not closed',eType);
msg{550} = sprintf('%s: Invalid points of the arc',eType);
msg{551} = sprintf('%s: Invalid robot type',eType);
msg{560} = sprintf('%s: Invalid mode',eType);
msg{561} = sprintf('%s: Time for homing elapsed',eType);
mit{561} = sprintf('Run "ScorHome" to re-home ScorBot');
qfx{561} = sprintf('ScorHome;');
msg{562} = sprintf('%s: Invalid or unrecognized command',eType);
msg{563} = sprintf('%s: Home switch not found',eType);
msg{564} = sprintf('%s: Plus limit',eType);
msg{565} = sprintf('%s: Minus limit',eType);
msg{566} = sprintf('%s: Stack Full',eType);
msg{567} = sprintf('%s: Immediate mode',eType);
msg{568} = sprintf('%s: Peripheral axis is not connected',eType);
msg{569} = sprintf('%s: Homing aborted by user',eType);
msg{580} = sprintf('%s: Axis number too big',eType);
msg{581} = sprintf('%s: Invalid acceleration parameter',eType);
msg{582} = sprintf('%s: Invalid parmeter of increase of acceleration',eType);
msg{583} = sprintf('%s: Invalid velocity',eType);
msg{584} = sprintf('%s: Unable to stop motion',eType);
msg{586} = sprintf('%s: Invalid motion duration',eType);
msg{587} = sprintf('%s: Zero velocity!',eType);
msg{588} = sprintf('%s: Invalid motion type option!',eType);
msg{589} = sprintf('%s: Invalid coordinate type option!',eType);
msg{590} = sprintf('%s: Unable to initialize parameters while robot is moving!',eType);
msg{600} = sprintf('%s: Invalid data',eType);
msg{601} = sprintf('%s: Too few arguments',eType);
msg{602} = sprintf('%s: Unsupported group',eType);
msg{603} = sprintf('%s: Invalid number of axes',eType);
msg{604} = sprintf('%s: Invalid gripper and group B values',eType);
msg{605} = sprintf('%s: INIT',eType);
msg{607} = sprintf('%s: Invalid sample time',eType);
msg{608} = sprintf('%s: RTC was not started!',eType);
msg{701} = sprintf('%s: ',eType);
msg{702} = sprintf('%s: ',eType);
msg{703} = sprintf('%s: ',eType);
msg{704} = sprintf('%s: ',eType);
msg{705} = sprintf('%s: ',eType);
msg{706} = sprintf('%s: ',eType);
msg{708} = sprintf('%s: ',eType);
msg{710} = sprintf('%s: ',eType);
msg{711} = sprintf('%s: ',eType);
msg{712} = sprintf('%s: ',eType);
msg{714} = sprintf('%s: ',eType);
msg{715} = sprintf('%s: ',eType);
msg{716} = sprintf('%s: ',eType);
msg{717} = sprintf('%s: ',eType);
msg{718} = sprintf('%s: ',eType);
msg{719} = sprintf('%s: ',eType);
msg{721} = sprintf('%s: ',eType);
msg{750} = sprintf('%s: ',eType);
msg{751} = sprintf('%s: ',eType);
msg{742} = sprintf('%s: ',eType);

% //-------------------------------------------------------------------------
% #define ERR_ROBOT		     500  //" Position error during the motion is grater then allowed or impact has occured"
% 
% #define ERR_PB             511  //" Power Box error
% #define ERR_PB_UNR  	     512
% #define ERR_PB_OVR  	     513
% #define ERR_PB_LEN  	     514
% #define ERR_PB_NUM  	     515
% #define ERR_PB_BFOVR       516
% #define ERR_PB_OCURR       517
% 
% #define ERR_PF_NF          522  // "%s:(Path or file not found)"
% #define ERR_TOO_F          523  // "(Too many open files)"
% #define ERR_IN_ACC         524  // "(Invalid access code)"
% #define ERR_CLOSE          525  // "Unable to close file"
% #define ERR_PER_DEN        527  // "Permission denied"
% #define ERR_BAD_FN         528  // "Bad file number"
% #define ERR_PAR_WR         529  // "Error while writing parameters"
% #define ERR_PAR_RE         530  // "Error while reading parameters"
% #define ERR_UK_ERR         531  //"%s : Unknown error option"
% #define ERR_INVNM		     532  // Invalid name
% #define ERR_INVPAR	     533  // Invalid parameter
% #define ER_BK_LNL  	     534  // Too long line
% #define ERR_NO_OPEN        535  // File not opened
% #define ERR_NO_CLOSE       536  // File not closed
% 
% #define ERR_INVP           550  //  "Invalid points of the arc "
% #define ERR_ROBT           551  //  "Invalid robot type "
% 
% #define ERR_MOD            560  //"Invalid mode"
% #define ERR_HT             561  //"Time for homing elapsed"
% #define ERR_IC             562  //"Invalid or unreckognized command"
% #define ERR_HNF		     563  //"Home switch not found"
% #define ERR_PL             564  //"Plus limit"
% #define ERR_ML             565  //"Minus limit"
% #define ERR_STCK           566  // Stack Full
% #define ERR_IMM            567  // Immediate mode
% #define ERR_NOT_CONNECT    568  // Peripheral axis is not connected. Shimon
% #define ERR_HOME_ABORTED   569  // Homing aborted by user.
% 
% #define ERR_A_BIG          580  //"Axis number too big"
% #define ERR_A_PAR	         581  //"Invalid acceleration parameter"
% #define ERR_AA_PAR         582  //"Invalid parmeter of increase of acceleration"
% #define ERR_VELO_PAR       583  //"Invalid velocity"
% #define ERR_STP	         584  //"Unable to stop motion"
% #define ERR_MDUR           586  //"Invalid motion duration"
% #define ERR_VEL_Z	         587  // "Zero velocity!"
% #define ERR_MTYP	         588  //"Invalid motion type option!"
% #define ERR_CTYP	         589  //"Invalid coordinate type option!"
% #define ERR_IWM	         590  //"Unable to initialize parameters while robot is moving!"
% 
% #define ERR_INDAT 	     600  //"Invalid data"
% #define ERR_TOO_FEW        601  //"Too few arguments"
% #define ERR_GRP_NSP        602  //"Unsupported group"
% #define ERR_AXNUM          603  //"Invalid number of axes"
% 
% #define ERR_GRP_B	         604  // "Invalid gripper and group B values"
% #define ERR_INIT           605  // "INIT"
% #define ERR_SEM_T          607  //"Invalid sample time"
% #define ERR_STRT           608  //"RTC was not started!"
% 
% #define CMM_ERR_INVDESC    701
% #define CMM_ERR_INVOPT     702
% #define CMM_ERR_INVAX      703
% #define CMM_ERR_INVGRP     704
% #define CMM_ERR_INVIND     705
% #define CMM_ERR_INVNAM     706
% #define CMM_ERR_LNGMSS     708
% #define CMM_ERR_NOTIN      710
% #define CMM_ERR_TIM        711
% #define CMM_ERR_MLON       712
% #define CMM_ERR_MFLL       714
% #define CMM_ERR_NRED       715
% #define CMM_ERR_UEXP       716
% #define CMM_ERR_UANS       717
% #define CMM_UNASS          718
% #define COMM_LOCK          719
% #define COMM_NOTTP         721
% #define CMM_UNKNOWN_SOURCE 750
% #define CMM_ERR_INVCHN     751
% #define CMM_CTRL_UNKN      742
% 
% // Up to this error code are SYSTEM ERRORS *********************************
% //-------------------------------------------------------------------------

%% User Errors
eType = 'USER';

msg{900} = sprintf('%s: Position error during the motion is greater then allowed or impact has occurred',eType);
mit{900} = sprintf('Run "ScorHome" to re-home ScorBot');
qfx{900} = sprintf('ScorHome;');
msg{901} = sprintf('%s: Home not done',eType);
mit{901} = sprintf('Run "ScorHome" to re-home ScorBot');
qfx{901} = sprintf('ScorHome;');
msg{902} = sprintf('%s: Manual motion not allowed (singularity)',eType);
msg{903} = sprintf('%s: Control disabled',eType);
mit{903} = sprintf('Use "ScorSetControl(''On'')" to enable control');
qfx{903} = sprintf('ScorSetControl(''On'');');
msg{904} = sprintf('%s: Invalid coordinate type!',eType);
msg{905} = sprintf('%s: Given point is not in the workspace of the robot',eType);
msg{906} = sprintf('%s: Given point is not in the workspace of the encoders',eType);
msg{907} = sprintf('%s: Given point is not in the workspace of the joints',eType);
msg{908} = sprintf('%s: Given point is not in the workspace',eType); % XYZPR specific
msg{909} = sprintf('%s: Invalid time duration of the movement',eType);
msg{910} = sprintf('%s: Invalid axis type',eType);
msg{911} = sprintf('%s: Motion in progress',eType);
mit{911} = sprintf('Use "ScorWaitForMove" between "ScorSet" commands that result in manipulator or gripper motion'); 
msg{912} = sprintf('%s: Configuration change',eType);
mit{912} = sprintf('Run "ScorGoHome" to move the ScorBot to the home position, if problem persists "ScorHome"');
qfx{912} = sprintf('ScorGoHome;');
msg{913} = sprintf('%s: Speed',eType);
msg{914} = sprintf('%s: Acceleration',eType);
msg{915} = sprintf('%s: Not enough space to store all points',eType);
msg{916} = sprintf('%s: Recursion!',eType);
msg{917} = sprintf('%s: Origin',eType);
msg{918} = sprintf('%s: Point already defined',eType);
msg{919} = sprintf('%s: Invalid point',eType);
msg{920} = sprintf('%s: Invalid length',eType);
msg{921} = sprintf('%s: Vector broken',eType);
msg{922} = sprintf('%s: Vectors of different groups not allowed',eType);
msg{923} = sprintf('%s: Invalid point name',eType);
msg{924} = sprintf('%s: Invalid group',eType);
msg{925} = sprintf('%s: Unassigned point',eType);
msg{926} = sprintf('%s: Not a vector type',eType);
msg{927} = sprintf('%s: Invalid version',eType);
msg{928} = sprintf('%s: Invalid version number',eType);
msg{929} = sprintf('%s: Percents must be between 0.0 and 1.0',eType);
msg{930} = sprintf('%s: Given point is not in the workspace of the B',eType);
msg{931} = sprintf('%s: Given point is not in the workspace of the C',eType);
msg{932} = sprintf('%s: Invalid I/O number',eType);
msg{933} = sprintf('%s: Invalid I/O value',eType);
msg{934} = sprintf('%s: I/O not disabled',eType);
msg{935} = sprintf('%s: The motion is out of the robot workspace',eType);
msg{936} = sprintf('%s: Invalid IRQ number',eType);
msg{937} = sprintf('%s: Robot home not done',eType);
msg{938} = sprintf('%s: Peripheral axis home not done',eType);
msg{939} = sprintf('%s: Undefined robot position',eType);
msg{940} = sprintf('%s: Undefined peripheral position',eType);
msg{941} = sprintf('%s: Cannot make mailslot',eType);
msg{942} = sprintf('%s: Cannot write mailslot',eType);
msg{943} = sprintf('%s: Wrong type of position',eType);
msg{944} = sprintf('%s: Undefined position',eType);
msg{945} = sprintf('%s: No characterin base position',eType);
msg{946} = sprintf('%s: Position is not in the Cartesian workspace!',eType);
msg{947} = sprintf('%s: Relative XYZPR',eType);
msg{948} = sprintf('%s: Absolute XYZPR',eType);
msg{949} = sprintf('%s: Robot cannot reach position required for writing character',eType);
msg{950} = sprintf('%s: Error in character template library. Contact your product dealer',eType);
msg{960} = sprintf('%s: ',eType);
msg{961} = sprintf('%s: ',eType);
msg{962} = sprintf('%s: Resultant point is not in the workspace',eType);
msg{963} = sprintf('%s: ',eType);
msg{970} = sprintf('%s: Teach Pendant switched to Teach mode',eType);
mit{970} = sprintf('Status update only, no action required.');
msg{971} = sprintf('%s: Teach Pendant switched to Auto mode',eType);
mit{971} = sprintf('Status update only, no action required.');
msg{973} = sprintf('%s: Peripherals positions are not suitable for peripherals configuration',eType);
msg{974} = sprintf('%s: Cannot delete position "N". It is the base position for relative position "M"',eType);
mit{974} = [];
qfx{974} = [];

% //-------------------------------------------------------------------------
% #define ERR_SYSTEM	  900         //"Position error during the motion is grater then allowed or impact has occured" 
%
% #define ERR_MAN_HM_ND   901	      //"Home not done"
% #define ERR_SINGU	      902	      //"Manual motion not allowed (singularity)"
% #define ERR_COFF	      903		  // "Control disabled"
% #define ERR_INCOO	      904	      // "Invalid coordinate type!"
% #define ERR_INV         905	      // "Given point is not in the workspace of the robot"
% #define ERR_ENC_INV     906	      // "Given point is not in the workspace of the encoders"
% #define ERR_JNT_INV     907	      //"Given point is not in the workspace of the joints"
% #define ERR_XYZ_INV     908	      //"Given point is not in the workspace of the Cartesian space"
% #define ERR_TIME_PAR	  909	      //"Invalid time duration of the movement"
% #define ERR_AXTYPE	  910		  // "Invalid axis tytpe"
% #define ERR_MOVP	      911		  // "Motion in progress"
% #define ERR_CCHANGE     912	      //"Configuration change"
% #define ERR_SPEED       913         // "Speed"
% #define ERR_ACCL        914         // "Acceleration"
% #define ERR_SPC	      915	      //"Not enaugh space to store all points"
% #define ERR_RCR		  916	      //"Recursion!"
% #define ERR_ORG		  917	      //"Orign"
% #define ERR_PDEF        918		  //"Point already defined"
% #define ERR_PINV        919		  //"Invalid point"
% #define ERR_LEN         920		  //len
% #define ERR_VEC_BRK     921		  //Vector broken
% #define ERR_VEC_GRP     922		  //Vectors of different groups not allwed
% #define ERR_PNAM        923         //"Invalid point name"
% #define ERR_GRP_INV     924         //"iNVALID GROUP"
% #define ERR_UNASS       925		  //"Unassigned point"
% #define ERR_NO_VEC      926         //"Not a vector type"
% #define ERR_PICVER      927		  // Invalid version
% #define ERR_VER         928	      // "Invalid version number"
% #define ERR_PROC        929	      //"Procents must be between 0.0 and 1.0"
% #define ERR_B_INV       930	      // "Given point is not in the workspace of the B"
% #define ERR_C_INV       931	      //"Given point is not in the workspace of the C"
% #define ERR_ION         932	      //"Invalid I/O number "
% #define ERR_IOV         933 		  //"Invalid I/O value  "
% #define ERR_IOD         934		  //"I/O not disabled"
% #define ERR_MWRK        935         //"The motion is out of the robot workspace"
% #define ERR_IRQ         936		  //"Invalid IRQ number."  //  Shimon
% 
% #define ERR_ROBOT_HM_ND 937         // "Robot home not done"   //  Shimon
% #define ERR_AXIS_HM_ND  938         // "Peripheral axis home not done" //  Shimon
% 
% #define ERR_UNASS_ROBOT  939        //"Undefined robot position"   // Shimon
% #define ERR_UNASS_PERIPH 940        //"Undefined peripheral position" // Shimon
% 
% #define ERR_NOT_MAIL          941   // "(%d) Cannot make mailslot '%s'"  // Shimon
% #define ERR_WRITE_MAIL        942   //"(%d) Cannot write mailslot '%s'"  // Shimon    New
% #define ERR_WRONG_POS_TYPE    943   // "Wrong type of position:  %d"
% #define ERR_UNDEF_POS         944   // "Undefined position: %d"
% #define ERR_CHAR_BASE_POS     945   // "No %d  Character: %c  Base position: %d"
% #define ERR_CART_WORKSPACE    946   // "Position  %d  is not in the Cartesian workspace!"
% #define ERR_REL_POS           947   // "Relative: X:%5.1f  Y:%5.1f  Z:%5.1f  P:%5.1f  R:%5.1f"
% #define ERR_ABS_POS           948   // "Absolute: X:%5.1f  Y:%5.1f  Z:%5.1f  P:%5.1f  R:%5.1f"
% #define ERR_CANNOT_WRITE_CHAR 949   // Robot cannot reach position required for writing character: %c   character # %d
% #define ERR_CHAR_TEMPL_LIB    950   // Error in character template library./nContact your product dealer.
% 
% #define COMM_TEACH            960
% #define KIN_ZERO              961
% #define KIN_BETA              962
% #define KIN_ALPHA             963
% 
% #define TP_TEACH              970   
% #define TP_AUTO               971
% 
% #define ERR_PERIPH_CONFIG     973   // Peripherals positions are not suitable for peripherals configuration.
% #define ERR_DELETE_POSIT      974   // Cannot delete position "N". It is the base position for relative position "M".
% 
% // Up to this error code are USER ERRORS *********************************
% //-------------------------------------------------------------------------

%% Assign code etc.
% Error message
if eCode <= numel(msg)
    if ~isempty(msg{eCode})
        errStruct.Message = msg{eCode};
    end
end
% Mitigation
if eCode <= numel(mit)
    if ~isempty(mit{eCode})
        errStruct.Mitigation = mit{eCode};
    end
end
% Quick Fix
if eCode <= numel(qfx)
    if ~isempty(qfx{eCode})
        errStruct.QuickFix = qfx{eCode};
    end
end
return
%% Unaddressed codes

% #define ERR_USER	      1000	      
% 
% 
% #define ERR_MAX         1500
% #define MAXERR 		   3000
% 
% // For Desktop application only
% #define DSK_ERRORS      CMM_CTRL_UNKN+500
% #define DSK_CFG 		   DSK_ERRORS+1
% #define DSK_CFG_ACCEPT  DSK_ERRORS+2
% #define DSK_CFG_OPEN    DSK_ERRORS+3
% #define DSK_CFG_NUM     DSK_ERRORS+4
% #define DSK_MOVE		   DSK_ERRORS+5
% #define DSK_POS_SPEC	   DSK_ERRORS+10
% #define DSK_POSM_SPEC   DSK_ERRORS+11
% #define DSK_POSTM_SPEC  DSK_ERRORS+12
% #define DSK_POS_IND	   DSK_ERRORS+13
% #define DSK_NOPEN		   DSK_ERRORS+14
% 
% ///////////////////////////////////////////////////////////////////////////
% // Text of the messages that are usually a fatal messages
% //
% 
% // #define WxxC  				MAXERR+1   // Mirko
% 
% #define WPCC_NAME      MAXERR+1
% #define WACLC_NAME     MAXERR+2
% #define WER3C_NAME     MAXERR+3
% 
% #define wc_ERR          MAXERR+4
% #define wc_MER				MAXERR+5
% #define wc_OO           MAXERR+6
% #define wc_TUN          MAXERR+7
% #define wc_VER          MAXERR+8
% #define wc_MEM          MAXERR+9
% #define wc_TIM          MAXERR+10
% #define wc_WPCC         MAXERR+11
% #define wc_CHK          MAXERR+12
% #define wc_ATA          MAXERR+13
% #define wc_CHNOAP       MAXERR+14
% #define wc_UOP          MAXERR+15
% #define wc_NOSEL        MAXERR+16
% #define wc_WxxC         MAXERR+17
% #define wc_UNDEF        MAXERR+18
% 
% #define IDS_NOTCONNECT_FN_AXIS  MAXERR+119
% #define IDS_INCORRECT_SELECT    MAXERR+120
% #define IDS_CONV_FN_AXIS        MAXERR+121
% #define IDS_SPEED_CNTR_CONV     MAXERR+122
% 
% 
% #define TP_ERROR			MAXERR+500
% 
% #define  ERR_MAN_HM_ND_STR 		TP_ERROR+1
% #define  ERR_SINGU_STR           TP_ERROR+2
% #define  ERR_COFF_STR            TP_ERROR+3
% #define  ERR_INCOO_STR           TP_ERROR+4
% #define  ERR_INV_STR             TP_ERROR+5
% #define  ERR_ENC_INV_STR         TP_ERROR+6
% #define  ERR_JNT_INV_STR         TP_ERROR+7
% #define  ERR_XYZ_INV_STR         TP_ERROR+8
% #define  ERR_MWRK_STR            TP_ERROR+9
% #define  ERR_B_INV_STR           TP_ERROR+10
% #define  ERR_C_INV_STR           TP_ERROR+11
% #define  ERR_AXTYPE_STR          TP_ERROR+12
% #define  ERR_MOVP_STR            TP_ERROR+13
% #define  ERR_CCHANGE_STR         TP_ERROR+14
% #define  ERR_SPEED_STR           TP_ERROR+15
% #define  ERR_ACCL_STR            TP_ERROR+16
% #define  ERR_PINV_STR            TP_ERROR+17
% #define  ERR_UNASS_STR           TP_ERROR+18
% #define  ERR_NO_VEC_STR          TP_ERROR+19
% #define  ERR_TRCK_STR            TP_ERROR+20
% #define  ERR_THR_STR             TP_ERROR+21
% #define  ERR_EMERG_STR           TP_ERROR+22
% #define  KIN_ZERO_STR            TP_ERROR+23
% #define  KIN_BETA_STR            TP_ERROR+24
% #define  KIN_ALPHA_STR           TP_ERROR+25
% #define  COMM_TEACH_STR          TP_ERROR+26
% #define  TP_ERR_STR              TP_ERROR+27
% #define  TP_FATAL_STR            TP_ERROR+28
% #define  TP_SYSTEM_STR           TP_ERROR+29
% #define  CMM_ERR_INVNAM_STR      TP_ERROR+30
% 
% #define DOSERROR						MAXERR+1000
% #define ERROROR_EZERO    DOSERROR+0      /* Error 0                  */
% #define ERROR_EINVFNC  DOSERROR+1      /* Invalid function number  */
% #define ERROR_ENOFILE  DOSERROR+2      /* File not found,   No such file or directory*/
% #define ERROR_ENOPATH  DOSERROR+3      /* Path not found           */
% #define ERROR_EMFILE   DOSERROR+4      /* Too many open files      */
% #define ERROR_EACCES   DOSERROR+5      /* Permission denied        */
% #define ERROR_EBADF    DOSERROR+6      /* Bad file number          */
% #define ERROR_ECONTR   DOSERROR+7      /* Memory blocks destroyed  */
% #define ERROR_ENOMEM   DOSERROR+8      /* Not enough core          */
% #define ERROR_EINVMEM  DOSERROR+9      /* Invalid memory block address */
% #define ERROR_EINVENV  DOSERROR+10      /* Invalid environment      */
% #define ERROR_EINVFMT  DOSERROR+11      /* Invalid format           */
% #define ERROR_EINVACC  DOSERROR+12      /* Invalid access code      */
% #define ERROR_EINVDAT  DOSERROR+13      /* Invalid data             */
% #define ERROR_EINVDRV  DOSERROR+15      /* Invalid drive specified  No such device */
% #define ERROR_ECURDIR  DOSERROR+16      /* Attempt to remove CurDir */
% #define ERROR_ENOTSAM  DOSERROR+17      /* Not same device          */
% #define ERROR_ENMFILE  DOSERROR+18      /* No more files            */
% #define ERROR_EFAULT   DOSERROR+14      /* Unknown error            */
% #define ERROR_EINVAL   DOSERROR+19      /* Invalid argument         */
% #define ERROR_E2BIG    DOSERROR+20      /* Arg list too long        */
% #define ERROR_ENOEXEC  DOSERROR+21      /* Exec format error        */
% #define ERROR_EXDEV    DOSERROR+22      /* Cross-device link        */
% #define ERROR_ENFILE   DOSERROR+23      /* Too many open files      */
% #define ERROR_ECHILD   DOSERROR+24      /* No child process         */
% #define ERROR_ENOTTY   DOSERROR+25      /* UNIX - not MSDOS         */
% #define ERROR_ETXTBSY  DOSERROR+26      /* UNIX - not MSDOS         */
% #define ERROR_EFBIG    DOSERROR+27      /* UNIX - not MSDOS         */
% #define ERROR_ENOSPC   DOSERROR+28      /* No space left on device  */
% #define ERROR_ESPIPE   DOSERROR+29      /* Illegal seek             */
% #define ERROR_EROFS    DOSERROR+30      /* Read-only file system    */
% #define ERROR_EMLINK   DOSERROR+31      /* UNIX - not MSDOS         */
% #define ERROR_EPIPE    DOSERROR+32      /* Broken pipe              */
% #define ERROR_EDOM     DOSERROR+33      /* Math argument            */
% #define ERROR_ERANGE   DOSERROR+34      /* Result too large         */
% #define ERROR_EEXIST   DOSERROR+35      /* File already exists      */
% #define ERROR_EDEADLOCK DOSERROR+36    /* Locking violation        */
% #define ERROR_EPERM   DOSERROR+37      /* Operation not permitted  */
% #define ERROR_ESRCH   DOSERROR+38      /* UNIX - not MSDOS         */
% #define ERROR_EINTR   DOSERROR+39      /* Interrupted function call */
% #define ERROR_EIO     DOSERROR+40      /* Input/output error       */
% #define ERROR_ENXIO   DOSERROR+41      /* No such device or address */
% #define ERROR_EAGAIN  DOSERROR+42      /* Resource temporarily unavailable */
% #define ERROR_ENOTBLK DOSERROR+43      /* UNIX - not MSDOS         */
% #define ERROR_EBUSY   DOSERROR+44      /* Resource busy            */
% #define ERROR_ENOTDIR DOSERROR+45      /* UNIX - not MSDOS         */
% #define ERROR_EISDIR  DOSERROR+46      /* UNIX - not MSDOS         */
% #define ERROR_EUCLEAN DOSERROR+47      /* UNIX - not MSDOS         */
