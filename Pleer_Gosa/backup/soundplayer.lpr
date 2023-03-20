program soundplayer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, gosa_program, help_program, equalizer_program
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TPleer_Form, Pleer_Form);
  Application.CreateForm(THelp_Form, Help_Form);
  Application.CreateForm(TEqualizer_Form, Equalizer_Form);
  Application.Run;
end.

