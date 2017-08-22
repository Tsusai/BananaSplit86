unit Main;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DosCommand, Vcl.ComCtrls,
	Vcl.ExtCtrls, Vcl.CheckLst, JvComponentBase, JvFormMagnet;

type
	TForm1 = class(TForm)
		ffmpegLog: TMemo;
		OpenBtn: TButton;
		DosCommand1: TDosCommand;
		BananaSplitLog: TMemo;
		AddJobBtn: TButton;
		KillTimer: TTimer;
		OpenDialog1: TOpenDialog;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		Panel1: TPanel;
		Thumb1: TImage;
		Panel2: TPanel;
		Thumb2: TImage;
		BlackSegList: TCheckListBox;
		CutList: TMemo;
		JvFormMagnet1: TJvFormMagnet;
		JobListBtn: TButton;
		StopBtn: TButton;
		procedure OpenBtnClick(Sender: TObject);
		procedure DosCommand1Terminated(Sender: TObject);
		procedure DosCommand1NewLine(ASender: TObject; const ANewLine: string;
			AOutputType: TOutputType);
		procedure FormCreate(Sender: TObject);
		procedure BlackSegListClick(Sender: TObject);
		procedure KillTimerTimer(Sender: TObject);
		procedure AddJobBtnClick(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure FormDestroy(Sender: TObject);
		procedure BlackSegListClickCheck(Sender: TObject);
		procedure JobListBtnClick(Sender: TObject);
		procedure StopBtnClick(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
		procedure GetBlackSegments;
		procedure GetSilence;
		procedure GenerateThumbnails(idx : integer);
	end;

var
	Form1: TForm1;
	ffmpeg : string;

implementation
uses
	StrUtils,
	IOUtils,
	TimeSpan,
	DateUtils,
	Jobs,
	Inifiles,
	VCL.Imaging.Jpeg,
	Contnrs;

type
	TBlackSeg = class
		StartT : TTime;
		EndT : TTime;
		MiddleT : TTime;
		DurationT : TTime;
		StartS : string;
		EndS : string;
		MiddleS : string;
		DurationS : string;
		//function GetDuration : string;
		function SecondsToTTime(Sec : single) : TTime;
	public
		Thumb1 : TJpegImage;
		Thumb2 : TJpegImage;
		procedure SetStart(Sec : single);
		procedure SetEnd(Sec : single);
		procedure SetMiddle;
		procedure SetDuration(Sec : single);
		constructor Create;
		destructor Destroy; override;
	end;

const
	//ffmpeg = 'C:\Users\Tsusai\Google Drive\MKLINK\VideoEncoding\RipBot264\Tools\ffmpeg\bin\ffmpeg.exe';
	gap = 2;

var
	SegHelper : TObjectlist;
	cDuration : single = 0;
	tDuration : string;
	ashow : string;
	HardStop : boolean = false;

{$R *.dfm}

(*------------------------------------------------------------------------------
TBlackSeg, it contains the timecodes for a black frame detection result
------------------------------------------------------------------------------*)
function TBlackSeg.SecondsToTTime(Sec : single) : TTime;
begin
	Result := EncodeTime(0,0,0,0);
	Result := IncSecond(Result,Trunc(Sec));
	Result := IncMilliSecond(Result,Trunc((Frac(Sec)*100)));
end;

procedure TBlackSeg.SetStart(Sec : single);
begin
	StartT := SecondsToTTime(Sec);
	StartS := FormatDateTime('hh:mm:ss.z',StartT);
end;

procedure TBlackSeg.SetEnd(Sec : single);
begin
	EndT := SecondsToTTime(Sec);
	EndS := FormatDateTime('hh:mm:ss.z',EndT);
end;

procedure TBlackSeg.SetMiddle;
begin
	MiddleT := StartT + (DurationT / 2);
	MiddleS := FormatDateTime('hh:mm:ss.z',MiddleT);
end;

procedure TBlackSeg.SetDuration(Sec : single);
begin
	DurationT := SecondsToTTime(Sec);
	DurationS := FormatDateTime('hh:mm:ss.z',DurationT);
end;

constructor TBlackSeg.Create;
begin
	inherited Create;
	StartT := EncodeTime(0,0,0,0);
	EndT := EncodeTime(0,0,0,0);
	DurationT := EncodeTime(0,0,0,0);
	MiddleT := EncodeTime(0,0,0,0);
end;

destructor TBlackSeg.Destroy;
begin
	if Assigned(Thumb1) then Thumb1.Free;
	if Assigned(Thumb2) then Thumb2.Free;
	inherited Destroy;
end;


(*------------------------------------------------------------------------------
FFmpeg Commands
------------------------------------------------------------------------------*)
procedure TForm1.GetBlackSegments;
const
	args = '"%s" -i "%s" -vf blackdetect=d=0.2:pix_th=.1 -f null - -y';
begin
	Doscommand1.CommandLine := Format(args,[ffmpeg,ashow]);
	//Doscommand1.OutputLines := Memo1.Lines;
	BananaSplitLog.Lines.Clear;
	BananaSplitLog.Lines.Append('Running Blackdetect');
	Doscommand1.Execute;
	while DosCommand1.IsRunning do
	begin
		//Sleep(500); //this will stop
		Application.ProcessMessages;
	end;
end;

procedure TForm1.GetSilence;
const
	args = '"%s" -i "%s" -af silencedetect=n=-20dB:d=0.15 -f null - -y';
begin
	if DosCommand1.IsRunning then exit;//just end my life fam
	BananaSplitLog.Lines.Append('Looking for Silence During Cut Durations to Improve Accuracy');
	DosCommand1.CommandLine := Format(args,[ffmpeg,ashow]);
	DosCommand1.Execute;
	while DosCommand1.IsRunning do
	begin
		sleep(50);
		Application.ProcessMessages;
	end;
end;

procedure TForm1.GenerateThumbnails(idx : integer);
const
	//TimeString, file, thumbnailname
	args = '"%s" -i "%s" -ss %s -vframes 1 %s -y';
	output = '(%d/%d) %s';
var
	mid : TTime;
	filenum : string;
	Segment : TBlackSeg;
	BSidx : integer;
begin
	BSidx := -1;
	if HardStop then exit;
	if DosCommand1.IsRunning then exit;//just end my life fam
	if idx >= 0 then
	begin
		Segment := TBlackSeg(BlackSegList.Items.Objects[idx]);
		if not Assigned(Segment.Thumb1) then
		begin
			BSidx := BananaSplitLog.Lines.Add(
				Format(output,[idx+1,BlackSegList.Count,Segment.MiddleS]) + ' (-2)'
			);
			mid := Segment.MiddleT;
			mid := IncSecond(mid,-gap);
			filenum := FormatDateTime('hhmmssz', mid)+'.jpg';
			DosCommand1.CommandLine :=
				Format(args,
					[ffmpeg,
					ashow,
					FormatDateTime('hh:mm:ss.z', mid),
					filenum]
				);
			DosCommand1.Execute;
			while DosCommand1.IsRunning do
			begin
				sleep(50);
				Application.ProcessMessages;
			end;
			if FileExists(filenum) then
			begin
				Segment.Thumb1 := TJpegImage.Create;
				Segment.Thumb1.LoadFromFile(filenum);
				DeleteFile(filenum); //cleanup
			end;
		end;
		if HardStop then exit;
		if not Assigned(Segment.Thumb2) then
		begin
			if BSidx = -1 then
			begin
				BSidx := BananaSplitLog.Lines.Add(
					Format(output,[idx+1,BlackSegList.Count,Segment.MiddleS]) + ' (-2)'
				);
			end else BananaSplitLog.Lines.Strings[BSidx] := BananaSplitLog.Lines.Strings[BSidx] + ' (+2)';
			mid := Segment.MiddleT;
			mid := IncSecond(mid,gap);
			filenum := FormatDateTime('hhmmssz', mid)+'.jpg';
			DosCommand1.CommandLine :=
				Format(args,
					[ffmpeg,
					ashow,
					FormatDateTime('hh:mm:ss.z', mid),
					filenum]
				);
			DosCommand1.Execute;
			while DosCommand1.IsRunning do
			begin
				sleep(50);
				Application.ProcessMessages;
			end;
			if FileExists(filenum) then
			begin
				Segment.Thumb2 := TJpegImage.Create;
				Segment.Thumb2.LoadFromFile(filenum);
				DeleteFile(filenum); //cleanup
			end;
		end;
	end;
	if BSidx <> -1 then BananaSplitLog.Lines.Strings[BSidx] := BananaSplitLog.Lines.Strings[BSidx] + ' ‎✔';
end;

(*------------------------------------------------------------------------------
FFmpeg Output Processing
------------------------------------------------------------------------------*)
procedure GrabCuts(ALine : string);
var
	Segment : TBlackSeg;
	AList : TStringList;
	atime : single;
begin
	ALine := StringReplace(ALine,':','=',[rfReplaceAll]);
	AList := TStringList.Create;
	AList.DelimitedText := ALine;

	//Values are SecondsTotal.milisecond
	//Times are set to 0 on object creation
	atime := StrToFloat(AList.Values['black_start']);
	//Not bothering with anything below 2 minutes or 2 min to the end
	if (atime >= 120) and ((cDuration-atime) > 120) then
	begin
		Segment := TBlackSeg.Create;
		Segment.SetStart(ATime);

		atime := StrToFloat(AList.Values['black_end']);
		Segment.SetEnd(ATime);

		atime := StrToFloat(AList.Values['black_duration']);
		Segment.SetDuration(ATime);

		Segment.SetMiddle;

		Form1.BlackSegList.AddItem(Segment.MiddleS,Segment);
		SegHelper.Add(Segment);
		//Segment.Free; OWNED BY SEGHELPER DO NOT FREE
	end;
	AList.Free;
end;

procedure GrabSilence(ALine : string);
var
	AList : TStringList;
	atime : single;
	Silence : TTime;
	Segment : TBlackSeg;
	idx : integer;
begin
	ALine := StringReplace(ALine,': ','=',[rfReplaceAll]);
	ALine := StringReplace(ALine,'|',',',[rfReplaceAll]);
	AList := TStringList.Create;
	AList.DelimitedText := ALine;

	atime := StrToFloat(AList.Values['silence_end']);
	Silence := EncodeTime(0,0,0,0);
	Silence := IncSecond(Silence,Trunc(atime));
	Silence := IncMilliSecond(Silence,Trunc((Frac(atime)*100)));

	atime:= StrToFloat(AList.Values['silence_duration']);
	atime := atime / 2;
	Silence := IncSecond(Silence,-Trunc(atime));
	Silence := IncMilliSecond(Silence,-Trunc((Frac(atime)*100)));

	AList.Free;

	for idx := 0 to Form1.BlackSegList.Count -1 do
	begin
		Segment := TBlackSeg(Form1.BlackSegList.Items.Objects[idx]);
		if (Silence > Segment.StartT) and (Silence < Segment.EndT) then
		begin
			Form1.BananaSplitLog.Lines.Add('Silence Timecode Match Found, Adjusting');
			Segment.MiddleT := Silence;
			Segment.MiddleS := FormatDateTime('hh:mm:ss.z',Segment.MiddleT);
			Form1.BlackSegList.Items.Strings[idx] := Segment.MiddleS + '*';
		end;
	end;
end;

procedure GrabDuration(ALine : string);
var
	AList : TStringList;
	timeSpan : TTimeSpan;
begin
	cDuration := 0;
	ALine := Trim(ALine);
	ALine := StringReplace(ALine,'Duration: ','Duration=',[rfReplaceAll]);
	AList := TStringList.Create;
	AList.CommaText := ALine;
	tDuration := AList.ValueFromIndex[0];
	timespan := TTimeSpan.Parse(tDuration);

	//Values are SecondsTotal.milisecond
	//Times are set to 0 on object creation
	cDuration := timespan.TotalSeconds;
	AList.Free;
end;

(*------------------------------------------------------------------------------
MainForm Controls
------------------------------------------------------------------------------*)

procedure TForm1.OpenBtnClick(Sender: TObject);
var
	idx : integer;
begin
	if OpenDialog1.Execute() then
	begin
		ashow := OpenDialog1.FileName;
		OpenDialog1.FileName := ''; //clear;
	end else exit; //we found nothing, so do nothing.
	OpenBtn.Enabled := false;
	Form1.Caption := ' BananaSplit86 - ' + ExtractFileName(ashow);

	if DosCommand1.IsRunning then
	begin
		BananaSplitLog.Lines.Append('Waiting on Background Processes to Stop');
		DosCommand1.Stop;
	end;
	while DosCommand1.IsRunning do Sleep(50);
	HardStop := false;

	Thumb1.Picture.Assign(nil);
	Thumb2.Picture.Assign(nil);
	CutList.Clear;
	BlackSegList.Clear;
	SegHelper.Clear;

	GetBlackSegments;

	if Not HardStop then
	begin
		if BlackSegList.Items.Count = 0 then
		begin
			ShowMessage('Nothing detected, stopping');
			HardStop := true;
		end;
	end;

	if Not HardStop then GetSilence;

	if Not HardStop then
	begin
		BananaSplitLog.Lines.Append('Generating Thumbnails');
		for idx := 0 to BlackSegList.Items.Count - 1 do
		begin
			GenerateThumbnails(idx);
		end;
		BananaSplitLog.Lines.Append('Finished Generating Thumbnails');
	end;
	OpenBtn.Enabled := true;
	HardStop := false;
end;

procedure TForm1.StopBtnClick(Sender: TObject);
begin
	BananaSplitLog.Lines.Append('All Stop Requested');
	HardStop := true;
	KillTimer.Enabled := true;
end;

procedure TForm1.AddJobBtnClick(Sender: TObject);
begin
	Form2.AddJob(ashow,tDuration);
end;

procedure TForm1.JobListBtnClick(Sender: TObject);
begin
	if Form2.Showing then Form2.Close else Form2.Show;
end;

procedure TForm1.BlackSegListClickCheck(Sender: TObject);
var
	idx : integer;
	CutPoints : TStringList;
	Segment : TBlackSeg;
begin
	CutList.Clear;
	CutPoints := TStringList.Create;
	CutPoints.Add('00:00:00.00');
	for idx := 0 to BlackSegList.Items.Count-1 do
	begin
		if BlackSegList.Checked[idx] then
		begin
			Segment := TBlackSeg(BlackSegList.Items.Objects[idx]);
			if Assigned(Segment.Thumb1) and Assigned(Segment.Thumb2) then
			begin
				Thumb1.Picture.Bitmap.Assign(Segment.Thumb1);
				Thumb2.Picture.Bitmap.Assign(Segment.Thumb2);
			end else
			begin
				Thumb1.Picture.Assign(nil);
				Thumb2.Picture.Assign(nil);
			end;
			//NEVERMIND
			//This seems to work the best. Middle is too soon, end is too late, so go half way between mid and end
			//CutPoints.Add(FormatDateTime('hh:mm:ss.z', Segment._middle + ((Segment._end - Segment._middle)/2)));
			CutPoints.Add(Segment.MiddleS);
		end;
	end;
	CutPoints.Add(tDuration);
	//Memo2.Lines.Assign(CutPoints);
	if CutPoints.Count > 2 then
	begin
		for idx := 0 to CutPoints.Count-2 do
		begin
			CutList.Lines.Add(CutPoints.Strings[idx] + ',' + CutPoints.Strings[idx+1]);
		end;
	end;
end;

procedure TForm1.DosCommand1NewLine(ASender: TObject; const ANewLine: string;
	AOutputType: TOutputType);
begin
	ffmpegLog.Lines.Add(ANewLine);

	if AnsiContainsStr(ANewLine,'Duration: ') and (cDuration < 1) then
	begin
		GrabDuration(ANewLine);
	end;

	if AnsiStartsStr('[blackdetect @ ',ANewLine) and
	AnsiContainsStr(ANewLine,'_duration') then
	begin
		GrabCuts(ANewLine);
	end;

	if AnsiStartsStr('[silencedetect @ ',ANewLine) and
	AnsiContainsStr(ANewLine,'_duration') then
	begin
		GrabSilence(ANewLine);
	end;
end;

procedure TForm1.DosCommand1Terminated(Sender: TObject);
begin
	ffmpeglog.Lines.Add('FFMpeg Process Finished');
	KillTimer.Enabled := true;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	HardStop := true;
	Doscommand1.Stop;
	CanClose := true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
	ini : TMemIniFile;
begin
	SegHelper := TObjectList.Create;
	SegHelper.OwnsObjects := true;
	ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
	ffmpeg := ini.ReadString('FFmpeg','Executable','c:\full path to exe without quotes please');
	ini.Free;
	if not FileExists(ffmpeg) then
	begin
		ShowMessage('Please close the program and set the path to ffmpeg in the ini file');
		close;
	end;
	Thumb1.Align := alClient;
	Thumb2.Align := alClient;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
	ini : TMemIniFile;
begin
	ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
	ini.WriteString('FFmpeg','Executable',ffmpeg);
	ini.UpdateFile;
	ini.Free;

	SegHelper.Free;
end;

procedure TForm1.BlackSegListClick(Sender: TObject);
var
	Segment : TBlackSeg;
begin
	if BlackSegList.ItemIndex >=0 then
	begin
		Segment := TBlackSeg(BlackSegList.Items.Objects[BlackSegList.ItemIndex]);

		if Assigned(Segment.Thumb1) then
		begin
			Thumb1.Picture.Bitmap.Assign(Segment.Thumb1);
			Thumb1.Visible := true;
		end else Thumb1.Visible := false;

		if Assigned(Segment.Thumb2) then
		begin
			Thumb2.Picture.Bitmap.Assign(Segment.Thumb2);
			Thumb2.Visible := true;
		end else Thumb2.Visible := false;


	end;
end;

procedure TForm1.KillTimerTimer(Sender: TObject);
begin
	DosCommand1.Stop;
	KillTimer.Enabled := false;
end;

{


                                      eTRL
                                     M!!!9
                                      #@@
WHY WON'T THIS WORK                    RX)
I'LL MAKE MY OWN PROGRAM               RMR
WITH BLACKJACK....AND HOOKERS          RM$
                                       RMM
                                       B8WL
                                      @XUUUUN...
                                  z@TMMMMMMMMMMMMMRm.
                               uRMMMMMMMMMMMMMMMMMMMMRc
                             :5MMMMMMMMMMMMMMMMMMMMMMMM$.
                            dMMMMMMMMMMMMMMMMMMMMMMMMMMMMr
                           JMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.
                           MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM$
                           MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM)
                           MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMR
                           MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM$....
                           MMMMMMM8*TTTTTTT???!!!!!!!!!!!!!!!!!!!?N.
                           3MMMM8?!!U*$$$$$$$$$$$$$$$$$$$$**$$$$$N!!N
                           4XMM$!!XF~~~~~~"#*$$$$$$R#"~~~~~~~$$$$$$!!)
                           4XMME!!$~~~~~~~~~~~~~?~~~~~~~(:::~?$$$$$R!)
                           'MMM!!!&~~~~~~4$$E~~~X~~~~~~~3$$E~4$$$$$E!)
                            EM9!!!M:~~~~~~""!~~~6~~~~~~~~~~~($$$$$$!9
                            RM@!!!!?i:~~~~~~~~($$N~~~~~~~~~\$$$$$#!XF
                            $MMB!!!!!!!TT#**@******##TTTTTT?!!!!!U#
                            MMMMN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!U#
                            tMMMMMRR@@@*RRMHHMMMMMHHHMMRTTRR@
                            4XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM9
                            'MMMMMMMMMMMMMMM86QQQQQ8MMMMMMMM9
                             EMMMMMMMM8*"~~~~f~~~~t~~~~~RMMM@
                             RMMMMMSF~~R~~~~(!~~~~$~~~~~$#"
                             $MMMMMF~~~Kuuii@m+++*$*++mmR
                             MMMMM9~~~!!~~~~@(::XuBL::~~R
             .um=*#""""""#*=+@MMMMMN+*#F~~~~M~~~~~X~~~~~$"~:~~~~~~~:("?%u.
         z*"~~~~~~~~~~~~~~~~~?MMMMMMK~~F~~~~?:~~~~$~~~~~M~~~~~~~~~~~~~~~~~~%u
      z"(~~~~~~~~~~~~~~~~~~~~~RMMMMMMRi$~:Xuu9emmm@@@%mmhi~~~~~~~~~~~~~~~~~~~^h
    z"~~~~~~~~~~~~~~~~~~~~~~~~RMMMMMMMMMMMMMMMMMMMMMMMMMMM&~~~~~~~~~~~~~~~'#C#=@c
   f.ue~~~~~~~~~~~^""#*+iL:~~~$MMMMMMMMMMMMMMMMMMMMMMMMMMMR~~~~~~~~~~~~~~~~~~?L
  "  F~~~~~~~~~~~~~~~~~~~~~:~"*8MMQ8N@*#TTT?!!!!!!!!!!!!?TT%miF~~~~~~~~~~~~~~~~$T*c
    F~~~~~~~~~~~~~~~~~~~~~~~~~~~~~?tX!!!!!!!!!!!!!!!!!!!!!!!XF~~~~~~~~~~~~~~~~~~N!!?k
   @.zm%i:~~~~~~~~~~~~~~~~~~~~~~~~~~~"*X!!!!!!!!!!!!!!!!!!!W"~~~~~~~~~~~~~"#NX!!!!!!!k
   d!!!!!!N/~~~~~~~~~~~~~~~~~~~~~~~~~~~~?t!!!!!!!!!!!!!!!!@~~~~~~~~~~~~~~~~~~~~#X!!!!9
  d!!!!!!!!?$RRRRRRRRRRRRNmi.~~~~~~~~~~~~~~N!!!!!!!!!!!!XF~~~~~~~~~~~~~(uz@$RRN!!!!!!!
  E!!!!!!!!!!$MMMMMMMMMMMM$?"~~~~~~~~~~~~~~~^N??!!!!!!XF~~~~~~~~~~.z@RMMMMMMMMM&!!!!!!
 4!!!!!!!!!!!!$MMMMMMMMMMMMMMR$mL~~~~~~~~~~~~~?X!!!!!XF~~~~~~~:eRMMMMMMMMMMMMMM$!!!!!!
 4!!!!!!!!!!!!?MMMMMMMMMMMMMMMMMMMMRmL~~~~~~~~~~N!!!!F~~~~~:@RMMMMMMMMMMMMMMMMMM&!!!!!
 4WRR$W!!!!!!!!9MMMMMMMMMMMMMMMMMMMMMMMRNi:~~~~~:N!!@~~~~zRMMMMMMMMMMMMMMMMMMMMM$!!!!9
 }
 end.
