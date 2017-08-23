unit Jobs;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvComponentBase, JvFormMagnet,
	Vcl.StdCtrls, Vcl.CheckLst;

type
	TForm2 = class(TForm)
		JvFormMagnet1: TJvFormMagnet;
		JobList: TCheckListBox;
		BatchBtn: TButton;
		ClearBtn: TButton;
		DeSelBtn: TButton;
		SelectBtn: TButton;
		procedure FormShow(Sender: TObject);
		procedure BatchBtnClick(Sender: TObject);
		procedure JobListKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure AddJob(const AFile : string; const tDuration : string);
		procedure SaveINI;
		procedure ClearBtnClick(Sender: TObject);
		procedure SelectBtnClick(Sender: TObject);
		procedure DeSelBtnClick(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	Form2: TForm2;


implementation
uses
	Main,
	IniFiles,
	Contnrs,
	IOUtils;

type TJobObj = class
	Cuts : TStringList;
	TheShow : string;
	constructor Create;
	destructor Destroy; override;
end;

var
	JobHelper : TObjectList;

{$R *.dfm}

(*------------------------------------------------------------------------------
TJobObj, it contains the information for 1 Job
------------------------------------------------------------------------------*)
constructor TJobObj.Create;
begin
	inherited Create;
	Cuts := TStringList.Create;
end;

destructor TJobObj.Destroy;
begin
	Cuts.Free;
	inherited;
end;

(*------------------------------------------------------------------------------
New Job Creation
------------------------------------------------------------------------------*)
procedure TForm2.AddJob(const AFile : string; const tDuration : string);
const
//	args = '"%s" -i "%s" -ss %s -to %s -acodec copy -vcodec libx264 -y "%s"';
	//input file, start, end , outputfilename
	Line = '%d Clips(s) | %s';
var
	//cutpoints : TStringList;
	idx : integer;
	AJob : TJobObj;
begin
	AJob := TJobObj.Create;
	AJob.TheShow := AFile;
	AJob.Cuts.Append('00:00:00.00');
	for idx := 0 to Form1.BlackSegList.Count -1 do
	begin
		if Form1.BlackSegList.Checked[idx] then
		begin
			AJob.Cuts.Append(
				StringReplace(Form1.BlackSegList.Items.Strings[idx],'*','',[rfReplaceAll])
			);
		end;
	end;
	AJob.Cuts.Append(tDuration);
	if AJob.Cuts.Count = 2 then
	begin
		ShowMessage('Nothing to Cut');
		AJob.Free; //Its never added so free
		exit;
  end;

	{CutPoints := TStringList.Create;
	for idx := 0 to Form1.CutList.Lines.Count -1 do
	begin
		CutPoints.CommaText := Form1.CutList.Lines.Strings[idx];
		CutPoints.Add(AFile);
		JobList.Checked[JobList.Items.Add(CutPoints.CommaText)] := true;
	end;
	CutPoints.Free;}

	idx := JobList.Items.AddObject(
		Format(Line,[AJob.Cuts.Count-1,ExtractFileName(AJob.TheShow)]),
		AJob
	);
	JobHelper.Add(AJob); //this owns the Job Object
	JobList.TopIndex := JobList.Items.Count - 1;
	JobList.Checked[idx] := true;
	SaveINI;

end;

(*------------------------------------------------------------------------------
Job List -> Batch File
------------------------------------------------------------------------------*)
procedure TForm2.BatchBtnClick(Sender: TObject);
const
	args = '"%s" -i "%s" -ss %s -to %s -acodec copy -vcodec libx264 -y "%s"';
	//input file, start, end , outputfilename
var
	idx : integer;
	AJob : TJobObj;
	Batch : TStringList;
	cutidx : integer;
begin
	Batch := TStringList.Create;
	for idx := 0 to JobList.Count -1 do
	begin
		if JobList.Checked[idx] then
		begin
			AJob := JobList.Items.Objects[idx] as TJobObj;
			for cutidx := 0 to AJob.Cuts.Count - 2 do
			begin
				Batch.Add(Format(args,
					[ffmpeg,
					AJob.TheShow,
					AJob.Cuts.Strings[cutidx],
					AJob.Cuts.Strings[cutidx+1],
					ExtractFilePath(AJob.TheShow)+TPath.GetFileNameWithoutExtension(AJob.TheShow)+'('+IntToStr(cutidx+1)+').mkv'])
				);
			end;
		end;
	end;
	Batch.SaveToFile('Jobs.cmd');
	Batch.Free;
	ShowMessage('Done, see Jobs.cmd');
end;

(*------------------------------------------------------------------------------
Form Controls
------------------------------------------------------------------------------*)
procedure TForm2.JobListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	if (Key=VK_Delete) and (JobList.ItemIndex > -1) then
	begin
		JobList.Items.Delete(JobList.ItemIndex);
		JobHelper.Delete(JobList.ItemIndex);
	end;
end;

procedure TForm2.FormCreate(Sender: TObject);
const
	Line = '%d Clips(s) | %s';
var
	ini : TMemIniFile;
	i : integer;
	JobInfo : TStringList;
	JobLines : TStringList;
	AJob : TJobObj;
begin
	JobInfo := TStringList.Create;
	JobLines := TStringList.Create;
	JobHelper := TObjectList.Create;
	JobHelper.OwnsObjects := true;
	ini := TMemIniFile.Create('Jobs.ini');
	try
		JobLines.Clear;
		JobInfo.Clear;
		ini.ReadSection('Jobs', JobLines);
		for i := 0 to JobLines.Count - 1 do
		begin
			JobInfo.CommaText := JobLines.Strings[i];
			AJob := TJobObj.Create;
			AJob.Cuts.Assign(JobInfo);
			AJob.TheShow := AJob.Cuts.Strings[AJob.Cuts.Count-1];
			AJob.Cuts.Delete(AJob.Cuts.Count-1);
			JobList.Items.AddObject(
				Format(Line,[AJob.Cuts.Count-1,ExtractFileName(AJob.TheShow)]),
				AJob
			);
			JobHelper.Add(AJob); //this owns the Job Object
			JobList.Checked[i] := ini.ReadBool('Jobs', JobLines[i], False);
		end;
	finally
		ini.Free;
		JobInfo.Free;
		JobLines.Free;
	end;
end;

procedure TForm2.SaveINI;
var
	ini : TMemIniFile;
	i : integer;
	tmp : TStringList;
begin
	tmp := TStringList.Create;
	ini := TMemIniFile.Create('Jobs.ini');
	ini.Clear;
	try
		for i := 0 to JobList.Items.Count - 1 do
		begin
			tmp.Clear;
			tmp.Assign(
				TJobObj(JobList.Items.Objects[i]).Cuts
			);
			tmp.Append(
				TJobObj(JobList.Items.Objects[i]).TheShow
			);
			ini.WriteBool('Jobs', tmp.CommaText, JobList.Checked[i]);
		end;
		ini.UpdateFile;
	finally
		ini.Free;
	end;
	tmp.Free;
end;

procedure TForm2.SelectBtnClick(Sender: TObject);
var
	idx : integer;
begin
	for idx := 0 to JobList.Count-1 do JobList.Checked[idx] := true;
end;

procedure TForm2.ClearBtnClick(Sender: TObject);
begin
	JobList.Clear;
	JobHelper.Clear;
end;

procedure TForm2.DeSelBtnClick(Sender: TObject);
var
	idx : integer;
begin
	for idx := 0 to JobList.Count-1 do JobList.Checked[idx] := false;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
	SaveINI;
	JobHelper.Free;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
	Self.Left := Form1.Left+Form1.Width;
	Self.Top  := Form1.Top;
	Self.Height := Form1.Height;
end;

end.
