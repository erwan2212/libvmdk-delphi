program client;

uses
  madExcept,
  madLinkDisAsm,
  madListModules,
  Forms,
  umain in 'umain.pas' {Form1},
  libvmdk in '..\libvmdk.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
