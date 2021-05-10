program animator;

{$mode delphi}

uses
  Codebot.System, Interfaces, Forms, Main, AnimateTools, AnimateEasings,
  AnimateWheel, AnimatePaint, AnimateExample, AnimateParallax
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TAnimateForm, AnimateForm);
  Application.Run;
end.

