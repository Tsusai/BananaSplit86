program BananaSplit86;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  Jobs in 'Jobs.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
